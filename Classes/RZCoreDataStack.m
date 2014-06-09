//
//  RZCoreDataStack.m
//  RZVinyl
//
//  Created by Nick Donaldson on 6/4/14.
//
//  Copyright 2014 Raizlabs and other contributors
//  http://raizlabs.com/
//
//  Permission is hereby granted, free of charge, to any person obtaining
//  a copy of this software and associated documentation files (the
//                                                                "Software"), to deal in the Software without restriction, including
//  without limitation the rights to use, copy, modify, merge, publish,
//  distribute, sublicense, and/or sell copies of the Software, and to
//  permit persons to whom the Software is furnished to do so, subject to
//  the following conditions:
//
//  The above copyright notice and this permission notice shall be
//  included in all copies or substantial portions of the Software.
//
//  THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND,
//  EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF
//  MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND
//  NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT HOLDERS BE
//  LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER IN AN ACTION
//  OF CONTRACT, TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN CONNECTION
//  WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE.


#import "RZCoreDataStack.h"
#import "NSManagedObject+RZVinylRecord.h"
#import "RZVinylDefines.h"

@interface RZCoreDataStack ()

@property (nonatomic, strong, readwrite) NSManagedObjectModel            *managedObjectModel;
@property (nonatomic, strong, readwrite) NSManagedObjectContext          *mainManagedObjectContext;
@property (nonatomic, strong, readwrite) NSPersistentStoreCoordinator    *persistentStoreCoordinator;

@property (nonatomic, strong) NSManagedObjectContext *topLevelBackgroundContext;

@property (nonatomic, copy) NSString *modelName;
@property (nonatomic, copy) NSString *modelConfiguration;
@property (nonatomic, copy) NSString *storeType;
@property (nonatomic, copy) NSURL    *storeURL;
@property (nonatomic, strong) dispatch_queue_t backgroundContextQueue;
@property (nonatomic, assign) RZCoreDataStackOptions options;

@property (nonatomic, readonly, strong) NSDictionary *entityClassNamesToStalenessPredicates;

@end

@implementation RZCoreDataStack

@synthesize entityClassNamesToStalenessPredicates = _entityClassNamesToStalenessPredicates;

+ (void)load
{
    [self buildDefaultStack];
}

- (id)init
{
    return [self initWithModelName:nil
                     configuration:nil
                         storeType:nil
                          storeURL:nil
                           options:kNilOptions];
}

- (instancetype)initWithModelName:(NSString *)modelName
                    configuration:(NSString *)modelConfiguration
                        storeType:(NSString *)storeType
                         storeURL:(NSURL *)storeURL
                          options:(RZCoreDataStackOptions)options
{
    return [self initWithModelName:modelName
                     configuration:modelConfiguration
                         storeType:storeType
                          storeURL:storeURL
        persistentStoreCoordinator:nil
                           options:options];
}

- (instancetype)initWithModelName:(NSString *)modelName
                    configuration:(NSString *)modelConfiguration
                        storeType:(NSString *)storeType
                         storeURL:(NSURL *)storeURL
       persistentStoreCoordinator:(NSPersistentStoreCoordinator *)psc
                          options:(RZCoreDataStackOptions)options
{
    self = [super init];
    if ( self ) {
        _modelName                  = modelName;
        _modelConfiguration         = modelConfiguration;
        _storeType                  = storeType ?: NSInMemoryStoreType;
        _storeURL                   = storeURL;
        _persistentStoreCoordinator = psc;
        _options                    = options;
        
        _backgroundContextQueue     = dispatch_queue_create("com.rzvinyl.backgroundContextQueue", DISPATCH_QUEUE_SERIAL);
        
        if ( ![self buildStack] ) {
            return nil;
        }
        
        [self registerForNotifications];
    }
    return self;
}

- (instancetype)initWithModel:(NSManagedObjectModel *)model
                    storeType:(NSString *)storeType
                     storeURL:(NSURL *)storeURL
   persistentStoreCoordinator:(NSPersistentStoreCoordinator *)psc
                      options:(RZCoreDataStackOptions)options
{
    if ( !RZVParameterAssert(model) ) {
        return nil;
    }
    
    self = [super init];
    if ( self ) {
        _managedObjectModel         = model;
        _storeType                  = storeType ?: NSInMemoryStoreType;
        _storeURL                   = storeURL;
        _persistentStoreCoordinator = psc;
        _options                    = options;
        
        _backgroundContextQueue     = dispatch_queue_create("com.rzvinyl.backgroundContextQueue", DISPATCH_QUEUE_SERIAL);
        
        if ( ![self buildStack] ) {
            return nil;
        }
        
        [self registerForNotifications];
    }
    
    return self;
}

