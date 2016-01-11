//
//  NSManagedObject+RZImport.m
//  RZVinyl
//
//  Created by Nick Donaldson on 6/5/14.
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
//  MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND
//  NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT HOLDERS BE
//  LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER IN AN ACTION
//  OF CONTRACT, TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN CONNECTION
//  WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE.


#import "NSManagedObject+RZImport.h"
#import "NSObject+RZImport_private.h"
#import "NSManagedObject+RZVinylRecord.h"
#import "NSManagedObject+RZVinylUtils.h"
#import "NSManagedObject+RZImport_private.h"
#import "NSManagedObject+RZVinylRecord_private.h"
#import "NSFetchRequest+RZVinylRecord.h"
#import "RZVinylRelationshipInfo.h"
#import "RZVinylDefines.h"
#import "RZVinylRecord.h"
#import "RZCoreDataStack.h"

#define RZVBeginThreadContext() \
    BOOL nestedCall = ([[self class] rzv_currentThreadImportContext] != nil); \
    if ( !nestedCall ) { \
        [[self class] rzi_setCurrentThreadImportContext:context]; \
    }

#define RZVEndThreadContext() \
    if ( !nestedCall ) { \
        [[self class] rzi_setCurrentThreadImportContext:nil]; \
    }

//
// Implementation
//

@implementation NSManagedObject (RZImport)

//!!!: Overridden to support default context
+ (instancetype)rzi_objectFromDictionary:(NSDictionary *)dict withMappings:(NSDictionary *)mappings
{
    // !!!: This is also called internally by the original RZImport methods Need to check if this is part of an ongoing import.
    //      Otherwise, assert that this is called on the main thread and use the default context.
    NSManagedObjectContext *context = [self rzv_currentThreadImportContext];
    if ( context == nil ) {
        if ( !RZVAssertMainThread() ) {
            return nil;
        }
        context = [[self rzv_validCoreDataStack] mainManagedObjectContext];
    }
    return [self rzi_objectFromDictionary:dict inContext:context];
}

//!!!: Overridden to support default context
+ (NSArray *)rzi_objectsFromArray:(NSArray *)array withMappings:(NSDictionary *)mappings
{
    // !!!: This is also called internally by the original RZImport methods Need to check if this is part of an ongoing import.
    //      Otherwise, assert that this is called on the main thread and use the default context.
    NSManagedObjectContext *context = [self rzv_currentThreadImportContext];
    if ( context == nil ) {
        if ( !RZVAssertMainThread() ) {
            return nil;
        }
        context = [[self rzv_validCoreDataStack] mainManagedObjectContext];
    }
    return [self rzi_objectsFromArray:array inContext:context];
}

+ (instancetype)rzi_objectFromDictionary:(NSDictionary *)dict inContext:(NSManagedObjectContext *)context
{
    return [self rzi_objectFromDictionary:dict inContext:context withMappings:nil];
}

+ (instancetype)rzi_objectFromDictionary:(NSDictionary *)dict inContext:(NSManagedObjectContext *)context withMappings:(NSDictionary *)mappings
{
    if ( !RZVParameterAssert(context) ) {
        return nil;
    }

    mappings = [self rzi_primaryKeyMappingsDictWithMappings:mappings];
    
    RZVBeginThreadContext();
    id object = [super rzi_objectFromDictionary:dict withMappings:mappings];
    RZVEndThreadContext();
    
    return object;
}

+ (NSArray *)rzi_objectsFromArray:(NSArray *)array inContext:(NSManagedObjectContext *)context
{
    return [self rzi_objectsFromArray:array inContext:context withMappings:nil];
}

