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
 */
- (void)rzi_performImport:(void(^)(void))importBlock;

/**
 *  The managed object context that is being imported to. This is set internally
 *  and by the `rzi_performImport:` method.
 */
+ (NSManagedObjectContext *)rzi_currentThreadImportContext;

/**
 *  Cache all objects that are in the context.
 */
- (void)rzi_cacheAllObjectsForEntityName:(Class)entityClass;

/**
 *  Cache a specific set of objects for the given entity
 */
- (void)rzi_cacheObjects:(NSArray *)objects forEntity:(Class)entityClass;

/**
 *  Load cache from the import data. Ensure that an object exists for
 *  every primary key value in the importData, looking up, or creating objects 
 *  as needed. All of the cached objects are returned.
 */
- (void)rzi_loadCacheWithImportData:(NSArray *)importData forEntity:(Class)entityClass;

/**
 *  Lookup an object in the cache with the specified primary key value.
 */
- (NSManagedObject *)rzi_cachedObjectForEntity:(Class)entityClass forPrimaryKeyValue:(id)key;

@end
