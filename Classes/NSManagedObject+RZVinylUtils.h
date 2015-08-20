//
//  NSManagedObject+RZVinylUtils.h
//  RZVinyl
//
//  Created by Nick Donaldson on 7/21/14.
//

@import CoreData;
#import "RZCompatibility.h"

@interface NSManagedObject (RZVinylUtils)

/**
 *  Get the same object as the receiver in another managed object context, if it exists.
 *  If the context is the same as the receiver's, it just returns itself.
 *
 *  @param context The context from which to get the object. Must not be nil.
 *
 *  @warning If the receiver has not been saved yet, this will fail and return nil.
 *
 *  @return The same object as the receiver from a different context, or nil if not found.
 */
- (instancetype RZNullable)rzv_objectInContext:(NSManagedObjectContext* RZNonnull)context;

/**
 *  The entity name of the Core Data entity represented by this class.
 *
 *  @return The entity name.
 */
+ (NSString* RZNonnull)rzv_entityName;

@end
