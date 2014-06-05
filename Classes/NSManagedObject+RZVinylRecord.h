//
//  NSManagedObject+RZVinylRecord.h
//  RZVinylDemo
//
//  Created by Nick Donaldson on 6/4/14.
//  Copyright (c) 2014 Raizlabs. All rights reserved.
//

@import CoreData;

@class RZCoreDataStack;

@interface NSManagedObject (RZVinylRecord)

//
//  Creation
//

/**
 *  Return an instance of this managed object class with the provided value for its primary key.
 *
 *  @param primaryValue The value of the primary key (e.g. the remoteID)
 *  @param createNew    Pass YES to create a new object if one is not found.
 *
 *  @warning Calling this on a class that does not override @p rzv_primaryKey will always return nil.
 *
 *  @return An existing or new instance of this managed object class with the provided primary key
 *          value, or nil if @p createNew is NO and an existing object was not found.
 */
+ (instancetype)rzv_objectWithPrimaryKeyValue:(id)primaryValue createNew:(BOOL)createNew;
+ (instancetype)rzv_objectWithPrimaryKeyValue:(id)primaryValue createNew:(BOOL)createNew inContext:(NSManagedObjectContext *)context;

//
//  Query/Fetch
//

//+ (NSArray *)rzv_all;
//
//+ (NSArray *)rzv_allSorted:(NSArray *)sortDescriptors;
//
//+ (NSArray *)rzv_allSorted:(NSArray *)sortDescriptors inContext:(NSManagedObjectContext *)context;

+ (NSArray *)rzv_where:(NSString *)predicateQuery;

+ (NSArray *)rzv_where:(NSString *)predicateQuery sort:(NSArray *)sortDescriptors;

+ (NSArray *)rzv_where:(NSString *)predicateQuery sort:(NSArray *)sortDescriptors inContext:(NSManagedObjectContext *)context;

//+ (NSArray *)rzv_wherePredicate:(NSPredicate *)predicate;
//
//+ (NSArray *)rzv_wherePredicate:(NSPredicate *)predicate withSortDescriptors:(NSArray *)sortDescriptors;
//
//+ (NSArray *)rzv_wherePredicate:(NSPredicate *)predicate withSortDescriptors:(NSArray *)sortDescriptors inContext:(NSManagedObjectContext *)context;

////
////  Save/Delete
////
//
//- (BOOL)save;
//
//- (BOOL)delete;

//
//  Metadata
//

+ (NSString *)rzv_entityName;

//
//  Subclassing
//

/**
 *  Overrie in subclasses to provide the keypath to the property uniquely
 *  identifying this object
 *
 *  @return The keypath of the property uniquely identifying this object.
 */
+ (NSString *)rzv_primaryKey;

/**
 *  Override in subclasses to provide a different data stack for use with this
 *  model object class. Defaults to the @p +defaultStack of @p RZDataStackAccess
 *
 *  @return The data stack to use for this model object class.
 */
+ (RZCoreDataStack *)rzv_coreDataStack;

@end
