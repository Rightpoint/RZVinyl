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
//  "Software"), to deal in the Software without restriction, including
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
#import "NSManagedObject+RZImportableSubclass.h"
#import "NSManagedObject+RZVinylRecord_private.h"
#import "NSManagedObjectContext+RZImport.h"
#import "NSManagedObjectContext+RZImport_private.h"
#import "NSFetchRequest+RZVinylRecord.h"
#import "RZVinylRelationshipInfo.h"
#import "RZVinylDefines.h"

//
// Implementation
//

@implementation NSManagedObject (RZImport)

+ (instancetype)rzi_objectFromDictionary:(NSDictionary *)dict withMappings:(NSDictionary *)mappings
{
    return [super rzi_objectFromDictionary:dict withMappings:mappings];
}

+ (NSArray *)rzi_objectsFromArray:(NSArray *)array withMappings:(NSDictionary *)mappings
{
    NSString *externalPrimaryKey = [self rzv_externalPrimaryKey];
    mappings = [self rzi_primaryKeyMappingsDictWithMappings:mappings];

    if ( externalPrimaryKey != nil ) {
        NSManagedObjectContext *context = [NSManagedObjectContext rzi_currentThreadImportContext];
        // Check to see if the cache is enabled prior to lookup.
        BOOL cacheEnabled = [context rzi_isCacheEnabledForEntity:self];
        NSMutableDictionary *lookup = nil;

        if ( cacheEnabled == NO ) {
            lookup = [NSMutableDictionary dictionary];
            // Load the cache with the import data.
            NSString *primaryKey = [self rzv_primaryKey];

            // Determine the primary keys by the external key, and remove duplicates
            NSArray *keyValues = [array valueForKey:externalPrimaryKey];
            NSSet *missingKeyValues = [NSSet setWithArray:keyValues];

            // If keys do not have objects and cache is not enabled for this entity, look them up
            if ( missingKeyValues.count > 0 ) {
                NSPredicate *predicate = [NSPredicate predicateWithFormat:@"%K in %@",
                                          [self rzv_primaryKey],
                                          missingKeyValues];

                for ( id object in [self rzv_where:predicate inContext:context] ) {
                    id keyValue = [object valueForKey:primaryKey];
                    [lookup setObject:object forKey:keyValue];
                }
            }
        }

        NSMutableArray *results = [NSMutableArray array];
        [array enumerateObjectsUsingBlock:^(NSDictionary *dictionary, NSUInteger idx, BOOL *stop) {
            id primaryKeyValue = [dictionary objectForKey:externalPrimaryKey];
            primaryKeyValue = primaryKeyValue ?: [NSNull null];

            if ( [primaryKeyValue isEqual:[NSNull null]] ) {
                [self rzv_logMissingPrimaryKey];
            }
            id importedObject = nil;
            if ( cacheEnabled ) {
                importedObject = [context rzi_cachedObjectForKeysInDictionary:dictionary entity:self];
            }
            else {
                importedObject = lookup[primaryKeyValue];
            }
            if ( importedObject == nil ) {
                importedObject = [self rzv_newObjectInContext:context];
                if ( ![primaryKeyValue isEqual:[NSNull null]] ) {
                    [importedObject setValue:primaryKeyValue forKey:[self rzv_primaryKey]];
                }
                if ( cacheEnabled ) {
                    [context rzi_cacheObjects:@[importedObject] forEntity:self];
                }
                else {
                    [lookup setObject:importedObject forKey:primaryKeyValue];
                }
            }

            [importedObject rzi_importValuesFromDict:dictionary withMappings:mappings];
            [results addObject:importedObject];
        }];
        return results;
    }
    else {
        // Default to creating new object instances.
        return [super rzi_objectsFromArray:array withMappings:mappings];
    }
}

- (void)rzi_importValuesFromDict:(NSDictionary *)dict withMappings:(NSDictionary *)mappings
{
    mappings = [[self class] rzi_primaryKeyMappingsDictWithMappings:mappings];

    [self.managedObjectContext rzi_performImport:^{
        [super rzi_importValuesFromDict:dict withMappings:mappings];
    }];
}

#pragma mark - RZImportable

+ (instancetype)rzi_existingObjectForDict:(NSDictionary *)dict
{
    NSManagedObjectContext *context = [NSManagedObjectContext rzi_currentThreadImportContext];
    id object = [self rzi_existingObjectForDict:dict inContext:context];
    return object;
}

