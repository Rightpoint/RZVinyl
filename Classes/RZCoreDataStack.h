//
//  RZCoreDataStack.h
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


@import CoreData;

typedef void (^RZCoreDataStackTransactionBlock)(NSManagedObjectContext* _Nonnull context);

typedef NS_OPTIONS(NSUInteger, RZCoreDataStackOptions)
{
    /**
     *  Pass this option to disable automatic lightweight migration between data model versions.
     *  If this option is set and migration fails, the initialization will either fail and return nil,
     *  or the file will be deleted, depending on whether @p RZCoreDataStackOptionDeleteDatabaseIfUnreadable is
     *  also passed to init.
     */
    RZCoreDataStackOptionDisableAutoLightweightMigration = (1 << 0),
    
    /**
     *  Pass this option to delete the database file if it is not readable using the provided model.
     *  If this option is not set and the file is unreadable, the initialization will fail and an exception will be thrown.
     */
    RZCoreDataStackOptionDeleteDatabaseIfUnreadable = (1 << 1),
    
    /**
     *  Pass this option to disable the write-ahead log for sqlite databases.
     *  If the database is not sqlite, this will be ignored.
     */
    RZCoreDataStackOptionsDisableWriteAheadLog = (1 << 2),
    
    /**
     *  Pass this option to automatically purge stale objects from the main MOC when backgrounding the app.
     *  @see @p purgeStaleObjectsWithCompletion
     */
    RZCoreDataStackOptionsEnableAutoStalePurge = (1 << 3)
};

/**
 *  An efficient wrapper for a basic application-level Core Data stack.
 *  Makes use of M. Zarra's private writer pattern for efficient disk writes.
 *  
 *  @code
 *               [ PSC ]
 *                  |
 *        [ Private Queue MOC ]
 *            |           |
 *  [ Main Queue MOC ]  [ Background MOC(s) ]
 *            |
 *  [ Temporary MOC(s) ]@endcode
 *
 *  @warning To save to the persistent store coordinator, you must use one of the category methods in
 *  @p NSManagedObjectContext+RZVinylSave. Saving the main thread's managed object context will not propagate
 *  changes all the way to the psc, which, when using a disk-backed store, will result in data not being saved to disk.
 */
@interface RZCoreDataStack : NSObject

/**
 *  The default Core Data stack for this application.
 *  An application can have more than one isntance of @p RZCoreDataStack,
 *  but the instance returned here will be used by default for all of the methods 
 *  in @p NSManagedObject+RZVinylRecord that don't take a context argument.
 *
 *  @warning On first access, if the default stack has not been set, this will return a new instance 
 *           with all the default options, using an inferred model name. To override this behavior, 
 *           call @p +setDefaultStack early in the application lifecyle, before any other accesses are 
 *           made to the default stack.
 *
 *  @return The default @p RZCoreDataStack for this application.
 */
+ (RZCoreDataStack* _Nonnull)defaultStack;

/**
 *  Set the default Core Data stack for this application.
 *  It is recommended to call this method as early as possible in the application lifecycle.
 *
 *  @warning Once the default stack has been set, it cannot be changed. Attempting to set it again
 *           will throw a runtime exception.
 *
 *  @param stack The stack to use as the new default stack. Must not be nil.
 */
+ (void)setDefaultStack:(RZCoreDataStack* _Nonnull)stack;

/**
 *  Return a new data stack initialized with the provided data model name
 *  and persistent store type.
 *
 *  @param modelName            The name of the Core Data Model. Pass nil to infer default value from application name.
 *  @param modelConfiguration   The name of a configuration from the model to use for this stack.
 *  @param storeType            The type of persistent store to use. Pass nil to default to sqlite store.
 *  @param storeURL             The URL of the persistent store's database file. If nil, defaults to a .sqlite file with
 *                              the same name as the model, located in the @p Library/ directory.
 *  @param options              Additional options for the stack.
 *
 *  @return A new data stack instance.
 */
- (instancetype _Nullable)initWithModelName:(NSString* _Nullable)modelName
                              configuration:(NSString* _Nullable)modelConfiguration
                                  storeType:(NSString* _Nullable)storeType
                                   storeURL:(NSURL* _Nullable)storeURL
                                    options:(RZCoreDataStackOptions)options;

/**
 *  Return a new data stack initialized with the provided data model name
 *  and persistent store type.
 *
 *  @param modelName            The name of the Core Data Model. Pass nil to infer default value from application name.
 *  @param modelConfiguration   The name of a configuration from the model to use for this stack.
 *  @param storeType            The type of persistent store to use. Pass nil to default to sqlite store.
 *  @param storeURL             The URL of the persistent store's database file. If nil, defaults to a .sqlite file with
 *                              the same name as the model, located in the @p Library/ directory.
 *  @param psc                  An existing persistent store coordinator to use in this stack. Pass nil to create a new one.
 *  @param options              Additional options for the stack.
 *
 *  @return A new data stack instance.
 */
