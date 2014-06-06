//
//  NSManagedObject+RZVinylSubclass.h
//  RZVinylDemo
//
//  Created by Nick Donaldson on 6/6/14.
//  Copyright (c) 2014 Raizlabs. All rights reserved.
//

#import "RZCoreDataStack.h"

/**
 *  Methods to override in @p NSManagedObject subclasses to support @p RZVinylRecord extensions.
 */
@interface NSManagedObject (RZVinylSubclass)

/**
 *  Override in subclasses to provide the keypath to the property uniquely
 *  identifying this object
 *
 *  @return The keypath of the property uniquely identifying this object.
 */
+ (NSString *)rzv_primaryKey;

/**
 *  Override in subclasses to provide a different data stack for use with this
 *  model object class. Defaults to @p +[RZDataStack defaultStack]
 *
 *  @return The data stack to use for this model object class.
 */
+ (RZCoreDataStack *)rzv_coreDataStack;

@end
