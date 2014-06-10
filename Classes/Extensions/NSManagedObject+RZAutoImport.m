//
//  NSManagedObject+RZAutoImport.m
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


#import "NSManagedObject+RZAutoImport.h"
#import "NSObject+RZAutoImport_private.h"
#import "NSManagedObject+RZVinylRecord.h"
#import "NSManagedObject+RZAutoImportableSubclass.h"
#import "NSManagedObject+RZVinylRecord_private.h"
#import "NSFetchRequest+RZVinylRecord.h"
#import "RZVinylRelationshipInfo.h"
#import "RZVinylDefines.h"

//
// Implementation
//

@implementation NSManagedObject (RZAutoImport)

//!!!: Overridden to support default context
+ (instancetype)rzai_objectFromDictionary:(NSDictionary *)dict withMappings:(NSDictionary *)mappings
{
    NSManagedObjectContext *context = [[self rzv_validCoreDataStack] mainManagedObjectContext];
    return [self rzai_objectFromDictionary:dict inContext:context];
}

//!!!: Overridden to support default context
+ (NSArray *)rzai_objectsFromArray:(NSArray *)array withMappings:(NSDictionary *)mappings
{
    NSManagedObjectContext *context = [[self rzv_validCoreDataStack] mainManagedObjectContext];
    return [self rzai_objectsFromArray:array inContext:context];
}

+ (instancetype)rzai_objectFromDictionary:(NSDictionary *)dict inContext:(NSManagedObjectContext *)context
{
    return [self rzai_objectFromDictionary:dict inContext:context withMappings:nil];
}

+ (instancetype)rzai_objectFromDictionary:(NSDictionary *)dict inContext:(NSManagedObjectContext *)context withMappings:(NSDictionary *)mappings
{
    if ( !RZVParameterAssert(context) ) {
        return nil;
    }
    
    NSMutableDictionary *extraMappings = (mappings != nil) ? [mappings mutableCopy] : [NSMutableDictionary dictionary];
    if ( [self rzai_primaryKeyMapping] ) {
        [extraMappings addEntriesFromDictionary:[self rzai_primaryKeyMapping]];
    }
    
    //!!!: If there is a context in the current thread dictionary, then this is a nested call to this method.
    //     In that case, do not modify the thread dictionary.
    BOOL nestedCall = ([self rzv_currentThreadImportContext] != nil);
    if ( !nestedCall ){
        [self rzai_setCurrentThreadImportContext:context];
    }
    id object = [super rzai_objectFromDictionary:dict withMappings:extraMappings];
    if ( !nestedCall ) {
        [self rzai_setCurrentThreadImportContext:nil];
    }
    return object;
}

+ (NSArray *)rzai_objectsFromArray:(NSArray *)array inContext:(NSManagedObjectContext *)context
{
    return [self rzai_objectsFromArray:array inContext:context withMappings:nil];
}

+ (NSArray *)rzai_objectsFromArray:(NSArray *)array inContext:(NSManagedObjectContext *)context withMappings:(NSDictionary *)mappings
{
    if ( !RZVParameterAssert(context) ) {
        return nil;
    }
    
    NSMutableDictionary *extraMappings = (mappings != nil) ? [mappings mutableCopy] : [NSMutableDictionary dictionary];
    if ( [self rzai_primaryKeyMapping] ) {
        [extraMappings addEntriesFromDictionary:[self rzai_primaryKeyMapping]];
    }
    
    //!!!: If there is a context in the current thread dictionary, then this is a nested call to this method.
    //     In that case, do not modify the thread dictionary.
    BOOL nestedCall = ( [self rzv_currentThreadImportContext] != nil );
    if ( !nestedCall ){
        [self rzai_setCurrentThreadImportContext:context];
    }

    NSArray *objects = nil;

    if ( array.count == 1 ) {
        id importedObject = [super rzai_objectFromDictionary:array[0] withMappings:extraMappings];
        if ( importedObject ) {
            objects = @[importedObject];
        }
    }
    else if ( [self rzv_primaryKey] != nil ) {
    
        NSMutableArray *updatedObjects = [NSMutableArray array];
        
        NSString *externalPrimaryKey = [self rzv_externalPrimaryKey] ?: [self rzv_primaryKey];
        
        // Pre-fetch all objects that have a primary key in the set of objects being imported
        NSDictionary *existingObjectsByID = [self rzai_existingObjectsByIDForArray:array inContext:context];
        [array enumerateObjectsUsingBlock:^(NSDictionary *rawDict, NSUInteger idx, BOOL *stop) {
            id importedObject = nil;
            id primaryValue = [rawDict objectForKey:externalPrimaryKey];
            
            if ( primaryValue != nil ) {
                importedObject = [existingObjectsByID objectForKey:primaryValue];
            }
            
            if ( importedObject == nil ) {
                importedObject = [super rzai_objectFromDictionary:rawDict withMappings:extraMappings];
            }
            else {
                [importedObject rzai_importValuesFromDict:rawDict withMappings:extraMappings];
            }
            
            if ( importedObject != nil ) {
                [updatedObjects addObject:importedObject];
            }
        }];
        
        objects = [NSArray arrayWithArray:updatedObjects];
    }
    else {
        // Default to creating new object instances.
        objects = [super rzai_objectsFromArray:array];
    }
    
    if ( !nestedCall ) {
        [self rzai_setCurrentThreadImportContext:nil];
    }
    return objects;
}

