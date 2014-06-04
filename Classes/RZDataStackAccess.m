//
//  RZDataStackAccess.m
//  RZVinylDemo
//
//  Created by Nick Donaldson on 6/4/14.
//  Copyright (c) 2014 Raizlabs. All rights reserved.
//

#import "RZDataStackAccess.h"

@implementation RZDataStackAccess

static RZDataStack *s_defaultStack = nil;

+ (RZDataStack *)defaultStack
{
    return s_defaultStack;
}

+ (void)setDefaultStack:(RZDataStack *)defaultStack
{
    s_defaultStack = defaultStack;
}


@end
