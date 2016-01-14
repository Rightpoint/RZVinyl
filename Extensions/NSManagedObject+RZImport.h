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
#import "RZVCompatibility.h"
#import <RZImport/NSObject+RZImport.h>

/**
 *  Automatic importing of dictionary representations (e.g. deserialized JSON response) 
 *  of an object to CoreData, using RZVinyl and RZImport.
 *
 *  RZImport will only work on the main thread, or inside a @p NSManagedObjectContext rzi_performImport: block.
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
+ (RZNonnull instancetype)rzi_objectFromDictionary:(RZVStringDictionary* RZCNonnull)dict inContext:(NSManagedObjectContext* RZCNonnull)context;

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
+ (RZNonnull instancetype)rzi_objectFromDictionary:(RZVStringDictionary* RZCNonnull)dict
                                         inContext:(NSManagedObjectContext* RZCNonnull)context
                                      withMappings:(RZVKeyMap* RZCNullable)mappings;

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
+ (RZNonnull NSArray *)rzi_objectsFromArray:(RZVArrayOfStringDict* RZCNonnull)array
                                  inContext:(NSManagedObjectContext* RZCNonnull)context;

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
+ (NSArray* RZCNonnull)rzi_objectsFromArray:(RZVArrayOfStringDict * RZCNonnull)array
                                  inContext:(NSManagedObjectContext* RZCNonnull)context
                               withMappings:(RZVKeyMap* RZCNullable)mappings;


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
+ (RZNullable id)rzi_existingObjectForDict:(RZVStringDictionary* RZCNonnull)dict inContext:(NSManagedObjectContext* RZCNonnull)context;

@end

/**
 * The original implementation had versions of the RZImportable methods that provided a context. These implementations are maintained to generate warnings, and then should still function for now.
 */
@interface NSManagedObject (RZImportDeprecated)

/**
 * Old Implementations of RZImport methods that passed along the managed object context. The context is not needed for instances of NSManagedObjectContext, since self.managedObjectContext is available.
 */
- (BOOL)rzi_shouldImportValue:(id RZCNonnull)value
                       forKey:(NSString* RZCNonnull)key
                    inContext:(NSManagedObjectContext* RZCNonnull)context NS_REQUIRES_SUPER __attribute__((deprecated("Use -rzi_shouldImportValue:forKey: and self.managedObjectContext")));

- (void)rzi_importValuesFromDict:(RZVStringDictionary* RZCNonnull)dict inContext:(NSManagedObjectContext* RZCNonnull)context __attribute__((deprecated("Use -rzi_importValuesFromDict: and self.managedObjectContext")));

- (void)rzi_importValuesFromDict:(RZVStringDictionary* RZCNonnull)dict
                       inContext:(NSManagedObjectContext* RZCNonnull)context
                    withMappings:(RZVKeyMap* RZCNullable)mappings __attribute__((deprecated("Use -rzi_importValuesFromDict:withMappings: and self.managedObjectContext")));


@end