+ (NSArray *)rzi_objectsFromArray:(NSArray *)array inContext:(NSManagedObjectContext *)context withMappings:(NSDictionary *)mappings
{
    if ( !RZVParameterAssert(context) ) {
        return nil;
    }
    
    mappings = [self rzi_primaryKeyMappingsDictWithMappings:mappings];

    RZVBeginThreadContext();

    NSArray *objects = nil;

    if ( array.count == 1 ) {
        id importedObject = [super rzi_objectFromDictionary:array[0] withMappings:mappings];
        if ( importedObject ) {
            objects = @[importedObject];
        }
    }
    else if ( [self rzv_safe_primaryKey] != nil ) {
    
        NSMutableDictionary *updatedObjects = [NSMutableDictionary dictionary];
        
        NSString *externalPrimaryKey = [self rzv_safe_externalPrimaryKey] ?: [self rzv_safe_primaryKey];
        
        // Pre-fetch all objects that have a primary key in the set of objects being imported
        NSDictionary *existingObjectsByID = [self rzi_existingObjectsByIDForArray:array inContext:context];
        [array enumerateObjectsUsingBlock:^(NSDictionary *rawDict, NSUInteger idx, BOOL *stop) {
            id importedObject = nil;
            id primaryValue = [rawDict objectForKey:externalPrimaryKey];
            
            if ( primaryValue != nil ) {
                importedObject = [existingObjectsByID objectForKey:primaryValue];

                 if (importedObject == nil) {
                     importedObject = [updatedObjects objectForKey:primaryValue];
                 }
            }

            if ( importedObject == nil ) {
                importedObject = [self rzv_newObjectInContext:context];
            }
            
            [importedObject rzi_importValuesFromDict:rawDict inContext:context withMappings:mappings];
            
            if ( importedObject != nil ) {
                [updatedObjects setObject:importedObject forKey:primaryValue];
            }
        }];
        
        objects = [updatedObjects allValues];
    }
    else {
        // Default to creating new object instances.
        objects = [super rzi_objectsFromArray:array withMappings:nil];
    }
    
    RZVEndThreadContext();
    
    return objects;
}


//!!!: Overridden to support default context
- (void)rzi_importValuesFromDict:(NSDictionary *)dict withMappings:(NSDictionary *)mappings
{
    // !!!: This is also called internally by the original RZImport methods Need to check if this is part of an ongoing import.
    //      Otherwise, assert that this is called on the main thread and use the default context.
    NSManagedObjectContext *context = [[self class] rzv_currentThreadImportContext];
    if ( context == nil ) {
        if ( !RZVAssertMainThread() ) {
            return;
        }
        context = [[[self class] rzv_validCoreDataStack] mainManagedObjectContext];
    }
    [self rzi_importValuesFromDict:dict inContext:context withMappings:mappings];
}

- (void)rzi_importValuesFromDict:(NSDictionary *)dict inContext:(NSManagedObjectContext *)context
{
    [self rzi_importValuesFromDict:dict inContext:context withMappings:nil];
}

- (void)rzi_importValuesFromDict:(NSDictionary *)dict inContext:(NSManagedObjectContext *)context withMappings:(NSDictionary *)mappings
{
    NSParameterAssert(context);
    RZVBeginThreadContext();
    mappings = [[self class] rzi_primaryKeyMappingsDictWithMappings:mappings];
    [super rzi_importValuesFromDict:dict withMappings:mappings];
    RZVEndThreadContext();
}

#pragma mark - RZImportable

+ (id)rzi_existingObjectForDict:(NSDictionary *)dict
{
    NSManagedObjectContext *context = [self rzv_currentThreadImportContext];
    return [self rzi_existingObjectForDict:dict inContext:context];
}

+ (id)rzi_existingObjectForDict:(NSDictionary *)dict inContext:(NSManagedObjectContext *)context
{
    if ( !RZVParameterAssert(context) ){
        RZVLogError(@"This thread does not have an associated managed object context at the moment, and that's a problem.");
        return nil;
    }
    
    if ( [self rzv_safe_shouldAlwaysCreateNewObjectOnImport] ) {
        return [self rzv_newObjectInContext:context];
    }
    
    id object = nil;
    NSString *externalPrimaryKey = [self rzv_safe_externalPrimaryKey] ?: [self rzv_safe_primaryKey];
    id primaryValue = externalPrimaryKey ? [dict objectForKey:externalPrimaryKey] : nil;
    if ( primaryValue != nil ) {
        object = [self rzv_objectWithPrimaryKeyValue:primaryValue createNew:YES inContext:context];
    }
    else {
        [self rzv_logUniqueObjectsWarning];
        object = [self rzv_newObjectInContext:context];
    }
    
    return object;
}

- (BOOL)rzi_shouldImportValue:(id)value forKey:(NSString *)key
{
    NSManagedObjectContext *context = [[self class] rzv_currentThreadImportContext];
    return [self rzi_shouldImportValue:value forKey:key inContext:context];
}

