//
//  Artist+RZVinyl.m
//  RZVinylDemo
//
//  Created by Nick Donaldson on 6/9/14.
//  Copyright (c) 2014 Raizlabs. All rights reserved.
//

#import "Artist+RZVinyl.h"

@implementation Artist (RZVinyl)

+ (NSPredicate *)rzv_stalenessPredicate
{
    // purge artists with no songs
    return [NSPredicate predicateWithFormat:@"songs.@count == 0"];
}

@end
