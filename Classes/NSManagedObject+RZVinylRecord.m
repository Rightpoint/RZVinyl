//
//  NSManagedObject+RZVinylRecord.m
//  RZVinyl
//
//  Created by Nick Donaldson on 6/4/14.
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


#import "NSManagedObject+RZVinylRecord.h"
#import "NSManagedObject+RZVinylUtils.h"
#import "NSFetchRequest+RZVinylRecord.h"
#import "RZCoreDataStack.h"
#import "RZVinylDefines.h"

@implementation NSManagedObject (RZVinylRecord)

#pragma mark - Creation

+ (instancetype)rzv_newObject
{
    if ( !RZVAssertMainThread() ) {
        return nil;
    }
    RZCoreDataStack *stack = [self rzv_validCoreDataStack];
    if ( stack == nil ){
        return nil;
    }
    return [self rzv_newObjectInContext:[stack mainManagedObjectContext]];
}

+ (instancetype)rzv_newObjectInContext:(NSManagedObjectContext *)context
{
    if ( !RZVParameterAssert(context) ) {
        return nil;
    }
    return [NSEntityDescription insertNewObjectForEntityForName:[self rzv_entityName] inManagedObjectContext:context];
}

+ (instancetype)rzv_objectWithPrimaryKeyValue:(id)primaryValue createNew:(BOOL)createNew
{
    if ( !RZVAssertMainThread() ) {
        return nil;
    }
    RZCoreDataStack *stack = [self rzv_validCoreDataStack];
    if ( stack == nil ){
        return nil;
    }
    return [self rzv_objectWithPrimaryKeyValue:primaryValue createNew:createNew inContext:[stack mainManagedObjectContext]];
}

+ (instancetype)rzv_objectWithPrimaryKeyValue:(id)primaryValue createNew:(BOOL)createNew inContext:(NSManagedObjectContext *)context
{
    if ( !RZVParameterAssert(primaryValue) || !RZVParameterAssert(context) ) {
        return nil;
    }

    NSString *primaryKey = [self rzv_primaryKey];
    if ( !RZVAssert(primaryKey != nil, @"No primary key provided for class %@. Ensure that +rzv_primaryKey is overridden and returning a valid key.", NSStringFromClass(self)) ) {
        return nil;
    }

    id object = [[self rzv_where:[NSPredicate predicateWithFormat:@"%K == %@", primaryKey, primaryValue] inContext:context] lastObject];
    if ( object == nil && createNew ) {
        object = [self rzv_newObjectInContext:context];
        [object setValue:primaryValue forKeyPath:primaryKey];
    }
    
    return object;
}

+ (instancetype)rzv_objectWithAttributes:(NSDictionary *)attributes createNew:(BOOL)createNew
{
    if ( !RZVAssertMainThread() ) {
        return nil;
    }
    RZCoreDataStack *stack = [self rzv_validCoreDataStack];
    if ( stack == nil ){
        return nil;
    }
    return [self rzv_objectWithAttributes:attributes createNew:createNew inContext:[stack mainManagedObjectContext]];
}

+ (instancetype)rzv_objectWithAttributes:(NSDictionary *)attributes createNew:(BOOL)createNew inContext:(NSManagedObjectContext *)context
{
    if ( !RZVParameterAssert(attributes) || !RZVParameterAssert(context) ) {
        return nil;
    }
    
    NSMutableArray *predicates = [NSMutableArray array];
    [attributes enumerateKeysAndObjectsUsingBlock:^(NSString *key, id value, BOOL *stop) {
        [predicates addObject:[NSPredicate predicateWithFormat:@"%K == %@", key, value]];
    }];
    
    NSFetchRequest *fetch = [NSFetchRequest rzv_forEntity:[self rzv_entityName]
                                                inContext:context
                                                    predicate:[NSCompoundPredicate andPredicateWithSubpredicates:predicates]
                                                     sort:nil];
    NSError *error = nil;
    id result = [[context executeFetchRequest:fetch error:&error] lastObject];
    if ( error ) {
        RZVLogError(@"Error performing fetch: %@", error);
    }
    else if ( result == nil && createNew ) {
        result = [self rzv_newObjectInContext:context];
        [result setValuesForKeysWithDictionary:attributes];
    }
    return result;
}

#pragma mark - Query/Fetch

+ (NSArray *)rzv_all
{
    if ( !RZVAssertMainThread() ) {
        return [NSArray array];
    }
    return [self rzv_where:nil];
}

+ (NSArray *)rzv_allInContext:(NSManagedObjectContext *)context
{
    return [self rzv_where:nil sort:nil inContext:context];
}

+ (NSArray *)rzv_allSorted:(NSArray *)sortDescriptors
{
    if ( !RZVAssertMainThread() ) {
        return [NSArray array];
    }
    return [self rzv_where:nil sort:sortDescriptors];
}

+ (NSArray *)rzv_allSorted:(NSArray *)sortDescriptors inContext:(NSManagedObjectContext *)context
{
    return [self rzv_where:nil sort:sortDescriptors inContext:context];
}

