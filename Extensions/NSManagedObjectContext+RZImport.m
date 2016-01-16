//
//  NSManagedObjectContext+RZImport.m
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

#import "NSManagedObject+RZVinylUtils.h"
#import "NSManagedObject+RZVinylRecord.h"
#import "NSManagedObject+RZImport.h"
#import "NSManagedObject+RZImportableSubclass.h"

#import "NSManagedObjectContext+RZImport.h"
#import "RZCoreDataStack.h"

@implementation NSThread (RZImport)

static NSString * const kRZVinylImportThreadContextKey = @"RZVinylImportThreadContext";
static NSString * const kRZVinylImportCacheContextKey = @"RZVinylImportCacheContextKey";

- (NSManagedObjectContext *)rzi_currentImportContext
{
    NSManagedObjectContext *context = [[self threadDictionary] objectForKey:kRZVinylImportThreadContextKey];
    return context;
}

- (void)rzi_setCurrentImportContext:(NSManagedObjectContext *)context
{
    if ( context ) {
        [[self threadDictionary] setObject:context forKey:kRZVinylImportThreadContextKey];
    }
    else {
        [[self threadDictionary] removeObjectForKey:kRZVinylImportThreadContextKey];
    }
}

@end

@implementation NSManagedObjectContext (RZImport)

- (void)rzi_performImport:(void(^)(void))importBlock
{
    NSParameterAssert(importBlock);
    NSThread *thread = [NSThread currentThread];
    NSManagedObjectContext *initialImportContext = [thread rzi_currentImportContext];
    [thread rzi_setCurrentImportContext:self];
    [self performBlockAndWait:importBlock];
    [thread rzi_setCurrentImportContext:initialImportContext];
}

+ (NSManagedObjectContext *)rzi_currentThreadImportContext
{
    NSManagedObjectContext *context = [[NSThread currentThread] rzi_currentImportContext];
    if ( context == nil && [NSThread currentThread] == [NSThread mainThread] ) {
        context = [[RZCoreDataStack defaultStack] mainManagedObjectContext];
    }
    NSAssert(context != nil, @"RZImport is attempting to perform an import with out an import context. Make sure that you use RZImport from inside -[NSManagedObjectContext rzi_performImport].");
    return context;
}

- (NSMutableDictionary *)rzi_cacheByEntityName
{
    NSMutableDictionary *dictionary = self.userInfo[kRZVinylImportCacheContextKey];
    if (dictionary == nil) {
        dictionary = [NSMutableDictionary dictionary];
        self.userInfo[kRZVinylImportCacheContextKey] = dictionary;
    }
    return dictionary;
}

- (NSMutableDictionary *)rzi_cacheForEntity:(Class)entityClass
{
    NSMutableDictionary *cachedObjects = self.rzi_cacheByEntityName[[entityClass rzv_entityName]];
    if (cachedObjects == nil) {
        cachedObjects = [NSMutableDictionary dictionary];
        self.rzi_cacheByEntityName[[entityClass rzv_entityName]] = cachedObjects;
    }
    return cachedObjects;
}

- (void)rzi_cacheObjects:(NSArray *)objects forEntity:(Class)entityClass
{
    NSArray *keys = [objects valueForKey:[entityClass rzv_primaryKey]];
    NSDictionary *values = [NSDictionary dictionaryWithObjects:objects
                                                       forKeys:keys];
    NSMutableDictionary *cachedObjects = [self rzi_cacheForEntity:entityClass];
    [cachedObjects setValuesForKeysWithDictionary:values];
}

- (void)rzi_loadCacheWithImportData:(NSArray *)importData forEntity:(Class)entityClass
{
    NSMutableDictionary *cachedObjects = [self rzi_cacheForEntity:entityClass];

    NSString *primaryKey = [entityClass rzv_primaryKey];
    NSString *externalPrimaryKey = [entityClass rzv_externalPrimaryKey] ?: primaryKey;

    // Determine the primary keys by the external key, and remove duplicates in importData
    NSArray *keyValues = [importData valueForKey:externalPrimaryKey];
    NSMutableSet *neededKeyValues = [NSMutableSet setWithArray:keyValues];

    // Look up the objects in the cache.
    for (id keyValue in [neededKeyValues copy]) {
        id cache = cachedObjects[keyValue];
        if (cache) {
            [neededKeyValues removeObject:keyValue];
        }
    }

    // If keys do not have objects, look them up
    if (neededKeyValues.count > 0) {
        NSPredicate *existingObjPred = [NSPredicate predicateWithFormat:@"%K in %@", [entityClass rzv_primaryKey], neededKeyValues];
        NSArray     *existingObjects = [entityClass rzv_where:existingObjPred inContext:self];

        for (id object in existingObjects) {
            id keyValue = [object valueForKey:primaryKey];
            [neededKeyValues removeObject:keyValue];
            [cachedObjects setObject:object forKey:keyValue];
        }
    }
}

- (void)rzi_cacheAllObjectsForEntityName:(Class)entityClass
{
    NSArray *objects = [entityClass rzv_allInContext:self];
    [self rzi_cacheObjects:objects forEntity:entityClass];
}

- (NSManagedObject *)rzi_cachedObjectForEntity:(Class)entityClass forPrimaryKeyValue:(id)keyValue;
{
    NSMutableDictionary *cachedObjects = [self rzi_cacheForEntity:entityClass];
    return cachedObjects[keyValue];
}

@end
