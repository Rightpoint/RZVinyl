//
//  NSManagedObject+RZVinyl.h
//  RZVinylDemo
//
//  Created by Nick Donaldson on 6/4/14.
//  Copyright (c) 2014 Raizlabs. All rights reserved.
//

@import CoreData;
#import "RZAutoImportable.h"

@class RZCoreDataStack;

@interface NSManagedObject (RZVinylRecord)

//+ (instancetype)rzv_objectWithPrimaryKey:(id)primaryKey createNew:(BOOL)createNew;

@end

/**
 *  Category that provides two methods to override in subclasses of NSManagedObject for
 *  automatic value importing. Also provides a partial implementation of @p RZAutoImportable
 */
@interface NSManagedObject (RZVinylImport) <RZAutoImportable>

/**
 *  Override in subclasses to provide the property name of the property whose value uniquely
 *  identies an instance of the class. Defaults to @p nil.
 *
 *  @return The primary key in dictionaries being imported for this class.
 */
+ (NSString *)rzv_primaryKeyPropertyName;

/**
 *  Override in subclasses to provide a different data stack for use with this
 *  model object class. Defaults to the @p +defaultStack of @p RZDataStackAccess
 *
 *  @return The data stack to use for this model object class.
 */
+ (RZCoreDataStack *)rzv_coreDataStack;

@end
