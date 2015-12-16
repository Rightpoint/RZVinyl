//
//  RZVinylRip.h
//  Pods
//
//  Created by Connor Smith on 2/6/15.
//
//

#import "RZCompatibility.h"

/**
 *  Methods to optionally implement in @p NSManagedObject subclasses to support @p RZImport extensions.
 */
@protocol RZVinylRip <NSObject>

@optional

/**
 *  Implement in @p NSManagedObject subclasses to provide a key to use for the primary key when importing
 *  values or updating/creating a new instance from an NSDictionary using NSManagedObject+RZImport.
 *
 *  For example, a JSON response might contain key/value pair "ID" : 1000 for the object's primary key,
 *  but your managed object subclass might store this value as an attribute named "remoteID", hence it is
 *  necessary to provide both keys separately to enforce unique instances in the database.
 *
 *  @note Failure to implement (or returning nil, the default) will cause the value of @p +rzv_primaryKey
 *  to be used for the external key as well.
 *
 *  @return The key in dictionary representations whose value uniquely identifies this object.
 */
+ (NSString* RZCNonnull)rzv_externalPrimaryKey;

/**
 *  Implement in @p NSManagedObject subclasses and return @c YES to always create new instances of this object's entity type upon import.
 *  If @c YES is returned, @c +rzv_primaryKey and @c +rzv_externalPrimaryKey will be completely ignored and no
 *  attempt will be made to find and update existing objects matching the dictionary being imported.
 *
 *  @return @c YES to always create new instances on import. Default is @c NO.
 */
+ (BOOL)rzv_shouldAlwaysCreateNewObjectOnImport;

@end
