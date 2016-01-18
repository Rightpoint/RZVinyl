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
#import "NSObject+RZImport_private.h"
#import "RZCoreDataStack.h"
#import "RZVinylDefines.h"

/**
 *  Managing the cache on the main context is complicated, since the user would have to manage
 *  when to clear the cache. Disable the cache on the main thread, since moving imports on to a
 *  background context is the first optimization to use.
 */
#define RZVAssertOffMainContext() \
({\
RZCoreDataStack *stack = self.userInfo[kRZCoreDataStackParentStackKey];\
NSAssert(stack.mainManagedObjectContext != self, @"Can not enable cache on the main context.");\
stack.mainManagedObjectContext != self;\
})

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
    NSAssert(context != nil, @"RZImport is attempting to perform an import with out an import context. Make sure that you use RZImport from inside -[NSManagedObjectContext rzi_performImport] or with one of the `inContext:` methods.");
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

- (NSMutableDictionary *)rzi_cacheForEntity:(Class)entityClass externalKey:(NSString *)key
{
    if (!RZVAssertOffMainContext()) {
        return nil;
    }
    NSMutableDictionary *entityCache = self.rzi_cacheByEntityName[[entityClass rzv_entityName]];
    if (entityCache == nil) {
        entityCache = [NSMutableDictionary dictionary];
        self.rzi_cacheByEntityName[[entityClass rzv_entityName]] = entityCache;
    }
    NSMutableDictionary *entityKeyCache = entityCache[key];
    if (entityKeyCache == nil) {
        entityKeyCache = [NSMutableDictionary dictionary];
        entityCache[key] = entityKeyCache;
    }

    return entityKeyCache;
}

- (void)rzi_cacheObjects:(NSArray *)objects forEntity:(Class)entityClass
{
    for ( NSString *externalKey in [entityClass rzv_externalCacheKeys] ) {
        RZIPropertyInfo *info = [entityClass rzi_propertyInfoForExternalKey:externalKey withMappings:nil];
        NSAssert(info != nil, @"Unable to find property for external key %@", externalKey);
        NSArray *keys = [objects valueForKey:info.propertyName];
        NSDictionary *values = [NSDictionary dictionaryWithObjects:objects
                                                           forKeys:keys];
        NSMutableDictionary *cachedObjects = [self rzi_cacheForEntity:entityClass externalKey:externalKey];
        [cachedObjects setValuesForKeysWithDictionary:values];
    }
}

- (void)rzi_cacheAllObjectsForEntityName:(Class)entityClass
{
    NSArray *objects = [entityClass rzv_allInContext:self];
    [self rzi_cacheObjects:objects forEntity:entityClass];
}

@end

@implementation NSManagedObjectContext (RZImport_private)

- (NSManagedObject *)rzi_objectForEntity:(Class)entityClass fromDictionary:(NSDictionary *)dictionary;
{
    for ( NSString *key in [entityClass rzv_externalCacheKeys] ) {
        id value = [dictionary objectForKey:key];
        if ( value == nil ) {
            continue;
        }
        id result = [self rzi_cacheForEntity:entityClass externalKey:key][value];
        if ( result ) {
            return result;
        }
    }
    return nil;
}

- (BOOL)rzi_isCacheEnabledForEntity:(Class)entityClass;
{
    return [self.rzi_cacheByEntityName objectForKey:[entityClass rzv_entityName]] != nil;
}

- (void)rzi_disableCacheForEntity:(Class)entityClass
{
    if (!RZVAssertOffMainContext()) {
        return;
    }
    [self.rzi_cacheByEntityName removeObjectForKey:[entityClass rzv_entityName]];
}

@end
