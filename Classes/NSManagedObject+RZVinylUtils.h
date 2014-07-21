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
 *  The entity name of the Core Data entity represented by this class.
 *
 *  @return The entity name.
 */
+ (NSString *)rzv_entityName;

@end
