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

@end

/**
 * The original implementation had versions of the RZImportable methods that provided a context. These implementations are maintained to generate warnings, and then should still function for now.
 */
@interface NSManagedObject (RZImportDeprecated)

+ (RZNonnull instancetype)rzi_objectFromDictionary:(RZVStringDictionary* RZCNonnull)dict
                                         inContext:(NSManagedObjectContext* RZCNonnull)context
__attribute__((deprecated("Use -rzi_objectFromDictionary: from inside -[NSManagedObjectContext rzi_performBlock:]")));

+ (RZNonnull instancetype)rzi_objectFromDictionary:(RZVStringDictionary* RZCNonnull)dict
                                         inContext:(NSManagedObjectContext* RZCNonnull)context
                                      withMappings:(RZVKeyMap* RZCNullable)mappings
__attribute__((deprecated("Use -rzi_objectFromDictionary:withMappings: from inside -[NSManagedObjectContext rzi_performBlock:]")));

+ (RZNonnull NSArray *)rzi_objectsFromArray:(RZVArrayOfStringDict* RZCNonnull)array
                                  inContext:(NSManagedObjectContext* RZCNonnull)context
__attribute__((deprecated("Use -rzi_objectsFromArray: from inside -[NSManagedObjectContext rzi_performBlock:]")));

+ (NSArray* RZCNonnull)rzi_objectsFromArray:(RZVArrayOfStringDict * RZCNonnull)array
                                  inContext:(NSManagedObjectContext* RZCNonnull)context
                               withMappings:(RZVKeyMap* RZCNullable)mappings
__attribute__((deprecated("Use -rzi_objectsFromArray:withMappings: from inside -[NSManagedObjectContext rzi_performBlock:]")));

+ (RZNullable id)rzi_existingObjectForDict:(RZVStringDictionary* RZCNonnull)dict
                                 inContext:(NSManagedObjectContext* RZCNonnull)context
__attribute__((deprecated("Use -rzi_objectsFromArray:withMappings: from inside -[NSManagedObjectContext rzi_performBlock:]")));

- (BOOL)rzi_shouldImportValue:(id RZCNonnull)value
                       forKey:(NSString* RZCNonnull)key
                    inContext:(NSManagedObjectContext* RZCNonnull)context
__attribute__((deprecated("Use -rzi_shouldImportValue:forKey: and self.managedObjectContext")));

- (void)rzi_importValuesFromDict:(RZVStringDictionary* RZCNonnull)dict inContext:(NSManagedObjectContext* RZCNonnull)context
__attribute__((deprecated("Use -rzi_importValuesFromDict: and self.managedObjectContext")));

- (void)rzi_importValuesFromDict:(RZVStringDictionary* RZCNonnull)dict
                       inContext:(NSManagedObjectContext* RZCNonnull)context
                    withMappings:(RZVKeyMap* RZCNullable)mappings
__attribute__((deprecated("Use -rzi_importValuesFromDict:withMappings: and self.managedObjectContext")));


@end
