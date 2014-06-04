//
//  RZDataStackConfigTests.m
//  RZVinylTests
//
//  Created by Nick Donaldson on 6/4/14.
//  Copyright (c) 2014 Raizlabs. All rights reserved.
//

#import <XCTest/XCTest.h>
#import "RZVinyl.h"

@interface RZDataStackConfigTests : XCTestCase

@property (nonatomic, strong) RZDataStack *dataStack;

@end

@implementation RZDataStackConfigTests

- (void)tearDown
{
    [super tearDown];
}

- (void)test_DefaultOptions
{
    RZDataStack *stack = nil;
    XCTAssertNoThrow(stack = [[RZDataStack alloc] initWithModelName:nil
                                                      configuration:nil
                                                          storeType:NSInMemoryStoreType
                                                           storeURL:nil
                                                            options:kNilOptions], @"Init threw an exception");
    
    XCTAssertNotNil(stack, @"Stack should not be nil");
}

@end