- (void)dealloc
{
    [self unregisterForNotifications];
}

#pragma mark - Public

- (void)performBlockUsingBackgroundContext:(RZCoreDataStackTransactionBlock)block completion:(void (^)(NSError *err))completion
{
    if ( !RZVParameterAssert(block) ) {
        return;
    }
    
    dispatch_async(self.backgroundContextQueue, ^{
        NSManagedObjectContext *context = [self temporaryChildManagedObjectContext];
        [context performBlock:^{
            block(context);
            NSError *err = nil;
            [context save:&err];
            if ( completion ) {
                dispatch_async(dispatch_get_main_queue(), ^{
                    completion(err);
                });
            }
        }];
    });
}

- (NSManagedObjectContext *)temporaryChildManagedObjectContext
{
    NSManagedObjectContext *tempChild = [[NSManagedObjectContext alloc] initWithConcurrencyType:NSPrivateQueueConcurrencyType];
    tempChild.parentContext = self.mainManagedObjectContext;
    return tempChild;
}

- (void)save:(BOOL)wait
{
    __block NSError *bgSaveErr = nil;
    void (^diskSave)() = ^{
        if ( ![self.topLevelBackgroundContext save:&bgSaveErr] ) {
            RZVLogError(@"Error saving to persistent store: %@", bgSaveErr);
        }
    };
    
    __block NSError *err = nil;
    if ( [self.mainManagedObjectContext hasChanges] ) {
        [self.mainManagedObjectContext performBlockAndWait:^{
            if ( ![self.mainManagedObjectContext save:&err] ) {
                RZVLogError(@"Error saving main managed object context: %@", bgSaveErr);
            }
        }];
    }
    
    if ( [self.topLevelBackgroundContext hasChanges] ) {
        if ( wait ) {
            [self.topLevelBackgroundContext performBlockAndWait:diskSave];
        }
        else {
            [self.topLevelBackgroundContext performBlock:diskSave];
        }
    }
    
}

- (void)purgeStaleObjectsWithCompletion:(void (^)(NSError *))completion
{
    [self performBlockUsingBackgroundContext:^(NSManagedObjectContext *context) {
        
        [self.entityClassNamesToStalenessPredicates enumerateKeysAndObjectsUsingBlock:^(NSString *className, NSPredicate *predicate, BOOL *stop) {
            
            Class moClass = NSClassFromString(className);
            if ( moClass != Nil ) {
                [moClass rzv_deleteAllWhere:predicate];
            }
            
        }];
        
    } completion:^(NSError *err) {

        if ( err == nil ) {
            [self save:YES];
        }
        else {
            RZVLogError(@"Error saving after stale objects purge: %@", err);
        }
        
        if (completion) {
            completion(err);
        }
        
    }];
}

#pragma mark - Lazy Default Properties

- (NSString *)modelName
{
    if ( _modelName == nil ) {
        NSMutableString *productName = [[[NSBundle mainBundle] objectForInfoDictionaryKey:@"CFBundleDisplayName"] mutableCopy];
        [productName replaceOccurrencesOfString:@" " withString:@"_" options:0 range:NSMakeRange(0, productName.length)];
        [productName replaceOccurrencesOfString:@"-" withString:@"_" options:0 range:NSMakeRange(0, productName.length)];
        _modelName = [NSString stringWithString:productName];
    }
    return _modelName;
}

- (NSURL *)storeURL
{
    if (_storeURL == nil) {
        if ( [self.storeType isEqualToString:NSSQLiteStoreType] ) {
            NSString *storeFileName = [self.modelName stringByAppendingPathExtension:@"sqlite"];
            NSURL    *libraryDir = [[[NSFileManager defaultManager] URLsForDirectory:NSLibraryDirectory inDomains:NSUserDomainMask] lastObject];
            _storeURL = [libraryDir URLByAppendingPathComponent:storeFileName];
        }
    }
    return _storeURL;
}

