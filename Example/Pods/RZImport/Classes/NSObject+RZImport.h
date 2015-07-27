//
//  NSObject+RZImport.h
//  RZImport
//
//  Created by Nick Donaldson on 5/21/14.
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
//  MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND
//  NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT HOLDERS BE
//  LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER IN AN ACTION
//  OF CONTRACT, TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN CONNECTION
//  WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE.


@import Foundation;
#import "RZImportable.h"

/**
 *  Automatically map key/value pairs from dictionary to properties
 *  on an object instance. Handles correct type conversion when possible.
 *  
 *  This category is useful when deserializing model objects from webservice
 *  JSON responses, plists, or anything else that can be deserialized into a
 *  dictionary or array.
 *
 *  Automatic mapping will occur between keys and properties that are a case-insensitive
 *  string match, regardless of underscores. For example, a property named "lastName" will
 *  match any of the following keys in a provided dictionary:
 *  
 *  @code 
 *  @"lastName"
 *  @"lastname" 
 *  @"last_name" 
 *  @endcode
 *
 *  Optionally implement @p RZImportable on the object class to manage
 *  object uniqueness, relationships, and other configuration options.
 *
 *  Inferred mappings are cached for performance when repeatedly importing the
 *  same type of object. If performance is a major concern, you can always implement
 *  the RZImportable protocol and provide a pre-defined mapping.
 */
@interface NSObject (RZImport)

/**
 *  Return an instance of the calling class initialized with the values in the dictionary.
 *
 *  If the calling class implements RZImportable, it is given the opportunity
 *  to return an existing unique instance of the object that is represented by
 *  the dictionary.
 *
 *  @param dict Dictionary from which to create the object instance.
 *
 *  @return An object instance initialized with the values in the dictionary.
 */
+ (instancetype)rzi_objectFromDictionary:(NSDictionary *)dict;

/**
 *  Return an instance of the calling class initialized with the values in the dictionary,
 *  with optional extra key/property mappings.
 *
 *  If the calling class implements RZImportable, it is given the opportunity
 *  to return an existing unique instance of the object that is represented by
 *  the dictionary.
 *
 *  @param dict     Dictionary from which to create the object instance.
 *  @param mappings An optional dictionary of extra mappings from keys to property names to
 *                  use in the import. These will override/supplement implicit mappings and mappings
 *                  provided by @p RZImportable.
 *
 *  @return An object instance initialized with the values in the dictionary.
 */
+ (instancetype)rzi_objectFromDictionary:(NSDictionary *)dict withMappings:(NSDictionary *)mappings;

/**
 *  Return an array of instances of the calling class initialized with the
 *  values in the dicitonaries in the provided array.
 *
 *  The array parameter should contain only @p NSDictionary instances.
 *
 *  If the calling class implements RZImportable, it is given the opportunity
 *  to return an existing unique instance of an object that is represented by
 *  each dictionary.
 *
 *  @param array An array of @p NSDictionary instances objects to import.
 *
 *  @return An array of objects initiailized with the respective values in each dictionary in the array.
 */
+ (NSArray *)rzi_objectsFromArray:(NSArray *)array;

/**
 *  Return an array of instances of the calling class initialized with the
 *  values in the dicitonaries in the provided array, with optional extra key/property mappings.
 *
 *  The array parameter should contain only @p NSDictionary instances.
 *
 *  If the calling class implements RZImportable, it is given the opportunity
 *  to return an existing unique instance of an object that is represented by
 *  each dictionary.
 *
 *  @param array    An array of @p NSDictionary instances objects to import.
 *  @param mappings An optional dictionary of extra mappings from keys to property names to
 *                  use in the import. These will override/supplement implicit mappings and mappings
 *                  provided by @p RZImportable.
 *
 *  @return An array of objects initiailized with the respective values in each dictionary in the array.
 */
+ (NSArray *)rzi_objectsFromArray:(NSArray *)array withMappings:(NSDictionary *)mappings;
 
/**
 *  Import the values from the provided dictionary into this object.
 *  Uses the implicit key/property mapping and the optional mapping overrides
 *  provided by RZImportable.
 *
 *  @param dict Dictionary of values to import.
 */
- (void)rzi_importValuesFromDict:(NSDictionary *)dict;

/**
 *  Import the values from the provided dictionary into this object with optional extra
 *  key/property mappings.
 *
 *  @param dict     Dictionary of values to import.
 *  @param mappings An optional dictionary of extra mappings from keys to property names to
 *                  use in the import. These will override/supplement implicit mappings and mappings
 *                  provided by @p RZImportable.
 */
- (void)rzi_importValuesFromDict:(NSDictionary *)dict withMappings:(NSDictionary *)mappings;

@end

