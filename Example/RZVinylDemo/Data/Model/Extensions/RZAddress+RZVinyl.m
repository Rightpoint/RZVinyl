//
//  RZAddress+RZVinyl.m
//  RZVinylDemo
//
//  Created by Nick Donaldson on 6/20/14.
//  Copyright (c) 2014 Raizlabs. All rights reserved.
//

#import "RZAddress+RZVinyl.h"

@implementation RZAddress (RZVinyl)

+ (NSPredicate *)rzv_stalenessPredicate
{
    // All addresses with no associated person will be purged
    // when the RZCoreDataStack purges stale objects
    return [NSPredicate predicateWithFormat:@"person == nil"];
}

@end
