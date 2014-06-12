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
 *  Override in subclasses to provide the key name of the property uniquely
 *  identifying this object
 *
 *  @warning It is @b mandatory to return a non-nil value from each @p NSManagedObject subclass
 *           in order to use RZVinyl. Failure to do so will throw a runtime exception when using
 *           the methods in the @p NSManagedObject categories.
 *
 *  @return The key name of the property uniquely identifying this object.
 */
+ (NSString *)rzv_primaryKey;

/**
 *  Override in subclasses to provide a key to use for the primary key when importing
 *  values or updating/creating a new instance from an NSDictionary using NSManagedObject+RZImport.
 *
 *  For example, a JSON response might contain key/value pair "ID" : 1000 for the object's primary key,
 *  but your managed object subclass might store this value as an attribute named "remoteID", hence it is 
 *  necessary to provide both keys separately to enforce unique instances in the database.
 *
 *  @note Failure to override (or returning nil, the default) will cause the value of @p +rzv_primaryKey
 *  to be used for the external key as well.
 *
 *  @return The key in dictionary representations whose value uniquely identifies this object.
 */
+ (NSString *)rzv_externalPrimaryKey;

@end
