//
//  NSManagedObject+RZImport.h
//  RZVinyl
//
//  Created by Nick Donaldson on 6/5/14.
//
//  Copyright 2014 Raizlabs and other contributors
//  http://raizlabs.com/
//
//  Permission is hereby granted, free of charge, to any person obtaining
//  a copy of this software and associated documentation files (the
//  Software"), to deal in the Software without restriction, including
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
#pragma clang diagnostic push
#pragma clang diagnostic ignored "-Wauto-import"

#import <RZImport/NSObject+RZImport.h>

#pragma clang diagnostic pop


/**
 *  Automatic importing of dictionary representations (e.g. deserialized JSON response) 
 *  of an object to CoreData, using RZVinyl and RZImport. Provides a partial implementation
 *  of @c RZImportable.
 *
 *  @warning Do not override the extended methods or their equivalents from @p RZImportable without reading 
 *           the method documentation. This category provides a crucial implementation of these methods that enables 
 *           automatic Core Data importing.
 */
@interface NSManagedObject (RZImport) <RZImportable>

/**
 *  Creates or updates an object in the provided managed object context using the key/value pairs in the provided dictionary.
 *  If an an object with a matching primary key value exists in the context, this method will update it with the values in
 *  the dictionary and return the result. If no existing object is found, this method will create/insert a new one and initialize
 *  it with the values in the dictionary.
 *
 *  @param dict    The dictionary representing the object to be inserted/updated.
 *  @param context The context in which to find/insert the object. Must not be nil.
 *
 *  @note Calling @p rzi_objectFromDictionary: without the context parameter will use the default context provided by
 *        calling @p +rzv_coreDataStack on the managed object subclass.
 *
 *  @note This method does not save the context or the core data stack.
 *
 *  @return A matching or newly created object updated from the key/value pairs in the dictionary.
 */
+ (instancetype)rzi_objectFromDictionary:(NSDictionary *)dict inContext:(NSManagedObjectContext *)context;

/**
 *  Creates or updates an object in the provided managed object context using the key/value pairs in the provided dictionary.
 *  If an an object with a matching primary key value exists in the context, this method will update it with the values in
 *  the dictionary and return the result. If no existing object is found, this method will create/insert a new one and initialize
 *  it with the values in the dictionary.
 *
 *  @param dict    The dictionary representing the object to be inserted/updated.
 *  @param context The context in which to find/insert the object. Must not be nil.
 *  @param mappings An optional dictionary of extra mappings from keys to property names to
 *                  use in the import. These will override/supplement implicit mappings and mappings
 *                  provided by @p RZImportable.
 *
 *  @note Calling @p rzi_objectFromDictionary: without the context parameter will use the default context provided by
 *        calling @p +rzv_coreDataStack on the managed object subclass.
 *
 *  @note This method does not save the context or the core data stack.
 *
 *  @return A matching or newly created object updated from the key/value pairs in the dictionary.
 */
+ (instancetype)rzi_objectFromDictionary:(NSDictionary *)dict inContext:(NSManagedObjectContext *)context withMappings:(NSDictionary *)mappings;

/**
 *  Creates or updates multiple objects in the provided managed object context using the key/value pairs in the dictionaries 
 *  in the provided array. If an an object with a matching primary key value for a dictionary exists in the context, this method will 
 *  update it with the values in the dictionary. If no existing object is found, this method will create/insert a new one and initialize
 *  it with the values in the dictionary. The corresponding imported/updated objects are returned in a new array.
 *
 *  @param array   An array of @p NSDictionary instances representing objects to be inserted/updated.
 *  @param context The context in which to find/insert the object. Must not be nil.
 *
 *  @note Calling @p rzi_objectsFromArray: without the context parameter will use the default context provided by
 *        calling @p +rzv_coreDataStack on the managed object subclass.
 *
 *  @note This method does not save the context or the core data stack.
 *
 *  @return An array matching or newly created objects updated from the key/value pairs in the dictionaries in the array.
 */
+ (NSArray *)rzi_objectsFromArray:(NSArray *)array inContext:(NSManagedObjectContext *)context;

