//
//  NSManagedObject+RZVinylRecord.m
//  RZVinylDemo
//
//  Created by Nick Donaldson on 6/4/14.
//  Copyright (c) 2014 Raizlabs. All rights reserved.
//

#import "NSManagedObject+RZVinylRecord.h"
#import "RZCoreDataStack.h"
#import "RZVinylDefines.h"

@implementation NSManagedObject (RZVinylRecord)

#pragma mark - Creation

+ (instancetype)rzv_objectWithPrimaryKeyValue:(id)primaryValue createNew:(BOOL)createNew
{
    RZCoreDataStack *stack = [self rzv_coreDataStack];
    if ( !RZVAssert(stack != nil, @"No core data stack provided for class %@. Ensure that +rzv_coreDataStack is returning a valid instance.", NSStringFromClass(self)) ) {
        return nil;
    }
    
    return [self rzv_objectWithPrimaryKeyValue:primaryValue createNew:createNew inContext:[stack currentThreadContext]];
}

+ (instancetype)rzv_objectWithPrimaryValue:(id)primaryValue createNew:(BOOL)createNew inContext:(NSManagedObjectContext *)context
{
    if ( !RZVParameterAssert(primaryValue) || !RZVParameterAssert(context) ) {
        return nil;
    }

    NSString *primaryKey = [self rzv_primaryKey];
    if ( !RZVAssert(primaryKey != nil, @"No primary key provided for class %@. Ensure that +rzv_primaryKey is overridden and returning a valid key.", NSStringFromClass(self)) ) {
        return nil;
    }

    id object = [[self rzv_where:[NSString stringWithFormat:@"%@ == %@", primaryKey, primaryValue]] lastObject];
    if ( object == nil && createNew ) {
        object = [NSEntityDescription insertNewObjectForEntityForName:[self rzv_entityName] inManagedObjectContext:context];
        [object setValue:primaryValue forKeyPath:primaryKey];
    }
    
    return object;
}

#pragma mark - Query/Fetch

+ (NSArray *)rzv_where:(NSString *)predicateQuery
{
    return [self rzv_where:predicateQuery withSortDescriptors:nil];
}

+ (NSArray *)rzv_where:(NSString *)predicateQuery withSortDescriptors:(NSArray *)sortDescriptors
{
    RZCoreDataStack *stack = [self rzv_coreDataStack];
    if ( !RZVAssert(stack != nil, @"No core data stack provided for class %@. Ensure that +rzv_coreDataStack is returning a valid instance.", NSStringFromClass(self)) ) {
        return nil;
    }
    
    return [self rzv_where:predicateQuery withSortDescriptors:sortDescriptors inContext:[stack currentThreadContext]];
}

+ (NSArray *)rzv_where:(NSString *)predicateQuery withSortDescriptors:(NSArray *)sortDescriptors inContext:(NSManagedObjectContext *)context
{
    if ( !RZVParameterAssert(predicateQuery) ) {
        return nil;
    }
    
    NSPredicate *predicate = [NSPredicate predicateWithFormat:predicateQuery];
    if ( !RZVAssert(predicate, @"Malformed predicate: %@", predicateQuery) ) {
        return nil;
    }
    
    NSFetchRequest *fetch = [self rzv_fetchRequestWithPredicate:predicate sort:sortDescriptors inContext:context];
    NSError *error = nil;
    NSArray *fetchedObjects = [context executeFetchRequest:fetch error:&error];
    if ( error ) {
        RZVLogError(@"Error performing fetch: %@", error);
    }
    return fetchedObjects;
}

#pragma makr - MetaData

+ (NSString *)rzv_entityName
{
    __block NSString *entityName = nil;
    
    // synchronize mutable dict access by dispatching to main thread
    if ( [NSThread isMainThread] ) {
        entityName = [self rzv_cachedEntityName];
    }
    else {
        dispatch_async(dispatch_get_main_queue(), ^{
            entityName = [self rzv_cachedEntityName];
        });
    }

    return entityName;
}

#pragma mark - Subclassable

+ (NSString *)rzv_primaryKey
{
    return nil;
}

+ (RZCoreDataStack *)rzv_coreDataStack
{
    return [RZCoreDataStack defaultStack];
}

#pragma mark - Private

+ (NSMutableDictionary *)rzv_s_cachedEntityNames
{
    static NSMutableDictionary *s_entityNames = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        s_entityNames = [NSMutableDictionary dictionary];
    });
    return s_entityNames;
}

+ (NSString *)rzv_cachedEntityName
{
    RZCoreDataStack *stack = [self rzv_coreDataStack];
    if ( !RZVAssert(stack != nil, @"No core data stack provided for class %@. Ensure that +rzv_coreDataStack is returning a valid instance.", NSStringFromClass(self)) ) {
        return nil;
    }
    
    NSString *className = NSStringFromClass(self);
    __block NSString *entityName = [[self rzv_s_cachedEntityNames] objectForKey:className];
    if ( entityName == nil ) {
        [[stack.managedObjectModel entities] enumerateObjectsUsingBlock:^(NSEntityDescription *entity, NSUInteger idx, BOOL *stop) {
            if ( [entity.managedObjectClassName isEqualToString:className] ) {
                entityName = entity.name;
                *stop = YES;
            }
        }];
        if ( entityName ) {
            [[self rzv_s_cachedEntityNames] setObject:entityName forKey:className];
        }
    }
    return entityName;
}

+ (NSFetchRequest *)rzv_fetchRequestWithPredicate:(NSPredicate *)predicate sort:(NSArray *)sortDescriptors inContext:(NSManagedObjectContext *)context
{
    NSFetchRequest *fetchRequest = [[NSFetchRequest alloc] init];
    NSEntityDescription *entity = [NSEntityDescription entityForName:[self rzv_entityName] inManagedObjectContext:context];
    [fetchRequest setEntity:entity];

    if ( predicate ) {
        [fetchRequest setPredicate:predicate];
    }
    
    if ( sortDescriptors ) {
        [fetchRequest setSortDescriptors:sortDescriptors];
    }

    return fetchRequest;
}

@end