- (NSDictionary *)entityClassNamesToStalenessPredicates
{
    __block NSDictionary *result = nil;
    
    //!!!: Must be a thread-safe lazy load
    rzv_performBlockAtomically(^{
        if ( _entityClassNamesToStalenessPredicates == nil ) {
            // Enumerate the model and discover stale predicates for each entity class
            NSMutableDictionary *classNamesToStalePredicates = [NSMutableDictionary dictionary];
            [[self.managedObjectModel entities] enumerateObjectsUsingBlock:^(NSEntityDescription *entity, NSUInteger idx, BOOL *stop) {
                Class moClass = NSClassFromString(entity.managedObjectClassName);
                if ( moClass != Nil ) {
                    NSPredicate *predicate = [moClass rzv_stalenessPredicate];
                    if ( predicate != nil ) {
                        [classNamesToStalePredicates setObject:predicate forKey:entity.managedObjectClassName];
                    }
                }
            }];
            _entityClassNamesToStalenessPredicates = [NSDictionary dictionaryWithDictionary:classNamesToStalePredicates];
        }
        result = _entityClassNamesToStalenessPredicates;
    });
    
    return result;
}

#pragma mark - Private

- (BOOL)hasOptionsSet:(RZCoreDataStackOptions)options
{
    return ( ( self.options & options ) == options );
}

- (BOOL)buildStack
{
    if ( !RZVAssert(self.modelName != nil, @"Must have a model name") ) {
        return NO;
    }
    
    //
    // Create model
    //
    if ( self.managedObjectModel == nil ) {
        self.managedObjectModel = [[NSManagedObjectModel alloc] initWithContentsOfURL:[[NSBundle mainBundle] URLForResource:self.modelName withExtension:@"momd"]];
        if ( self.managedObjectModel == nil ) {
            RZVLogError(@"Could not create managed object model for name %@", self.modelName);
            return NO;
        }
    }
    
    //
    // Create PSC
    //
    NSError *error = nil;
    if ( self.persistentStoreCoordinator == nil ) {
        self.persistentStoreCoordinator = [[NSPersistentStoreCoordinator alloc] initWithManagedObjectModel:self.managedObjectModel];
    }
    
    NSMutableDictionary *options = [NSMutableDictionary dictionary];
    
    if ( self.storeType == NSSQLiteStoreType ) {
        if ( !RZVAssert(self.storeURL != nil, @"Must have a store URL for SQLite stores") ) {
            return NO;
        }
        NSString *journalMode = [self hasOptionsSet:RZCoreDataStackOptionsDisableWriteAheadLog] ? @"DELETE" : @"WAL";
        options[NSSQLitePragmasOption] = @{@"journal_mode" : journalMode};
    }

    if ( ![self hasOptionsSet:RZCoreDataStackOptionDisableAutoLightweightMigration] && self.storeURL ){
        options[NSMigratePersistentStoresAutomaticallyOption] = @(YES);
        options[NSInferMappingModelAutomaticallyOption] = @(YES);
    }
    
    if( ![self.persistentStoreCoordinator addPersistentStoreWithType:self.storeType
                                                       configuration:self.modelConfiguration
                                                                 URL:self.storeURL
                                                             options:options error:&error] ) {
        
        RZVLogError(@"Error creating/reading persistent store: %@", error);
        
        if ([self hasOptionsSet:RZCoreDataStackOptionDeleteDatabaseIfUnreadable] && self.storeURL ) {
            NSError *removeFileError = nil;
            if ( [[NSFileManager defaultManager] removeItemAtURL:self.storeURL error:&removeFileError] ) {
                [self.persistentStoreCoordinator addPersistentStoreWithType:self.storeType
                                                              configuration:self.modelConfiguration
                                                                        URL:self.storeURL
                                                                    options:options
                                                                      error:&error];
            }
            else {
                error = removeFileError;
            }
        }
        
        if ( error != nil ) {
            @throw [NSException exceptionWithName:NSInternalInconsistencyException
                                           reason:[NSString stringWithFormat:@"Unresolved error creating PSC for data stack: %@", error]
                                         userInfo:nil];
            return NO;
        }
    }
    
    //
    // Create Contexts
    //
    self.topLevelBackgroundContext = [[NSManagedObjectContext alloc] initWithConcurrencyType:NSPrivateQueueConcurrencyType];
    self.topLevelBackgroundContext.persistentStoreCoordinator = self.persistentStoreCoordinator;

    self.mainManagedObjectContext = [[NSManagedObjectContext alloc] initWithConcurrencyType:NSMainQueueConcurrencyType];
    self.mainManagedObjectContext.parentContext = self.topLevelBackgroundContext;
    
    if ([self hasOptionsSet:RZCoreDataStackOptionsCreateUndoManager] ) {
        self.mainManagedObjectContext.undoManager   = [[NSUndoManager alloc] init];
    }
    
    return YES;
}

