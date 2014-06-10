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

// Declaration of benchmark function from libdispatch
// http://nshipster.com/benchmarking/
extern uint64_t dispatch_benchmark(size_t count, void (^block)(void));

@interface RZVinylBaseTestCase : XCTestCase

@property (nonatomic, readonly, strong) RZCoreDataStack *stack;

@end
