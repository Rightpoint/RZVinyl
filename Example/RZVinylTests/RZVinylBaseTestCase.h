//
//  RZVinylBaseTestCase.m
//  RZVinylDemo
//
//  Created by Nick Donaldson on 6/8/14.
//  Copyright (c) 2014 Raizlabs. All rights reserved.
//

@import XCTest;
#import "RZVinyl.h"
#import "Artist.h"
#import "Song.h"
#import "RZWaiter.h"

@interface RZVinylBaseTestCase : XCTestCase

@property (nonatomic, readonly, strong) RZCoreDataStack *stack;

@end
