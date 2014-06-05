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

@interface NSManagedObject (RZVinyl) <RZAutoImportable>

/**
 *  Override in subclasses to provide the primary key whose value uniquely
 *  identies an instance of the class. Defaults to @p nil.
 *
 *  @return The primary key in dictionaries being imported for this class.
 */
+ (NSString *)rzv_primaryKey;

/**
 *  Override in subclasses to provide a different data stack for use with this
 *  model object class. Defaults to the @p +defaultStack of @p RZDataStackAccess
 *
 *  @return The data stack to use for this model object class.
 */
+ (RZCoreDataStack *)rzv_dataStack;

@end