+ (id)rzi_existingObjectForDict:(NSDictionary *)dict
                      inContext:(NSManagedObjectContext *)context
{
    if ( [self rzv_shouldAlwaysCreateNewObjectOnImport] ) {
        return [self rzv_newObjectInContext:context];
    }
    
    id existingObject = nil;
    NSString *externalPrimaryKey = [self rzv_externalPrimaryKey];
    if ( externalPrimaryKey == nil ) {
        [self rzv_logUniqueObjectsWarning];
    }

    id primaryKeyValue = externalPrimaryKey ? [dict objectForKey:externalPrimaryKey] : nil;
    primaryKeyValue = primaryKeyValue ?: [NSNull null];
    
    if ( [context rzi_isCacheEnabledForEntity:self] ) {
        existingObject = [context rzi_cachedObjectForKeysInDictionary:dict entity:self];
        if ( existingObject == nil ) {
            existingObject = [self rzv_newObjectInContext:context];
            if ( [primaryKeyValue isEqual:[NSNull null]] ) {
                [self rzv_logMissingPrimaryKey];
            }
            else {
                [existingObject setValue:primaryKeyValue forKey:[self rzv_primaryKey]];
            }
            [context rzi_cacheObjects:@[existingObject] forEntity:self];
        }
    }
    else {
        if ( ![primaryKeyValue isEqual:[NSNull null]] ) {
            existingObject = [self rzv_objectWithPrimaryKeyValue:primaryKeyValue createNew:YES inContext:context];
        }
        else {
            existingObject = [self rzv_newObjectInContext:context];
            [self rzv_logMissingPrimaryKey];
        }
    }

    return existingObject;
}

- (BOOL)rzi_shouldImportValue:(id)value forKey:(NSString *)key
{
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

#pragma mark - inContext Helpers

+ (instancetype)rzi_objectFromDictionary:(NSDictionary *)dict
                               inContext:(NSManagedObjectContext*)context
{
    __block id object = nil;
    [context rzi_performImport:^{
        object = [self rzi_objectFromDictionary:dict];
    }];
    return object;
}

+ (instancetype)rzi_objectFromDictionary:(NSDictionary *)dict
                               inContext:(NSManagedObjectContext *)context
                            withMappings:(NSDictionary *)mappings
{
    __block id object = nil;
    [context rzi_performImport:^{
        object = [self rzi_objectFromDictionary:dict withMappings:mappings];
    }];
    return object;
}

+ (NSArray *)rzi_objectsFromArray:(NSArray *)array
                        inContext:(NSManagedObjectContext *)context
{
    __block NSArray *results = nil;
    [context rzi_performImport:^{
        results = [self rzi_objectsFromArray:array];
    }];
    return results;
}

+ (NSArray*)rzi_objectsFromArray:(NSArray *)array
                       inContext:(NSManagedObjectContext *)context
                    withMappings:(NSDictionary *)mappings
{
    __block NSArray *results = nil;
    [context rzi_performImport:^{
        results = [self rzi_objectsFromArray:array withMappings:mappings];
    }];
    return results;
}

#pragma mark - Private

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
    NSString *primaryKey = [self rzv_primaryKey];
    NSString *externalPrimaryKey = [self rzv_externalPrimaryKey];
    if ( primaryKey != nil && externalPrimaryKey != nil && ![primaryKey isEqual:externalPrimaryKey] ) {
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
        NSManagedObjectContext *context = [NSManagedObjectContext rzi_currentThreadImportContext];
        NSManagedObjectModel *model = [[context persistentStoreCoordinator] managedObjectModel];
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

- (void)rzi_performRelationshipImportWithValue:(id)value forRelationship:(RZVinylRelationshipInfo *)relationshipInfo
{
    if ( !RZVParameterAssert(relationshipInfo) ) {
        return;
    }
    
    NSManagedObjectContext *context = [NSManagedObjectContext rzi_currentThreadImportContext];
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
        NSArray *importedObjects = [relationshipInfo.destinationClass rzi_objectsFromArray:rawObjects];
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
        
        id importedObject = [relationshipInfo.destinationClass rzi_objectFromDictionary:value];
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

+ (void)rzv_logMissingPrimaryKey
{
    rzv_performBlockAtomically(NO, ^{

        static NSMutableSet *s_cachedMissingKeyClasses = nil;
        static dispatch_once_t onceToken;
        dispatch_once(&onceToken, ^{
            s_cachedMissingKeyClasses = [NSMutableSet set];
        });

        if ( ![s_cachedMissingKeyClasses containsObject:NSStringFromClass(self)] ) {
            [s_cachedMissingKeyClasses addObject:NSStringFromClass(self)];
            RZVLogInfo(@"Class %@ for entity %@ provides a primary key, but the imported primary key value is nil. This will create a new object every time.", NSStringFromClass(self), [self rzv_entityName] );
        }
    });
}

@end

@implementation NSManagedObject (RZImportDeprecated)

- (BOOL)rzi_shouldImportValue:(id)value forKey:(NSString *)key inContext:(NSManagedObjectContext *)context
{
    return [self rzi_shouldImportValue:value forKey:key];
}

- (void)rzi_importValuesFromDict:(NSDictionary *)dict inContext:(NSManagedObjectContext *)context
{
    [self rzi_importValuesFromDict:dict];
}

- (void)rzi_importValuesFromDict:(NSDictionary *)dict
                       inContext:(NSManagedObjectContext *)context
                    withMappings:(NSDictionary *)mappings
{
    [self rzi_importValuesFromDict:dict withMappings:mappings];
}

@end
