//
//  RZDataStack.m
//  RZVinylDemo
//
//  Created by Nick Donaldson on 6/4/14.
//  Copyright (c) 2014 Raizlabs. All rights reserved.
//

#import "RZDataStack.h"

#define RZDSAssertReturn(cond, msg, ...) \
    NSAssert(cond, msg, ##__VA_ARGS__); \
    if ( !(cond) ) { \
        return; \
    }

#define RZDSAssertReturnNO(cond, msg, ...) \
    NSAssert(cond, msg, ##__VA_ARGS__); \
    if ( !(cond) ) { \
        return NO; \
    }

#define RZDSLogError(msg, ...) \
    NSLog((@"[RZDataStack]: ERROR -- " msg), ##__VA_ARGS__);

@interface RZDataStack ()

@property (nonatomic, strong, readwrite) NSManagedObjectModel            *managedObjectModel;
@property (nonatomic, strong, readwrite) NSManagedObjectContext          *managedObjectContext;
@property (nonatomic, strong, readwrite) NSPersistentStoreCoordinator    *persistentStoreCoordinator;

@property (nonatomic, strong) NSManagedObjectContext *topLevelBackgroundContext;

@property (nonatomic, copy) NSString *modelName;
@property (nonatomic, copy) NSString *modelConfiguration;
@property (nonatomic, copy) NSString *storeType;
@property (nonatomic, copy) NSURL    *storeURL;

@property (nonatomic, assign) RZDataStackOptions options;

@end

@implementation RZDataStack

+ (void)load
{
    [self buildDefaultStack];
}

- (id)init
{
    return [self initWithModelName:nil configuration:nil storeType:nil storeURL:nil options:kNilOptions];
}

- (instancetype)initWithModelName:(NSString *)modelName configuration:(NSString *)modelConfiguration storeType:(NSString *)storeType storeURL:(NSURL *)storeURL options:(RZDataStackOptions)options
{
    self = [super init];
    if ( self ) {
        _modelName          = modelName;
        _modelConfiguration = modelConfiguration;
        _storeType          = storeType ?: NSInMemoryStoreType;
        _storeURL           = storeURL;
        _options            = options;
        
        if ( ![self buildStack] ) {
            return nil;
        }
    }
    return self;
}

#pragma mark - Public

- (NSManagedObjectContext *)temporaryChildContext
{
    NSManagedObjectContext *tempChild = [[NSManagedObjectContext alloc] initWithConcurrencyType:NSPrivateQueueConcurrencyType];
    tempChild.parentContext = self.managedObjectContext;
    return tempChild;
}

- (void)save:(BOOL)wait
{
    __block NSError *err = nil;
    
    void (^DiskSave)() = ^{
        if ( wait ) {
            [self.topLevelBackgroundContext performBlockAndWait:^{
                [self.topLevelBackgroundContext save:&err];
            }];
        }
        else {
            [self.topLevelBackgroundContext performBlock:^{
                [self.topLevelBackgroundContext save:&err];
            }];
        }
    };
    
    if ( wait ) {
        [self.managedObjectContext performBlockAndWait:^{
            if ( [self.managedObjectContext save:&err] ) {
                DiskSave();
            }
        }];
    }
    else {
        [self.managedObjectContext performBlock:^{
            if ( [self.managedObjectContext save:&err] ) {
                DiskSave();
            }
        }];
    }

    if ( err ) {
        RZDSLogError(@"Error saving database: %@", err);
    }
}

#pragma mark - Lazy Default Properties

- (NSString *)modelName
{
    if ( _modelName == nil ) {
        NSMutableString *productName = [[[NSBundle bundleForClass:[self class]] objectForInfoDictionaryKey:@"CFBundleDisplayName"] mutableCopy];
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

#pragma mark - Private

- (BOOL)hasOptionsSet:(RZDataStackOptions)options
{
    return ( ( self.options | options ) == options );
}

- (BOOL)buildStack
{
    RZDSAssertReturnNO(self.modelName != nil, @"Must have a model name");
    
    //
    // Create model
    //
    self.managedObjectModel = [[NSManagedObjectModel alloc] initWithContentsOfURL:[[NSBundle bundleForClass:[self class]] URLForResource:self.modelName withExtension:@"momd"]];
    if ( self.managedObjectModel == nil ) {
        RZDSLogError(@"Could not create managed object model for name %@", self.modelName);
        return NO;
    }
    
    //
    // Create PSC
    //
    NSMutableDictionary *options = [NSMutableDictionary dictionary];
    
    if ( self.storeType == NSSQLiteStoreType ) {
        RZDSAssertReturnNO(self.storeURL != nil, @"Must have a store URL for SQLite stores");
        NSString *journalMode = [self hasOptionsSet:RZDataStackOptionsNoWriteAheadLog] ? @"DELETE" : @"WAL";
        options[NSSQLitePragmasOption] = @{@"journal_mode" : journalMode};
    }

    NSError *error = nil;
    self.persistentStoreCoordinator = [[NSPersistentStoreCoordinator alloc] initWithManagedObjectModel:self.managedObjectModel];
    
    if ( ![self hasOptionsSet:RZDataStackOptionNoAutoLightweightMigration] && self.storeURL ){
        options[NSMigratePersistentStoresAutomaticallyOption] = @(YES);
        options[NSInferMappingModelAutomaticallyOption] = @(YES);
    }
    
    if( ![self.persistentStoreCoordinator addPersistentStoreWithType:self.storeType
                                                       configuration:self.modelConfiguration
                                                                 URL:self.storeURL
                                                             options:options error:&error] ) {
        
        RZDSLogError(@"Error creating/reading persistent store: %@", error);
        
        if ( [self hasOptionsSet:RZDataStackOptionDeleteDatabaseIfUnreadable] && self.storeURL ) {
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
            RZDSLogError(@"Unresolved error creating PSC for data stack: %@", error);
            return NO;
        }
    }
    
    //
    // Create Contexts
    //
    self.topLevelBackgroundContext = [[NSManagedObjectContext alloc] initWithConcurrencyType:NSPrivateQueueConcurrencyType];
    self.topLevelBackgroundContext.persistentStoreCoordinator = self.persistentStoreCoordinator;

    self.managedObjectContext = [[NSManagedObjectContext alloc] initWithConcurrencyType:NSMainQueueConcurrencyType];
    self.managedObjectContext.parentContext = self.topLevelBackgroundContext;
    
    if ( [self hasOptionsSet:RZDataStackOptionsCreateUndoManager] ) {
        self.managedObjectContext.undoManager   = [[NSUndoManager alloc] init];
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
    
    RZDataStack *defaultStack = [[RZDataStack alloc] initWithModelName:modelName
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

@end

@implementation RZDataStack (SharedAccess)

static RZDataStack *s_defaultStack = nil;

+ (RZDataStack *)defaultStack
{
    return s_defaultStack;
}

+ (void)setDefaultStack:(RZDataStack *)defaultStack
{
    s_defaultStack = defaultStack;
}

@end
