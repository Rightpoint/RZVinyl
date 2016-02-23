//
//  NSManagedObject+RZImportableSubclass.h
//  RZVinyl
//
//  Created by Nick Donaldson on 6/6/14.
//
//  Copyright 2014 Raizlabs and other contributors
//  http://raizlabs.com/
//
//  Permission is hereby granted, free of charge, to any person obtaining
//  a copy of this software and associated documentation files (the
//  "Software"), to deal in the Software without restriction, including
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
//  MERCHANTABILITY, F  ITNESS FOR A PARTICULAR PURPOSE AND
//  NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT HOLDERS BE
//  LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER IN AN ACTION
//  OF CONTRACT, TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN CONNECTION
//  WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE.

#import "RZCoreDataStack.h"

/**
 *  Methods to optionally override in @p NSManagedObject subclasses to support @p RZImport extensions.
 */
@interface NSManagedObject (RZImportableSubclass)

/**
 *  Override in subclasses to provide a key to use for the primary key when importing
 *  values or updating/creating a new instance from an NSDictionary using NSManagedObject+RZImport.
 *
 *  For example, a JSON response might contain key/value pair "ID" : 1000 for the object's primary key,
 *  but your managed object subclass might store this value as an attribute named "remoteID", hence it is 
 *  necessary to provide both keys separately to enforce unique instances in the database.
 *
 *  @note This will return the value of @c +rzv_primaryKey if it is this method is not overridden.
 *
 *  @return The key in dictionary representations whose value uniquely identifies this object.
 */
+ (NSString *)rzv_externalPrimaryKey;


/**
 *  Override and return @c YES to always create new instances of this object's entity type upon import.
 *  If @c YES is returned, @c +rzv_primaryKey and @c +rzv_externalPrimaryKey will be completely ignored and no
 *  attempt will be made to find and update existing objects matching the dictionary being imported.
 *
 *  @return @c YES to always create new instances on import. Default is @c NO.
 */
+ (BOOL)rzv_shouldAlwaysCreateNewObjectOnImport;

/** 
 *  When caching managed objects, the cache will be built for the keys specified. By default `rzv_externalPrimaryKey`
 *  is returned. Subclasses can add cache lookups for other keys by overriding this method and returning the keys.
 *  This is useful when a different key is used elsewhere in your object graph for associations.
 *
 *  @return An array of external keys to build the cache with.
 */
+ (NSArray *)rzv_externalCacheKeys;

@end
