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
    
    if ( context == self.managedObjectContext ) {
        return self;
    }
    
    if ( [self.objectID isTemporaryID] ) {
        if ( self.managedObjectContext ) {
            NSError *permanentObjErr = nil;
            if ( ![self.managedObjectContext obtainPermanentIDsForObjects:@[self] error:&permanentObjErr] ) {
                RZVLogError(@"Error getting permanent object ID: %@", permanentObjErr);
                return nil;
            }
        }
        else {
            RZVLogError(@"Cannot get object %@ from other context if it has not been inserted yet.", self);
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
    RZCoreDataStack *stack = [self rzv_validCoreDataStack];
    if ( stack == nil ){
        return nil;
    }
    NSString *className = NSStringFromClass(self);
    for ( NSEntityDescription *entity in stack.managedObjectModel.entities ) {
        if ( [entity.managedObjectClassName isEqualToString:className] ) {
            return entity.name;
        }
    }
    return nil;
}


#pragma mark - Private

@end
