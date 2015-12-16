//
//  NSManagedobject+RZvinylRecord_private.h
//  RZVinyl
//
//  Created by Nick Donaldson on 6/5/14.
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

/**
 *  This header contains private method prototypes for NSManagedObject+RZVinylRecord
 *  These are NOT intended for public usage.
 */
@import CoreData;

@class RZCoreDataStack;

@interface NSManagedObject ()

/**
 *  Asserts that a subclass implements +rzv_coreDataStack and returns the value.
 */
+ (RZCoreDataStack *)rzv_validCoreDataStack;

/**
 *  Always call this instead of @p rzv_coreDataStack.
 *  Checks whether the subclass responds to @p rzv_coreDataStack before calling it.
 *
 *  @return The staleness predicate provided by the subclass implementing @p rzv_coreDataStack else @p [RZCoreDataStack defaultStack]
 */
+ (RZCoreDataStack *)rzv_safe_coreDataStack;

/**
 *  Always call this instead of @p rzv_primaryKey.
 *  Checks whether the subclass responds to @p rzv_primaryKey before calling it.
 *
 *  @return The staleness predicate provided by the subclass implementing @p rzv_primaryKey else @p nil
 */
+ (NSString *)rzv_safe_primaryKey;

/**
 *  Always call this instead of @p rzv_stalenessPredicate.
 *  Checks whether the subclass responds to @p rzv_stalenessPredicate before calling it.
 *
 *  @return The staleness predicate provided by the subclass implementing @p rzv_stalenessPredicate else @p nil
 */
+ (NSPredicate *)rzv_safe_stalenessPredicate;

@end