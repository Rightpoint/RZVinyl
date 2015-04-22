//
//  NSManagedObject+RZImport_private.m
//  Pods
//
//  Created by Connor Smith on 2/6/15.
//
//

#import "NSManagedObject+RZImport_private.h"
#import "RZVinylRip.h"

@interface NSManagedObject () <RZVinylRip>

@end

@implementation NSManagedObject (RZImport_private)

+ (NSString *)rzv_safe_externalPrimaryKey
{
    NSString *externalPrimaryKey = nil;
    if ( [self respondsToSelector:@selector(rzv_externalPrimaryKey)] ) {
        externalPrimaryKey = [self rzv_externalPrimaryKey];
    }
    return externalPrimaryKey;
}

+ (BOOL)rzv_safe_shouldAlwaysCreateNewObjectOnImport
{
    BOOL shouldAlwaysCreateNew = NO;
    if ( [self respondsToSelector:@selector(rzv_shouldAlwaysCreateNewObjectOnImport)] ) {
        shouldAlwaysCreateNew = [self rzv_shouldAlwaysCreateNewObjectOnImport];
    }
    return shouldAlwaysCreateNew;
}

@end
