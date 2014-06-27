//
//  RZInterest+RZVinyl.m
//  RZVinylDemo
//
//  Created by Nick Donaldson on 6/20/14.
//  Copyright (c) 2014 Raizlabs. All rights reserved.
//

#import "RZInterest+RZVinyl.h"

@implementation RZInterest (RZVinyl)

+ (NSPredicate *)rzv_stalenessPredicate
{
    // All interests with no associated people will be purged
    // when the RZCoreDataStack purges stale objects
    return [NSPredicate predicateWithFormat:@"people.@count == 0"];
}

@end