/**
 *  Creates or updates multiple objects in the provided managed object context using the key/value pairs in the dictionaries
 *  in the provided array. If an an object with a matching primary key value for a dictionary exists in the context, this method will
 *  update it with the values in the dictionary. If no existing object is found, this method will create/insert a new one and initialize
 *  it with the values in the dictionary. The corresponding imported/updated objects are returned in a new array.
 *
 *  @param array   An array of @p NSDictionary instances representing objects to be inserted/updated.
 *  @param context The context in which to find/insert the object. Must not be nil.
 *  @param mappings An optional dictionary of extra mappings from keys to property names to
 *                  use in the import. These will override/supplement implicit mappings and mappings
 *                  provided by @p RZImportable.
 *
 *  @note Calling @p rzi_objectsFromArray: without the context parameter will use the default context provided by
 *        calling @p +rzv_coreDataStack on the managed object subclass.
 *
 *  @note This method does not save the context or the core data stack.
 *
 *  @return An array matching or newly created objects updated from the key/value pairs in the dictionaries in the array.
 */
+ (NSArray *)rzi_objectsFromArray:(NSArray *)array inContext:(NSManagedObjectContext *)context withMappings:(NSDictionary *)mappings;

/**
 *  Import the values from the provided dictionary into the receiver using the provided context to manage relationships.
 * 
 *  @param dict    The dictionary representing the object to be inserted/updated.
 *  @param context The context in which to find/insert the object. Must not be nil.
 *
 *  @note Calling @p rzi_importValuesFromDict: without the context parameter will use the default context provided by
 *        calling @p +rzv_coreDataStack on the managed object subclass.
 *
 *  @warning This method does not manage object uniqueness as it is an instance method and will act on whatever instance it is called on.
 *
 */
- (void)rzi_importValuesFromDict:(NSDictionary *)dict inContext:(NSManagedObjectContext *)context;

/**
 *  Import the values from the provided dictionary into the receiver using the provided context to manage relationships, with optional extra property mappings.
 *
 *  @param dict    The dictionary representing the object to be inserted/updated.
 *  @param context The context in which to find/insert the object. Must not be nil.
 *  @param mappings An optional dictionary of extra mappings from keys to property names to
 *                  use in the import. These will override/supplement implicit mappings and mappings
 *                  provided by @p RZImportable.
 *
 *  @note Calling @p rzi_importValuesFromDict: without the context parameter will use the default context provided by
 *        calling @p +rzv_coreDataStack on the managed object subclass.
 *
 *  @warning This method does not manage object uniqueness as it is an instance method and will act on whatever instance it is called on.
 */
- (void)rzi_importValuesFromDict:(NSDictionary *)dict inContext:(NSManagedObjectContext *)context withMappings:(NSDictionary *)mappings;


/** @name RZImportable Protocol */


/**
 *  Extended implementation of the method from @p RZImportable.
 *  Do not call directly; this is exposed for reasons of documentation only.
 *
 *  If you override this method in an @p NSManagedObject subclass, it must always return a valid instance
 *  of the receiver's class, whether previously existing or newly inserted into the supplied context.
 *
 *  @param dict The dictionary representing an instance of the receiver's class.
 *  @param context The managed object context in which to find/insert the object.
 *
 *  @warning Do not implement the @p RZImportable protocol method @p +rzi_existingObjectForDict: in subclasses.
 *           This method is called by an internal implementation of @p +rzi_existingObjectForDict: which will pass along the correct
 *           context based on a bit of internal state.
 *
 *  @return A valid NSManagedObject initialized with the provided dictionary, or nil
 *          if an object could not be created.
 */
+ (id)rzi_existingObjectForDict:(NSDictionary *)dict inContext:(NSManagedObjectContext *)context;

/**
 *  Extended implementation of the method from @p RZImportable.
 *  Do not call directly; this is exposed for reasons of documentation only.
 *
 *  If you override this method in an @p NSManagedObject subclass for purposes of validation, you must only prevent 
 *  invalid values from being imported by returning @p NO. For valid import values, you should return the value returned
 *  by this (@p super's) implementation.
 *
 *  @param value   The value being imported for @p key
 *  @param key     The key being imported.
 *  @param context The context in which the import is taking place.
 *
 *  @warning Do not implement the @p RZImportable protocol method @p +rzi_shouldImportValue:forKey: in subclasses.
 *           This method is called by an internal implementation of @p +rzi_shouldImportValue:forKey: which will pass along the correct
 *           context based on a bit of internal state.
 *
 *  @return YES if @p RZImport should perform automatic value import, NO to prevent it from doing so.
 */
- (BOOL)rzi_shouldImportValue:(id)value forKey:(NSString *)key inContext:(NSManagedObjectContext *)context NS_REQUIRES_SUPER;

@end
