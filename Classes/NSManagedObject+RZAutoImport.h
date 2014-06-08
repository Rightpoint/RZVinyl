//
//  NSManagedObject+RZAutoImport.h
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
#import "RZAutoImport.h"

/**
 *  Automatic importing of dictionary representations (e.g. deserialized JSON response) 
 *  of an object to CoreData, using RZVinyl and RZAutoImport. Provides a partial implementation
 *  of @RZAutoImportable.
 *
 *  @warning Do not override the extended methods or thir equivalents from @p RZAutoImportable without reading 
 *           the method documentation. This category provides a crucial implementation of these methods that enables 
 *           automaitic CoreData importing.
 */
@interface NSManagedObject (RZAutoImport) <RZAutoImportable>

+ (instancetype)rzai_objectFromDictionary:(NSDictionary *)dict
                                inContext:(NSManagedObjectContext *)context;

+ (NSArray *)rzai_objectsFromArray:(NSArray *)array
                         inContext:(NSManagedObjectContext *)context;

//
//  RZAutoImportable Protocol
//

/**
 *  Extended implementation of the method from @p RZAutoImportable.
 *  Do not call directly; this is exposed for reasons of documentation only.
 *
 *  If you override this method in an @p NSManagedObject subclass, it must always return a valid instance
 *  of the receiver's class, whether previously existing or newly inserted into the supplied context.
 *
 *  @param dict The dictionary representing an instance of the receiver's class.
 *  @param context The managed object context in which to find/insert the object.
 *
 *  @warning Do not implement the @p RZAutoImportable protocol method @p +rzai_existingObjectForDict: in subclasses.
 *           This methid is called by an internal implementation of @p +rzai_existingObjectForDict: which will pass along the correct
 *           context based on a bit of internal state.
 *
 *  @return A valid NSManagedObject initialized with the provided dictionary, or nil
 *          if an object could not be created.
 */
+ (id)rzai_existingObjectForDict:(NSDictionary *)dict inContext:(NSManagedObjectContext *)context;

/**
 *  Extended implementation of the method from @p RZAutoImportable.
 *  Do not call directly; this is exposed for reasons of documentation only.
 *
 *  If you override this method in an @p NSManagedObject subclass for purposes of validation, you must only prevent 
 *  invalid values from being imported byreturning @p NO. For valid import values, you should return the value returned 
 *  by this (@p super's) implementation.
 *
 *  @param value   The value being imported for @p key
 *  @param key     The key being imported.
 *  @param context The context in which the import is taking place.
 *
 *  @warning Do not implement the @p RZAutoImportable protocol method @p +rzai_shouldImportValue:forKey: in subclasses.
 *           This method is called by an internal implementation of @p +rzai_shouldImportValue:forKey: which will pass along the correct
 *           context based on a bit of internal state.
 *
 *  @return YES if @p RZAutoImport should perform automatic value import, NO to prevent it from doing so.
 */
- (BOOL)rzai_shouldImportValue:(id)value forKey:(NSString *)key inContext:(NSManagedObjectContext *)context;

@end