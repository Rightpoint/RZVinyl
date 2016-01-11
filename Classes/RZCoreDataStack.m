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

@import UIKit.UIApplication;

#import "RZCoreDataStack.h"
#import "NSManagedObject+RZVinylRecord.h"
#import "NSManagedObjectContext+RZVinylSave.h"
#import "RZVinylDefines.h"
#import <libkern/OSAtomic.h>

static RZCoreDataStack *s_defaultStack = nil;

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

@property (nonatomic, strong) NSHashTable *registeredFetchedResultsControllers;

@end

@implementation RZCoreDataStack

@synthesize entityClassNamesToStalenessPredicates = _entityClassNamesToStalenessPredicates;

+ (RZCoreDataStack *)defaultStack
{
    if ( s_defaultStack == nil ) {
        RZVLogInfo(@"The default stack has been accessed without being configured. Creating a new default stack with the default options.");
        s_defaultStack = [[self alloc] initWithModelName:nil
                                           configuration:nil
                                               storeType:nil
                                                storeURL:nil
                                                 options:kNilOptions];
    }
    return s_defaultStack;
}

+ (void)setDefaultStack:(RZCoreDataStack *)stack
{
    s_defaultStack = stack;
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
        _storeType                  = storeType ?: NSSQLiteStoreType;
        _storeURL                   = storeURL;
        _persistentStoreCoordinator = psc;
        _options                    = options;

        _backgroundContextQueue     = dispatch_queue_create("com.rzvinyl.backgroundContextQueue", DISPATCH_QUEUE_SERIAL);

        _registeredFetchedResultsControllers = [NSHashTable weakObjectsHashTable];

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
        _registeredFetchedResultsControllers = [NSHashTable weakObjectsHashTable];

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
        NSManagedObjectContext *context = [self backgroundManagedObjectContext];
        [context performBlockAndWait:^{
            block(context);
            NSError *err = nil;
            [context rzv_saveToStoreAndWait:&err];
            if ( completion ) {
                dispatch_async(dispatch_get_main_queue(), ^{
                    completion(err);
                });
            }
        }];
        [self unregisterSaveNotificationsForContext:context];
    });
}

- (NSManagedObjectContext *)backgroundManagedObjectContext
{
    NSManagedObjectContext *bgContext = [[NSManagedObjectContext alloc] initWithConcurrencyType:NSPrivateQueueConcurrencyType];
    [[bgContext userInfo] setObject:self forKey:kRZCoreDataStackParentStackKey];
    bgContext.parentContext = self.topLevelBackgroundContext;
    [self registerSaveNotificationsForContext:bgContext];
    return bgContext;
}

- (NSManagedObjectContext *)temporaryManagedObjectContext
{
    NSManagedObjectContext *tempContext = [[NSManagedObjectContext alloc] initWithConcurrencyType:NSMainQueueConcurrencyType];
    [[tempContext userInfo] setObject:self forKey:kRZCoreDataStackParentStackKey];
    tempContext.parentContext = self.mainManagedObjectContext;
    return tempContext;
}

- (void)ensureContextNotificationsForFetchedResultsController:(NSFetchedResultsController *)frc
{
    if ( RZVAssert(frc.managedObjectContext == self.mainManagedObjectContext,
                   @"Can only monitor FRC that attach to the main context") ) {
        [self.registeredFetchedResultsControllers addObject:frc];
    }
}

- (void)purgeStaleObjectsWithCompletion:(void (^)(NSError *))completion
{
    [self performBlockUsingBackgroundContext:^(NSManagedObjectContext *context) {
        
        [self.entityClassNamesToStalenessPredicates enumerateKeysAndObjectsUsingBlock:^(NSString *className, NSPredicate *predicate, BOOL *stop) {
            
            Class moClass = NSClassFromString(className);
            if ( moClass != Nil ) {
                [moClass rzv_deleteAllWhere:predicate inContext:context];
            }
            
        }];
        
    } completion:^(NSError *err) {
        
        if (completion) {
            completion(err);
        }
        
    }];
}

