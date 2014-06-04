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
 */
@interface RZDataStack : NSObject

/**
 *  Return a new data stack initialized with the provided data model name
 *  and persistent store type.
 *
 *  @param modelName            The name of the Core Data Model. Pass nil to infer default value from application name.
 *  @param modelConfiguration   The name of a configuration from the model to use for this stack.
 *  @param storeType            The type of persistent store to use. Must not be nil.
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

- (NSManagedObjectContext *)temporaryChildContext;

- (void)save:(BOOL)wait;

@end
