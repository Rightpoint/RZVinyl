//
//  RZCoreDataStack+TestUtils.m
//  RZVinylDemo
//
//  Created by Nick Donaldson on 6/11/14.
//  Copyright (c) 2014 Raizlabs. All rights reserved.
//

#import "RZCoreDataStack+TestUtils.h"

extern void __rzv_resetDefaultStack();

@implementation RZCoreDataStack (TestUtils)

+ (void)resetDefaultStack
{
    __rzv_resetDefaultStack();
}

@end
