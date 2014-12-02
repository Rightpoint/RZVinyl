//
//  NSManagedObject+RZVinylUtils.m
//  RZVinyl
//
//  Created by Nick Donaldson on 7/21/14.
//

#import "NSManagedObject+RZVinylUtils.h"
#import "NSManagedObject+RZVinylRecord_private.h"
#import "RZCoreDataStack.h"
#import "RZVinylDefines.h"

@implementation NSManagedObject (RZVinylUtils)

- (instancetype)rzv_objectInContext:(NSManagedObjectContext *)context
{
    if ( !RZVParameterAssert(context) ) {
        return nil;
    }
    
    if ( self.managedObjectContext == nil ) {
        RZVLogError(@"Cannot get object %@ from other context if it has not been inserted yet.", self);
        return nil;
    }
    
    if ( context == self.managedObjectContext ) {
        return self;
    }
    
    if ( [self.objectID isTemporaryID] ) {
        NSError *permanentObjErr = nil;
        if ( ![self.managedObjectContext obtainPermanentIDsForObjects:@[self] error:&permanentObjErr] ) {
            RZVLogError(@"Error getting permanent object ID: %@", permanentObjErr);
            return nil;
        }
    }
    
    NSError *fetchErr = nil;
    NSManagedObject *other = [context existingObjectWithID:self.objectID error:&fetchErr];
    if ( fetchErr != nil ) {
        RZVLogError(@"Error getting object from other context: %@", fetchErr);
        return nil;
    }
    
    return other;
}

+ (NSString *)rzv_entityName
{
    __block NSString *entityName = nil;
    
    // Synchronize mutable dict access by dispatching to main thread
    // Do NOT use rzv_performBlockAtomically: because it does not support reentrancy
    if ( [NSThread isMainThread] ) {
        entityName = [self rzv_cachedEntityName];
    }
    else {
        dispatch_sync(dispatch_get_main_queue(), ^{
            entityName = [self rzv_cachedEntityName];
        });
    }
    
    return entityName;
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
    RZCoreDataStack *stack = [self rzv_validCoreDataStack];
    if ( stack == nil ){
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
        if ( RZVAssert(entityName != nil, @"Could not find entity name for class %@", className) ) {
            [[self rzv_s_cachedEntityNames] setObject:entityName forKey:className];
        }
    }
    return entityName;
}

@end
