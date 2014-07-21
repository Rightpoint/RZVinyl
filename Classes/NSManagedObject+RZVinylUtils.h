//
//  NSManagedObject+RZVinylUtils.h
//  Pods
//
//  Created by Nick Donaldson on 7/21/14.
//
//

@import CoreData;

@interface NSManagedObject (RZVinylUtils)

/**
 *  Get the same object as the receiver in another managed object context, if it exists.
 *  If the context is the same as the receiver's, it just returns itself.
 *
 *  @param context The context from which to get the object. Must not be nil.
 *
 *  @return The same object as the receiver from a different context, or nil if not found.
 */
- (instancetype)rzv_objectInContext:(NSManagedObjectContext *)context;

/**
 *  The entity name of the Core Data entity represented by this class.
 *
 *  @return The entity name.
 */
+ (NSString *)rzv_entityName;

@end