- (instancetype _Nullable)initWithModelName:(NSString* _Nullable)modelName
                              configuration:(NSString* _Nullable)modelConfiguration
                                  storeType:(NSString* _Nullable)storeType
                                   storeURL:(NSURL* _Nullable)storeURL
                 persistentStoreCoordinator:(NSPersistentStoreCoordinator* _Nullable)psc
                                    options:(RZCoreDataStackOptions)options;

/**
 *  Return a new data stack initialized with a preexisting data model and persistent store coordinator.
 *  The managed object context(s) will be created automatically and a new store will be added to the PSC.
 *
 *  @param model        A configured data model. Must not be nil.
 *  @param storeType    The type of persistent store to use. Pass nil to default to sqlite store.
 *  @param storeURL     The URL of the persistent store's database file. If nil, defaults to a .sqlite file with
 *                      the same name as the model, located in the @p Library/ directory.
 *  @param psc          An existing persistent store coordinator to use in this stack. Pass nil to create a new one.
 *  @param options      Additional options for the stack.
 *
 *  @return A new data stack instance.
 */
- (instancetype _Nullable)initWithModel:(NSManagedObjectModel* _Nonnull)model
                              storeType:(NSString* _Nullable)storeType
                               storeURL:(NSURL* _Nullable)storeURL
             persistentStoreCoordinator:(NSPersistentStoreCoordinator* _Nullable)psc
                                options:(RZCoreDataStackOptions)options;


/**
 *  The main queue's managed object context for this Core Data stack.
 *  All classes observing context notifications or managed objects driving UI should use this context.
 *
 *  @warning Obviously, you must manipulate this context and its objects from the main thread,
 *           or by using one of the +p performBlock methods.
 */
@property (strong, nonatomic, nonnull, readonly) NSManagedObjectContext *mainManagedObjectContext;

/**
 *  The managed object model used in this Core Data stack.
 */
@property (strong, nonatomic, nonnull, readonly) NSManagedObjectModel *managedObjectModel;

/**
 *  The persistent store coordinator used in this Core Data stack.
 */
@property (strong, nonatomic, nonnull, readonly) NSPersistentStoreCoordinator *persistentStoreCoordinator;

/**
 *  Asynchronously perform a database operation on a temporary background managed object context.
 *  The context will be saved when the operation is finished, and all changes merged into the main context.
 *
 *  @param block      The block to perform.
 *  @param completion An optional completion block that is called on the main thread after the operation finishes.
 *                    If there was an error saving the background context, it will be passed here.
 *
 *  @note Blocks sent to this method will be enqueued on a serial queue until other pending blocks finish, to prevent 
 *        parallel background contexts from being spawned. This is useful for preventing duplicate objects resulting from
 *        concurrent imports on different contexts. To prevent longer-lasting background tasks from holding up the queue, 
 *        use @p -backgroundManagedObjectContext, but be mindful of potential duplicate objects or merge issues.
 *
 *  @note When the block completes, the context hierarchy will be saved from the background context all the way up to the PSC.
 *
 *  @warning When using this method, you must pass the context given to the block to to the methods in
 *           @p NSManagedObject+VinylRecord.h. Failure to do so will cause all transactions to happen on the main context.
 *
 */
- (void)performBlockUsingBackgroundContext:(RZCoreDataStackTransactionBlock _Nonnull)block
                                completion:(void(^ _Nullable)(NSError* _Nullable err))completion;

/**
 *  Creates, initializes, and returns a new managed object context with private queue confinement,
 *  which is a sibling of the main managed object context. This can be used for longer, concurrent
 *  background imports or other operations to prevent blocking the main thread. Upon saving this
 *  context, changes will be automatically merged into the main context.
 *
 *  @note You must use @p performBlock: to manipulate the returned context.
 *
 *  @warning Since this context is a sibling of the main context, be mindful of the merge policy when saving it.
 *
 *  @return A new background managed object context with private queue confinement.
 */
- (NSManagedObjectContext* _Nonnull)backgroundManagedObjectContext;

/**
 *  Creates, initializes, and returns a new managed object context with main queue confinement,
 *  which is a child of the main managed object context. This can be used as a "sandbox" of sorts,
 *  for making changes to objects on the main queue with the option of later discarding the changes.
 *
 *  @note You must manipulate the returned context and its objects on the main thread.
 *
 *  @return A new temporary managed object context with private queue confinement.
 */
- (NSManagedObjectContext* _Nonnull)temporaryManagedObjectContext;

/**
 *  Performs a serialzed background purge of all stale objects in the persistent store.
 *  Staleness for each entity type is determined by the predicate returned by 
 *  @p rzv_stalenessPredicate in an @p NSManagedObject subclass.
 *
 *  @param completion Optional completion block.
 *
 *  @note   Calling this method will save to the persistent store, so any other unsaved
 *          changes in the main managed object context will also be saved.
 *
 *  @warning This may invalidate existing managed object instances if the objects they represent
 *           are deleted. Subscribe to @p NSManagedObjectContextObjectsDidChange and check for object
 *           deletion in the main context.
 *
 *  @see @p RZCoreDataStackOptionsEnableAutoStalePurge option.
 */
- (void)purgeStaleObjectsWithCompletion:(void(^ _Nullable)(NSError* _Nullable err))completion;

@end
