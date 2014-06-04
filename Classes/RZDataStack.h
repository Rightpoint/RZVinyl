//
//  RZDataStack.h
//  RZVinylDemo
//
//  Created by Nick Donaldson on 6/4/14.
//  Copyright (c) 2014 Raizlabs. All rights reserved.
//

@import CoreData;

typedef NS_OPTIONS(NSUInteger, RZDataStackOptions) {
    
    RZDataStackOptionNoAutoLightweightMigration = (1 >> 0),
    RZDataStackOptionDeleteDatabaseIfUnreadable = (1 >> 1),
    RZDataStackOptionsNoWriteAheadLog           = (1 >> 2),
    RZDataStackOptionsCreateUndoManager         = (1 >> 3)
};

/**
 *  An efficient wrapper for a basic application-level CoreData stack.
 *  Makes use of M. Zarra's parent/child pattern for efficient disk writes.
 *  
 *  @code
 *  [ PSC ]
 *    - [ Private Queue MOC ]
 *       - [ Main Queue MOC ]
 *          - [ Temporary child MOC ] @endcode
 *
 *  @warning To save to the persistent store coordinator, you must use the @p save: method
 *  provided by this class. Saving the main thread's managed object context will not propagate
 *  changes all the way to the psc, which will result in data not being saved to disk.
 */
@interface RZDataStack : NSObject

/**
 *  Return a new data stack initialized with the provided data model name
 *  and persistent store type.
 *
 *  @param modelName            The name of the Core Data Model. Pass nil to infer default value from application name.
 *  @param modelConfiguration   The name of a configuration from the model to use for this stack.
 *  @param storeType            The type of persistent store to use. Pass nil to default to in memory store.
 *  @param storeURL             The URL of the persistent store's database file. If nil, defaults to a .sqlite file with
 *                              the same name as the model, located in the @p Library/ directory.
 *  @param options              Additional options for the stack.
 *
 *  @return A new data stack instance.
 */
- (instancetype)initWithModelName:(NSString *)modelName
                    configuration:(NSString *)modelConfiguration
                        storeType:(NSString *)storeType
                         storeURL:(NSURL *)storeURL
                          options:(RZDataStackOptions)options;


@property (nonatomic, strong, readonly) NSManagedObjectModel            *managedObjectModel;
@property (nonatomic, strong, readonly) NSManagedObjectContext          *managedObjectContext;
@property (nonatomic, strong, readonly) NSPersistentStoreCoordinator    *persistentStoreCoordinator;

/**
 *  Spawn and return a temporary child context with private queue confinement.
 *
 *  @return A newly spawned child context with private queue confinement.
 */
- (NSManagedObjectContext *)temporaryChildContext;

/**
 *  Save the data stack and optionally wait for save to finish.
 *
 *  @param wait Whether to wait to return until the save is finished.
 */
- (void)save:(BOOL)wait;

// TODO: Delete/reset entire database

@end
