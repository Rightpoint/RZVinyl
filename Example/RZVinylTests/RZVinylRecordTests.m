//
//  RZVinylRecordTests.m
//  RZVinylDemo
//
//  Created by Nick Donaldson on 6/5/14.
//  Copyright (c) 2014 Raizlabs. All rights reserved.
//

@import XCTest;
#import "RZVinyl.h"
#import "Artist.h"
#import "Song.h"
#import "RZWaiter.h"

@interface RZVinylRecordTests : XCTestCase

@property (nonatomic, strong) RZCoreDataStack *stack;

@end

@implementation RZVinylRecordTests

- (void)setUp
{
    [super setUp];
    NSURL *modelURL = [[NSBundle bundleForClass:[self class]] URLForResource:@"TestModel" withExtension:@"momd"];
    NSManagedObjectModel *model = [[NSManagedObjectModel alloc] initWithContentsOfURL:modelURL];
    self.stack = [[RZCoreDataStack alloc] initWithModel:model
                                              storeType:NSInMemoryStoreType
                                               storeURL:nil
                             persistentStoreCoordinator:nil
                                                options:kNilOptions];
    
    [RZCoreDataStack setDefaultStack:self.stack];
}

- (void)tearDown
{
    [super tearDown];
    self.stack = nil;
}

#pragma mark - Utils

- (void)seedDatabase
{
    
}

#pragma mark - Tests

- (void)test_SimpleCreation
{
    Artist *newArtist = nil;
    XCTAssertNoThrow(newArtist = [Artist rzv_newObject], @"Creation threw exception");
    XCTAssertNotNil(newArtist, @"Failed to create new object");
    XCTAssertTrue([newArtist isKindOfClass:[Artist class]], @"New object is not of correct class");
}

- (void)test_BackgroundCreation
{
    __block BOOL finished = NO;
    
    [self.stack performBlockUsingBackgroundContext:^(NSManagedObjectContext *moc) {
        Artist *newArtist = nil;
        XCTAssertNoThrow(newArtist = [Artist rzv_newObject], @"Creation threw exception");
        XCTAssertNotNil(newArtist, @"Failed to create new object");
        XCTAssertTrue([newArtist isKindOfClass:[Artist class]], @"New object is not of correct class");
        
        newArtist.remoteID = @100;
        newArtist.name = @"Sergio";
        newArtist.genre = @"Sax";
        
    } completion:^(NSError *err) {
        XCTAssertNil(err, @"An error occurred during the background save: %@", err);
        
        [self.stack save:YES];
        
        Artist *matchingArtist = [Artist rzv_objectWithPrimaryKeyValue:@100 createNew:NO];
        XCTAssertNotNil(matchingArtist, @"Could not fetch from main context");
        XCTAssertEqualObjects(matchingArtist.name, @"Sergio", @"Fetched artist has wrong name");
        
        finished = YES;
    }];
    
    [[RZWaiter waiter] waitWithTimeout:3
                          pollInterval:0.1
                        checkCondition:^BOOL{
                            return finished;
                        } onTimeout:^{
                            XCTFail(@"Operation timed out");
                        }];
}


@end