#pragma mark - Lazy Default Properties

- (NSString *)modelName
{
    if ( _modelName == nil ) {
        // Fall back on CFBundleName if CFBundleDisplayName is not included in info.plist
        NSMutableString *productName = [[[NSBundle mainBundle] objectForInfoDictionaryKey:@"CFBundleDisplayName"] mutableCopy] ?: [[[NSBundle mainBundle] objectForInfoDictionaryKey:@"CFBundleName"] mutableCopy];
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
    rzv_performBlockAtomically(YES, ^{
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

- (BOOL)hasSamePersistentStoreCoordinator:(NSManagedObjectContext *)context
{
    NSManagedObjectContext *topContext = context;
    while (topContext.parentContext != nil) {
        topContext = topContext.parentContext;
    }
    return topContext.persistentStoreCoordinator == self.persistentStoreCoordinator;
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
        // we look for both mom and momd versions, we could have used [NSManagedObjectModel mergedModelFromBundles:nil] but it does more than we want
        NSURL* url = [[NSBundle mainBundle] URLForResource:self.modelName withExtension:@"momd"];
        if ( url == nil ) {
            url = [[NSBundle mainBundle] URLForResource:self.modelName withExtension:@"mom"];
        }
        if ( url == nil ) {
            RZVLogError(@"Could find resource %@.momd OR %@.mom", self.modelName, self.modelName);
            return NO;
        }

        self.managedObjectModel = [[NSManagedObjectModel alloc] initWithContentsOfURL:url];
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
        
        if ( [self hasOptionsSet:RZCoreDataStackOptionDeleteDatabaseIfUnreadable] && self.storeURL ) {
            
            // Reset the error before we reuse it
            error = nil;
            
            if ( [[NSFileManager defaultManager] removeItemAtURL:self.storeURL error:&error] ) {
                
                [self.persistentStoreCoordinator addPersistentStoreWithType:self.storeType
                                                              configuration:self.modelConfiguration
                                                                        URL:self.storeURL
                                                                    options:options
                                                                      error:&error];
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
    if ( [self hasOptionsSet:RZCoreDataStackOptionsDisableTopLevelContext] ) {
        self.mainManagedObjectContext = [[NSManagedObjectContext alloc] initWithConcurrencyType:NSMainQueueConcurrencyType];
        self.mainManagedObjectContext.persistentStoreCoordinator = self.persistentStoreCoordinator;
    }
    else {
        self.topLevelBackgroundContext = [[NSManagedObjectContext alloc] initWithConcurrencyType:NSPrivateQueueConcurrencyType];
        self.topLevelBackgroundContext.persistentStoreCoordinator = self.persistentStoreCoordinator;

        self.mainManagedObjectContext = [[NSManagedObjectContext alloc] initWithConcurrencyType:NSMainQueueConcurrencyType];
        self.mainManagedObjectContext.parentContext = self.topLevelBackgroundContext;
    }
    return YES;
}

#pragma mark - Notifications

- (void)registerForNotifications
{
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(handleAppDidEnterBackground:) name:UIApplicationDidEnterBackgroundNotification object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(handleContextWillSave:) name:NSManagedObjectContextWillSaveNotification object:self.mainManagedObjectContext];
}

- (void)unregisterForNotifications
{
    [[NSNotificationCenter defaultCenter] removeObserver:self name:UIApplicationDidEnterBackgroundNotification object:nil];
    [[NSNotificationCenter defaultCenter] removeObserver:self name:NSManagedObjectContextWillSaveNotification object:self.mainManagedObjectContext];
}

- (void)registerSaveNotificationsForContext:(NSManagedObjectContext *)context
{
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(handleContextWillSave:) name:NSManagedObjectContextWillSaveNotification object:context];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(handleContextDidSave:) name:NSManagedObjectContextDidSaveNotification object:context];
}

- (void)unregisterSaveNotificationsForContext:(NSManagedObjectContext *)context
{
    [[NSNotificationCenter defaultCenter] removeObserver:self name:NSManagedObjectContextWillSaveNotification object:context];
    [[NSNotificationCenter defaultCenter] removeObserver:self name:NSManagedObjectContextDidSaveNotification object:context];
}

- (void)handleAppDidEnterBackground:(NSNotification *)notification
{
    if ( [self hasOptionsSet:RZCoreDataStackOptionsEnableAutoStalePurge] ) {
        
        __block UIBackgroundTaskIdentifier backgroundPurgeTaskID = UIBackgroundTaskInvalid;
        
        backgroundPurgeTaskID = [[UIApplication sharedApplication] beginBackgroundTaskWithExpirationHandler:^{
            [[UIApplication sharedApplication] endBackgroundTask:backgroundPurgeTaskID];
            backgroundPurgeTaskID = UIBackgroundTaskInvalid;
        }];
        
        [self purgeStaleObjectsWithCompletion:^(NSError *err) {
            [[UIApplication sharedApplication] endBackgroundTask:backgroundPurgeTaskID];
            backgroundPurgeTaskID = UIBackgroundTaskInvalid;
        }];
    }
}

- (void)handleContextWillSave:(NSNotification *)notification
{
    NSManagedObjectContext *context = [notification object];
    if (![self hasSamePersistentStoreCoordinator:context]) {
        return;
    }

    NSArray *insertedObjects = [[context insertedObjects] allObjects];
    if ( insertedObjects.count > 0 ) {
        NSError *err = nil;
        if ( ![context obtainPermanentIDsForObjects:insertedObjects error:&err] ) {
            RZVLogError(@"Error obtaining permanent ID's for inserted objects before save: %@", err);
        }
    }
}

- (void)handleContextDidSave:(NSNotification *)notification
{
    NSManagedObjectContext *context = [notification object];
    if (![self hasSamePersistentStoreCoordinator:context]) {
        return;
    }

    NSArray *objectsToFault = nil;
    if ( self.registeredFetchedResultsControllers.count > 0 ) {
        // If we registered a FRC to fault, build the predicate on the main object context thread to
        // ensure thread safety.
        NSMutableArray *predicates = [NSMutableArray array];
        [self.mainManagedObjectContext performBlockAndWait:^{
            for ( NSFetchedResultsController *frc in [self.registeredFetchedResultsControllers allObjects] ) {
                NSEntityDescription *entityDescription = frc.fetchRequest.entity;
                NSPredicate *predicate = frc.fetchRequest.predicate;
                if ( predicate ) {
                    [predicates addObject:[NSPredicate predicateWithBlock:^BOOL(NSManagedObject *mo, NSDictionary *bindings) {
                        return ([[mo entity] isEqual:entityDescription] && [predicate evaluateWithObject:mo]);
                    }]];
                }
            }
        }];
        // If there are any predicates, build a list of objects to fault into the main context
        // prior to the merge.
        if ( [predicates count] > 0 ) {
            NSPredicate *anyMatch = [NSCompoundPredicate orPredicateWithSubpredicates:predicates];
            NSSet *updatedObjects = [[notification userInfo] objectForKey:NSUpdatedObjectsKey];
            objectsToFault = [[updatedObjects allObjects] filteredArrayUsingPredicate:anyMatch];
        }
    }

    [self.mainManagedObjectContext performBlockAndWait:^{
        for ( NSManagedObject *mo in objectsToFault ) {
            NSManagedObject *mainMo = [self.mainManagedObjectContext objectWithID:[mo objectID]];
            [mainMo willAccessValueForKey:nil];
        }

        [self.mainManagedObjectContext mergeChangesFromContextDidSaveNotification:notification];
    }];
}

@end

//=====================
//  FOR TESTING ONLY
//=====================

// This is reserved for background compatibility.   You can just call [RZCoreDataStack setDefaultStack:nil].
void __rzv_resetDefaultStack()
{
    s_defaultStack = nil;
}