+ (void)buildDefaultStack
{
    NSString *modelName    = [[NSBundle mainBundle] objectForInfoDictionaryKey:@"RZVDataModelName"];
    if ( modelName == nil ) {
        return;
    }
    
    NSString *configName   = [[NSBundle mainBundle] objectForInfoDictionaryKey:@"RZVDataModelConfiguration"];
    NSString *storeTypeRaw = [[NSBundle mainBundle] objectForInfoDictionaryKey:@"RZVPersistentStoreType"];
    
    NSString *storeType = nil;
    if ( storeTypeRaw ) {
        if ( [storeTypeRaw isEqualToString:@"memory"] ) {
            storeType = NSInMemoryStoreType;
        }
        else if ( [storeTypeRaw isEqualToString:@"sqlite"] ) {
            storeType = NSSQLiteStoreType;
        }
        else {
            storeType = NSInMemoryStoreType;
            NSLog(@"[RZDataStackAccess] WARNING: Unknown store type \"%@\" in info.plist. Defaulting to in-memory store.", storeTypeRaw);
        }
    }
    
    RZCoreDataStack *defaultStack = [[RZCoreDataStack alloc] initWithModelName:modelName
                                                                 configuration:configName
                                                                     storeType:storeType
                                                                      storeURL:nil
                                                                       options:kNilOptions];
    
    if ( defaultStack != nil ) {
        [self setDefaultStack:defaultStack];
    }
    else {
        NSLog(@"[RZDataStackAccess] ERROR: Could not build default CoreData stack from info.plist values. Please check your entries:");
        NSLog(@"Model Name (RZVDataModelName): %@", modelName);
        if ( configName ) {
            NSLog(@"Config Name (RZVDataModelConfiguration): %@", configName);
        }
        if ( storeTypeRaw ) {
            NSLog(@"Persistent Store Type (RZVPersistentStoreType): %@", storeTypeRaw);
        }
    }
}

- (void)registerForNotifications
{
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(handleAppDidEnterBackground:) name:UIApplicationDidEnterBackgroundNotification object:nil];
}

- (void)unregisterForNotifications
{
    [[NSNotificationCenter defaultCenter] removeObserver:self name:UIApplicationDidEnterBackgroundNotification object:nil];
}

- (void)handleAppDidEnterBackground:(NSNotification *)notification
{
    if ( [self hasOptionsSet:RZCoreDataStackOptionsEnableAutoStalePurge] ) {
        
        __block UIBackgroundTaskIdentifier backgroundPurgeTaskID = UIBackgroundTaskInvalid;
        
        [[UIApplication sharedApplication] beginBackgroundTaskWithExpirationHandler:^{
            // ???: Need to clean this task up in any other way?
            [[UIApplication sharedApplication] endBackgroundTask:backgroundPurgeTaskID];
            backgroundPurgeTaskID = UIBackgroundTaskInvalid;
        }];
        
        [self purgeStaleObjectsWithCompletion:^(NSError *err) {
            [[UIApplication sharedApplication] endBackgroundTask:backgroundPurgeTaskID];
            backgroundPurgeTaskID = UIBackgroundTaskInvalid;
        }];
    }
}

@end

@implementation RZCoreDataStack (SharedAccess)

static RZCoreDataStack *s_defaultStack = nil;

+ (RZCoreDataStack *)defaultStack
{
    return s_defaultStack;
}

+ (void)setDefaultStack:(RZCoreDataStack *)defaultStack
{
    s_defaultStack = defaultStack;
}

@end
