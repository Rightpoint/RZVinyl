//
//  NSManagedObjectContext+RZImport.h
//  RZVinyl
//
//  Created by Brian King on 1/12/16.
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

@interface NSManagedObjectContext (RZImport)

/**
 *  Specify that this managed object context should be used for all subsequent
 *  RZImport operations. This enables RZImport to work with NSObjects containing
 *  NSManagedObjects.
 *
 *  @param importBlock A block to execute where the import context will be set to this managed object context.
 */
- (void)rzi_performImport:(void(^)(void))importBlock;

/**
 *  The managed object context that is being imported to. This is set internally
 *  and by the `rzi_performImport:` method.
 *
 *  @return the thread-local managed object context
 */
+ (NSManagedObjectContext *)rzi_currentThreadImportContext;

/**
 *  Lookup all objects that belong to the entity and cache them.
 *
 *  @note If this is called on the main context of the core data stack, this method will assert.
 *
 *  @param entityClass A subclass of NSManagedObject to cache.
 */
- (void)rzi_cacheAllObjectsForEntity:(Class)entityClass;

/**
 *  Cache a specific set of objects for the given entity.
 *
 *  @warning Make sure that the objects cached contain all possibilities for the import
 *           associations, otherwise duplicate objects may be created.
 *
 *  @param objects An array of objects to cache. All of these objects are of class entityClass.
 *  @param entityClass A subclass of NSManagedObject to cache.
 */
- (void)rzi_cacheObjects:(NSArray *)objects forEntity:(Class)entityClass;

/**
 *  Look for a cached instance of entityClass that has matching keys in the dictionary.
 *
 *  @param entityClass A subclass of NSManagedObject to lookup.
 *  @param dictionary A dictionary containing the keys and values to lookup in the cache.
 */
- (NSManagedObject *)rzi_cachedObjectForKeysInDictionary:(NSDictionary *)dictionary entity:(Class)entityClass;

/**
 *  Check to see if the cache is enabled for the specified entity.
 */
- (BOOL)rzi_isCacheEnabledForEntity:(Class)entityClass;

@end