- (BOOL)rzi_shouldImportValue:(id)value forKey:(NSString *)key inContext:(NSManagedObjectContext *)context
{
    if ( !RZVParameterAssert(context) ){
        RZVLogError(@"This thread does not have an associated managed object context at the moment, and that's a problem.");
        return NO;
    }
    
    __block BOOL shouldImport = YES;
    RZIPropertyInfo *propInfo = [[self class] rzi_propertyInfoForExternalKey:key withMappings:nil];
    if ( propInfo != nil && (propInfo.dataType == RZImportDataTypeOtherObject || propInfo.dataType == RZImportDataTypeNSSet) ) {

        // Check cached relationship mapping info. If collection type matches, perform automatic relationship import
        __block RZVinylRelationshipInfo *relationshipInfo = nil;
        
        // !!!: This needs to be done in a thread-safe way - the cache is mutable state
        rzv_performBlockAtomically(YES, ^{
            relationshipInfo = [[self class] rzi_relationshipInfoForKey:key];
        });
        
        if ( relationshipInfo != nil ) {
            [self rzi_performRelationshipImportWithValue:value forRelationship:relationshipInfo];
            shouldImport = NO;
        }
    }
    
    return shouldImport;
}

#pragma mark - Private

static NSString * const kRZVinylImportThreadContextKey = @"RZVinylImportThreadContext";

+ (NSManagedObjectContext *)rzv_currentThreadImportContext
{
    return [[[NSThread currentThread] threadDictionary] objectForKey:kRZVinylImportThreadContextKey];
}

+ (void)rzi_setCurrentThreadImportContext:(NSManagedObjectContext *)context
{
    if ( context ) {
        [[[NSThread currentThread] threadDictionary] setObject:context forKey:kRZVinylImportThreadContextKey];
    }
    else {
        [[[NSThread currentThread] threadDictionary] removeObjectForKey:kRZVinylImportThreadContextKey];
    }
}

+ (NSDictionary *)rzi_primaryKeyMappingsDictWithMappings:(NSDictionary *)mappings
{
    NSMutableDictionary *extraMappings = (mappings != nil) ? [mappings mutableCopy] : [NSMutableDictionary dictionary];
    if ( [self rzi_primaryKeyMapping] ) {
        [extraMappings addEntriesFromDictionary:[self rzi_primaryKeyMapping]];
    }
    return [NSDictionary dictionaryWithDictionary:extraMappings];
}

+ (NSDictionary *)rzi_primaryKeyMapping
{
    NSString *primaryKey = [self rzv_safe_primaryKey];
    NSString *externalPrimaryKey = [self rzv_safe_externalPrimaryKey];
    if ( primaryKey != nil && externalPrimaryKey != nil ) {
        return @{ externalPrimaryKey : primaryKey };
    }
    
    // If no external primary key, then the external key is assumed to match
    return nil;

}

+ (RZVinylRelationshipInfo *)rzi_relationshipInfoForKey:(NSString *)key
{
    static NSMutableDictionary *s_cachedRelationshipMappings = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        s_cachedRelationshipMappings = [NSMutableDictionary dictionary];
    });
    
    NSString *className = NSStringFromClass(self);
    NSMutableDictionary *classRelationshipMappings = [s_cachedRelationshipMappings objectForKey:className];
    if ( classRelationshipMappings == nil ) {
        classRelationshipMappings = [NSMutableDictionary dictionary];
        [s_cachedRelationshipMappings setObject:classRelationshipMappings forKey:className];
    }
    
    RZIPropertyInfo *propInfo = [self rzi_propertyInfoForExternalKey:key withMappings:nil];
    
    __block id relationshipInfo = [classRelationshipMappings objectForKey:key];
    if ( relationshipInfo == nil && propInfo.propertyName != nil ) {
        
        NSManagedObjectModel *model = [[[self rzv_currentThreadImportContext] persistentStoreCoordinator] managedObjectModel];
        NSEntityDescription *entity = [[model entitiesByName] objectForKey:[self rzv_entityName]];
        NSRelationshipDescription *relationshipDesc = [[entity relationshipsByName] objectForKey:propInfo.propertyName];
        
        if ( relationshipDesc != nil ) {
            relationshipInfo = [RZVinylRelationshipInfo relationshipInfoFromDescription:relationshipDesc];
        }
        
        if ( relationshipInfo ) {
            [classRelationshipMappings setObject:relationshipInfo forKey:key];
        }
        else {
            [classRelationshipMappings setObject:[NSNull null] forKey:key];
        }
    }

    // !!!: To prevent further checking of non-relationship keys, we cache NSNull
    //      so this ensures that a valid relationshipInfo object is returned
    return [relationshipInfo isEqual:[NSNull null]] ? nil : relationshipInfo;
}

