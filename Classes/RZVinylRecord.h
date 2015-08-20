//
//  RZVinylRecord.h
//  Pods
//
//  Created by Connor Smith on 2/5/15.
//
//  Copyright 2015 Raizlabs and other contributors
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

#import "RZCompatibility.h"

/**
 *  Methods to optionally implement in @p NSManagedObject subclasses
 */
@protocol RZVinylRecord <NSObject>

@optional

/**
 *  Implement in @p NSManagedObject subclasses to provide a different data stack for use with this
 *  model object class. Defaults to @p +[RZDataStack defaultStack]
 *
 *  @return The data stack to use for this model object class.
 */
+ (RZCoreDataStack* RZNonnull)rzv_coreDataStack;

/**
 *  Implement in @p NSManagedObject subclasses to provide the key name of the property uniquely
 *  identifying this object
 *
 *  @warning If you do not implement this method to return a valid key, attempting to use @c +rzv_objectWithPrimaryKeyValue:
 *           will throw a runtime exception.
 *
 *  @return The key name of the property uniquely identifying this object.
 */
+ (NSString* RZNonnull)rzv_primaryKey;

/**
 *  Implement in @p NSManagedObject subclasses to return a predicate to be used when purging stale objects from the persistent store.
 *  Returns nil (no objects considered stale) by default.
 *
 *  @return A predicate to use with @p RZCoreDataStack's @p -purgeStaleObjects
 */
+ (NSPredicate* RZNullable)rzv_stalenessPredicate;

@end