#pragma mark - RZAutoImportablej

+ (id)rzai_existingObjectForDict:(NSDictionary *)dict
{
    NSManagedObjectContext *context = [self rzv_currentThreadImportContext];
    return [self rzai_existingObjectForDict:dict inContext:context];
}

+ (id)rzai_existingObjectForDict:(NSDictionary *)dict inContext:(NSManagedObjectContext *)context
{
    if ( !RZVParameterAssert(context) ){
        RZVLogError(@"This thread does not have an associated managed object context at the moment, and that's a problem.");
        return nil;
    }
    
    id object = nil;
    NSString *externalPrimaryKey = [self rzv_externalPrimaryKey] ?: [self rzv_primaryKey];
    id primaryValue = externalPrimaryKey ? [dict objectForKey:externalPrimaryKey] : nil;
    if ( primaryValue != nil ) {
        object = [self rzv_objectWithPrimaryKeyValue:primaryValue createNew:YES inContext:context];
    }
    else {
        RZVLogInfo(@"Class %@ for entity %@ does not provide a primary key and cannot be uniqued. Creating new instance...", NSStringFromClass(self), [self rzv_entityName] );
        object = [self rzv_newObjectInContext:context];
    }
    
    return object;
}

- (BOOL)rzai_shouldImportValue:(id)value forKey:(NSString *)key
{
    NSManagedObjectContext *context = [[self class] rzv_currentThreadImportContext];
    return [self rzai_shouldImportValue:value forKey:key inContext:context];
}

- (BOOL)rzai_shouldImportValue:(id)value forKey:(NSString *)key inContext:(NSManagedObjectContext *)context
{
    if ( !RZVParameterAssert(context) ){
        RZVLogError(@"This thread does not have an associated managed object context at the moment, and that's a problem.");
        return NO;
    }
    
    __block BOOL shouldImport = YES;
    RZAIPropertyInfo *propInfo = [[self class] rzai_propertyInfoForExternalKey:key withMappings:nil];
    if ( propInfo != nil && (propInfo.dataType == RZAutoImportDataTypeOtherObject || propInfo.dataType == RZAutoImportDataTypeNSSet) ) {

        // Check cached relationship mapping info. If collection type matches, perform automatic relationship import
        __block RZVinylRelationshipInfo *relationshipInfo = nil;
        
        // !!!: This needs to be done in a thread-safe way - the cache is mutable state
        rzv_performBlockAtomically(^{
            relationshipInfo = [[self class] rzai_relationshipInfoForKey:key];
        });
        
        if ( relationshipInfo != nil ) {
            [self rzai_performRelationshipImportWithValue:value forRelationship:relationshipInfo];
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

+ (void)rzai_setCurrentThreadImportContext:(NSManagedObjectContext *)context
{
    if ( context ) {
        [[[NSThread currentThread] threadDictionary] setObject:context forKey:kRZVinylImportThreadContextKey];
    }
    else {
        [[[NSThread currentThread] threadDictionary] removeObjectForKey:kRZVinylImportThreadContextKey];
    }
}

+ (NSDictionary *)rzai_primaryKeyMapping
{
    NSString *primaryKey = [self rzv_primaryKey];
    NSString *externalPrimaryKey = [self rzv_externalPrimaryKey];
    if ( primaryKey != nil && externalPrimaryKey != nil ) {
        return @{ externalPrimaryKey : primaryKey };
    }
    
    // If no external primary key, then the external key is assumed to match
    return nil;

}

+ (RZVinylRelationshipInfo *)rzai_relationshipInfoForKey:(NSString *)key
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
    
    RZAIPropertyInfo *propInfo = [self rzai_propertyInfoForExternalKey:key withMappings:nil];
    
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

+ (NSDictionary *)rzai_existingObjectsByIDForArray:(NSArray *)array inContext:(NSManagedObjectContext *)context
{
    NSString *primaryKey = [self rzv_primaryKey];
    NSString *externalPrimaryKey = [self rzv_externalPrimaryKey] ?: primaryKey;
    
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

- (void)rzai_performRelationshipImportWithValue:(id)value forRelationship:(RZVinylRelationshipInfo *)relationshipInfo
{
    if ( !RZVParameterAssert(relationshipInfo) ) {
        return;
    }
    
    NSManagedObjectContext *context = [[self class] rzv_currentThreadImportContext];
    if ( !RZVAssert(context != nil, @"There should be a current thread import context.") ) {
        return;
    }
    
    if ( value == nil ) {
        [self rzai_setNilForPropertyNamed:relationshipInfo.sourcePropertyName];
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
        NSArray *importedObjects = [relationshipInfo.destinationClass rzai_objectsFromArray:rawObjects inContext:context];
        if ( importedObjects != nil ) {
            [self setValue:[NSSet setWithArray:importedObjects] forKey:relationshipInfo.sourcePropertyName];
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
        
        id importedObject = [relationshipInfo.destinationClass rzai_objectFromDictionary:value inContext:context];
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

@end