+ (NSDictionary *)rzi_existingObjectsByIDForArray:(NSArray *)array inContext:(NSManagedObjectContext *)context
{
    NSString *primaryKey = [self rzv_safe_primaryKey];
    NSString *externalPrimaryKey = [self rzv_safe_externalPrimaryKey] ?: primaryKey;
    
    NSSet       *primaryKeySet   = [NSSet setWithArray:[array valueForKey:externalPrimaryKey]];
    NSPredicate *existingObjPred = [NSPredicate predicateWithFormat:@"%K in %@", primaryKey, primaryKeySet];
    NSArray     *existingObjects = [self rzv_where:existingObjPred inContext:context];
    
    NSMutableDictionary *existingObjsByID = [NSMutableDictionary dictionary];
    [existingObjects enumerateObjectsUsingBlock:^(id obj, NSUInteger idx, BOOL *stop) {
        id primaryValue = [obj valueForKey:primaryKey];
        if ( primaryValue ) {
            [existingObjsByID setObject:obj forKey:primaryValue];
        }
    }];
    
    return [NSDictionary dictionaryWithDictionary:existingObjsByID];
}

- (void)rzi_performRelationshipImportWithValue:(id)value forRelationship:(RZVinylRelationshipInfo *)relationshipInfo
{
    if ( !RZVParameterAssert(relationshipInfo) ) {
        return;
    }
    
    NSManagedObjectContext *context = [[self class] rzv_currentThreadImportContext];
    if ( !RZVAssert(context != nil, @"There should be a current thread import context.") ) {
        return;
    }
    
    if ( value == nil ) {
        [self rzi_setNilForPropertyNamed:relationshipInfo.sourcePropertyName];
    }
    else if ( relationshipInfo.isToMany ) {
        
        if ( ![value isKindOfClass:[NSArray class]] ) {
            RZVLogError(@"Invalid object class %@ for to-many relationship \"%@\" of entity \"%@\". Expecting NSArray.",
                            NSStringFromClass([value class]),
                            relationshipInfo.sourcePropertyName,
                            relationshipInfo.sourceEntityName);
            return;
        }
        
        NSArray *rawObjects = value;
        NSArray *importedObjects = [relationshipInfo.destinationClass rzi_objectsFromArray:rawObjects inContext:context];
        if ( importedObjects != nil ) {
            if ( relationshipInfo.isOrdered ) {
                [self setValue:[[NSOrderedSet alloc] initWithArray:importedObjects] forKey:relationshipInfo.sourcePropertyName];
            }
            else {
                [self setValue:[NSSet setWithArray:importedObjects] forKey:relationshipInfo.sourcePropertyName];
            }

        }
        else {
            RZVLogError(@"Unable to import objects for relationship \"%@\" on entity \"%@\" from value:\n%@",
                            relationshipInfo.sourcePropertyName,
                            relationshipInfo.sourceEntityName,
                            value);
        }
    }
    else {
       
        if ( ![value isKindOfClass:[NSDictionary class]] ) {
            RZVLogError(@"Invalid object class %@ for to-one relationship \"%@\" of entity \"%@\". Expecting NSDictionary.",
                        NSStringFromClass([value class]),
                        relationshipInfo.sourcePropertyName,
                        relationshipInfo.sourceEntityName);
            return;
        }
        
        id importedObject = [relationshipInfo.destinationClass rzi_objectFromDictionary:value inContext:context];
        if ( importedObject != nil ) {
            [self setValue:importedObject forKey:relationshipInfo.sourcePropertyName];
        }
        else {
            RZVLogError(@"Unable to import object for relationship \"%@\" on entity \"%@\" from value:\n%@",
                        relationshipInfo.sourcePropertyName,
                        relationshipInfo.sourceEntityName,
                        value);
        }
    }
}

+ (void)rzv_logUniqueObjectsWarning
{
    rzv_performBlockAtomically(NO, ^{
        
        static NSMutableSet *s_cachedNonUniqueableClasses = nil;
        static dispatch_once_t onceToken;
        dispatch_once(&onceToken, ^{
            s_cachedNonUniqueableClasses = [NSMutableSet set];
        });
        
        if ( ![s_cachedNonUniqueableClasses containsObject:NSStringFromClass(self)] ) {
            [s_cachedNonUniqueableClasses addObject:NSStringFromClass(self)];
            RZVLogInfo(@"Class %@ for entity %@ does not provide a primary key, so it is not possible to find an existing instance to update. A new instance is being created in the database. If new instances of this entity should be created for every import, override +rzv_shouldAlwaysCreateNewObjectOnImport to return YES in order to suppress this message.", NSStringFromClass(self), [self rzv_entityName] );
        }
    });
}

@end