+ (NSArray *)rzv_where:(NSPredicate *)predicate
{
    if ( !RZVAssertMainThread() ) {
        return [NSArray array];
    }
    return [self rzv_where:predicate sort:nil];
}

+ (NSArray *)rzv_where:(NSPredicate *)predicate inContext:(NSManagedObjectContext *)context
{
    return [self rzv_where:predicate sort:nil inContext:context];
}

+ (NSArray *)rzv_where:(NSPredicate *)predicate sort:(NSArray *)sortDescriptors
{
    if ( !RZVAssertMainThread() ) {
        return [NSArray array];
    }
    RZCoreDataStack *stack = [self rzv_validCoreDataStack];
    if ( stack == nil ){
        return [NSArray array];
    }
    return [self rzv_where:predicate sort:sortDescriptors inContext:[stack mainManagedObjectContext]];
}

+ (NSArray *)rzv_where:(NSPredicate *)predicate sort:(NSArray *)sortDescriptors inContext:(NSManagedObjectContext *)context
{
    NSError *error = nil;
    NSFetchRequest *fetch = [NSFetchRequest rzv_forEntity:[self rzv_entityName]
                                                inContext:context
                                                    predicate:predicate
                                                     sort:sortDescriptors];
    
    NSArray *fetchedObjects = [context executeFetchRequest:fetch error:&error];
    if ( error ) {
        RZVLogError(@"Error performing fetch: %@", error);
    }
    return fetchedObjects;
}

#pragma mark - Count

+ (NSUInteger)rzv_count
{
    if ( !RZVAssertMainThread() ) {
        return 0;
    }
    return [self rzv_countWhere:nil];
}

+ (NSUInteger)rzv_countInContext:(NSManagedObjectContext *)context
{
    return [self rzv_countWhere:nil inContext:context];
}

+ (NSUInteger)rzv_countWhere:(NSPredicate *)predicate
{
    if ( !RZVAssertMainThread() ) {
        return 0;
    }
    RZCoreDataStack *stack = [self rzv_validCoreDataStack];
    if ( stack == nil ){
        return 0;
    }
    return [self rzv_countWhere:predicate inContext:[stack mainManagedObjectContext]];
}

+ (NSUInteger)rzv_countWhere:(NSPredicate *)predicate inContext:(NSManagedObjectContext *)context
{
    NSFetchRequest *fetch = [NSFetchRequest rzv_forEntity:[self rzv_entityName]
                                                inContext:context
                                                    predicate:predicate
                                                     sort:nil];
    
    [fetch setResultType:NSCountResultType];
    
    NSError *err = nil;
    NSUInteger count = [context countForFetchRequest:fetch error:&err];
    if ( err ) {
        RZVLogError(@"Error getting count of objects for entity %@: %@", [self rzv_entityName], err);
    }
    return count;
}

#pragma mark - Delete

- (void)rzv_delete
{
    if ( self.managedObjectContext ) {
        [self.managedObjectContext deleteObject:self];
    }
    else {
        RZVLogInfo(@"Object %@ was not deleted because it is not inserted in a context.", self);
    }
}

+ (void)rzv_deleteAll
{
    if ( !RZVAssertMainThread() ) {
        return;
    }
    [self rzv_deleteAllWhere:nil];
}

+ (void)rzv_deleteAllInContext:(NSManagedObjectContext *)context
{
    [self rzv_deleteAllWhere:nil inContext:context];
}

+ (void)rzv_deleteAllWhere:(NSPredicate *)predicate
{
    if ( !RZVAssertMainThread() ) {
        return;
    }
    RZCoreDataStack *stack = [self rzv_validCoreDataStack];
    if ( stack == nil ) {
        return;
    }
    [self rzv_deleteAllWhere:predicate inContext:[stack mainManagedObjectContext]];
}

+ (void)rzv_deleteAllWhere:(NSPredicate *)predicate inContext:(NSManagedObjectContext *)context
{
    if ( !RZVParameterAssert(context) ) {
        return;
    }
    
    [[self rzv_where:predicate sort:nil inContext:context] enumerateObjectsUsingBlock:^(id obj, NSUInteger idx, BOOL *stop) {
        [context deleteObject:obj];
    }];
}

#pragma mark - Subclassable

+ (NSPredicate *)rzv_stalenessPredicate
{
    return nil;
}

+ (NSString *)rzv_primaryKey
{
    return nil;
}

+ (RZCoreDataStack *)rzv_coreDataStack
{
    return [RZCoreDataStack defaultStack];
}

+ (RZCoreDataStack *)rzv_validCoreDataStack
{
    RZCoreDataStack *stack = [self rzv_coreDataStack];
    if ( !RZVAssert(stack != nil, @"No core data stack provided for class %@. Ensure that +rzv_coreDataStack is returning a valid instance.", NSStringFromClass(self)) ) {
        return nil;
    }
    return stack;
}

@end