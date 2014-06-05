//
//  RZCoreDataStackConfigTests.m
//  RZVinylTests
//
//  Created by Nick Donaldson on 6/4/14.
//  Copyright (c) 2014 Raizlabs. All rights reserved.
//

#import <XCTest/XCTest.h>
#import "RZVinyl.h"

static NSString* const kRZCoreDataStackCustomFilePath = @"test_tmp/RZCoreDataStackConfigTest.sqlite";

@interface RZCoreDataStackConfigTests : XCTestCase

@property (nonatomic, strong) RZCoreDataStack *dataStack;
@property (nonatomic, strong) NSURL *customFileURL;

@end

@implementation RZCoreDataStackConfigTests

- (void)setUp
{
    [super setUp];
    NSURL *libraryURL = [[[NSFileManager defaultManager] URLsForDirectory:NSLibraryDirectory inDomains:NSUserDomainMask] lastObject];
    self.customFileURL = [libraryURL URLByAppendingPathComponent:kRZCoreDataStackCustomFilePath];
}

- (void)tearDown
{
    [super tearDown];
    
    // Delete test file
    if ( [[NSFileManager defaultManager] fileExistsAtPath:[self.customFileURL path]] ){
        [[NSFileManager defaultManager] removeItemAtURL:self.customFileURL error:NULL];
    }
}

- (void)test_DefaultOptions
{
    RZCoreDataStack *stack = nil;
    XCTAssertNoThrow(stack = [[RZCoreDataStack alloc] initWithModelName:nil
                                                          configuration:nil
                                                              storeType:NSInMemoryStoreType
                                                               storeURL:nil
                                                                options:kNilOptions], @"Init threw an exception");
    
    XCTAssertNotNil(stack, @"Stack should not be nil");
    XCTAssertNotNil(stack.managedObjectModel, @"Model should not be nil");
    XCTAssertNotNil(stack.managedObjectContext, @"MOC should not be nil");
    XCTAssertNotNil(stack.persistentStoreCoordinator, @"PSC should not be nil");
}

- (void)test_CustomStoreURL
{
    XCTAssertFalse([[NSFileManager defaultManager] fileExistsAtPath:[self.customFileURL path]], @"sqlite file should not exist yet");
    
    RZCoreDataStack *stack = nil;
    XCTAssertNoThrow(stack = [[RZCoreDataStack alloc] initWithModelName:nil
                                                          configuration:nil
                                                              storeType:NSInMemoryStoreType
                                                               storeURL:self.customFileURL
                                                                options:kNilOptions], @"Init threw an exception");
    
    XCTAssertNotNil(stack, @"Stack should not be nil");
    XCTAssertNotNil(stack.managedObjectModel, @"Model should not be nil");
    XCTAssertNotNil(stack.managedObjectContext, @"MOC should not be nil");
    XCTAssertNotNil(stack.persistentStoreCoordinator, @"PSC should not be nil");
    
    XCTAssertTrue([[NSFileManager defaultManager] fileExistsAtPath:[self.customFileURL path]], @"sqlite file not created");
}

- (void)test_CustomModel
{
    
}

@end
