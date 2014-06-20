//
//  RZPerson+RZVinyl.m
//  RZVinylDemo
//
//  Created by Nick Donaldson on 6/20/14.
//  Copyright (c) 2014 Raizlabs. All rights reserved.
//

#import "RZPerson+RZVinyl.h"
#import "RZInterest.h"

@implementation RZPerson (RZVinyl)

+ (NSString *)rzv_primaryKey
{
    return NSStringFromSelector(@selector(remoteId));
}

+ (NSString *)rzv_externalPrimaryKey
{
    return @"id";
}

- (BOOL)rzi_shouldImportValue:(id)value forKey:(NSString *)key inContext:(NSManagedObjectContext *)context
{
    if ( [key isEqualToString:@"interests"] ) {
        if ( [value isKindOfClass:[NSArray class]] ) {
            
            NSMutableSet *interests = [NSMutableSet set];
            [(NSArray *)value enumerateObjectsUsingBlock:^(id obj, NSUInteger idx, BOOL *stop) {
                if ( [obj isKindOfClass:[NSString class]] ) {
                    RZInterest *interest = [RZInterest rzv_objectWithAttributes:@{ @"name" : obj } createNew:YES inContext:context];
                    if ( interest ) {
                        [interests addObject:interest];
                    }
                }
            }];
            self.interests = [NSSet setWithSet:interests];
        }
        return NO;
    }
    return [super rzi_shouldImportValue:value forKey:key inContext:context];
}

@end
