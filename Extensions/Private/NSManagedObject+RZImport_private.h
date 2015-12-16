//
//  NSManagedObject+RZImport_private.h
//  Pods
//
//  Created by Connor Smith on 2/6/15.
//
//

#import <CoreData/CoreData.h>

@interface NSManagedObject (RZImport_private)

/**
 *  Always call this instead of @p rzv_externalPrimaryKey.
 *  Checks whether the subclass responds to @p rzv_externalPrimaryKey before calling it.
 *
 *  @return The staleness predicate provided by the subclass implementing @p rzv_externalPrimaryKey else @p nil
 */
+ (NSString *)rzv_safe_externalPrimaryKey;

/**
 *  Always call this instead of @p rzv_shouldAlwaysCreateNewObjectOnImport.
 *  Checks whether the subclass responds to @p rzv_shouldAlwaysCreateNewObjectOnImport before calling it.
 *
 *  @return The staleness predicate provided by the subclass implementing @p rzv_shouldAlwaysCreateNewObjectOnImport else @p NO
 */
+ (BOOL)rzv_safe_shouldAlwaysCreateNewObjectOnImport;

@end
