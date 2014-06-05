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
    // Manual import for this test
    NSURL *testJSONURL = [[NSBundle bundleForClass:[self class]] URLForResource:@"record_tests" withExtension:@"json"];
    NSArray *testArtists = [NSJSONSerialization JSONObjectWithData:[NSData dataWithContentsOfURL:testJSONURL] options:kNilOptions error:NULL];
    [testArtists enumerateObjectsUsingBlock:^(NSDictionary *artistDict, NSUInteger idx, BOOL *stop) {
        Artist *artist = [NSEntityDescription insertNewObjectForEntityForName:@"Artist" inManagedObjectContext:self.stack.managedObjectContext];
        artist.remoteID = @(idx + 100);
        artist.name = artistDict[@"name"];
        artist.genre = artistDict[@"genre"];
        
        NSMutableSet *songs = [NSMutableSet set];
        NSArray *songArray = artistDict[@"songs"];
        [songArray enumerateObjectsUsingBlock:^(NSDictionary *songDict, NSUInteger songIdx, BOOL *stop) {
            Song *song = [NSEntityDescription insertNewObjectForEntityForName:@"Song" inManagedObjectContext:self.stack.managedObjectContext];
            song.remoteID = @( (idx + 1) * 100 + songIdx );
            song.title = songDict[@"title"];
            song.length = songDict[@"length"];
            [songs addObject:song];
        }];
        
        artist.songs = songs;
    }];
    
    [self.stack save:YES];
}

#pragma mark - Tests

- (void)test_SimpleCreation
{
    Artist *newArtist = nil;
    XCTAssertNoThrow(newArtist = [Artist rzv_newObject], @"Creation threw exception");
    XCTAssertNotNil(newArtist, @"Failed to create new object");
    XCTAssertTrue([newArtist isKindOfClass:[Artist class]], @"New object is not of correct class");
}

- (void)test_ChildContext
{
    NSManagedObjectContext *childContext = [self.stack temporaryChildContext];
    [childContext performBlockAndWait:^{
        Artist *newArtist = nil;
        XCTAssertNoThrow(newArtist = [Artist rzv_newObjectInContext:childContext], @"Creation with explicit context should not throw exception");
        XCTAssertNotNil(newArtist, @"Failed to create new object");
        XCTAssertTrue([newArtist isKindOfClass:[Artist class]], @"New object is not of correct class");
        
        newArtist.remoteID = @100;
        newArtist.name = @"Sergio";
        newArtist.genre = @"Sax";
        
        NSError *err = nil;
        [childContext save:&err];
        XCTAssertNil(err, @"Saving child context failed: %@", err);
    }];
    
    Artist *matchingArtist = [Artist rzv_objectWithPrimaryKeyValue:@100 createNew:NO];
    XCTAssertNotNil(matchingArtist, @"Could not fetch from main context");
    XCTAssertEqualObjects(matchingArtist.name, @"Sergio", @"Fetched artist has wrong name");
}

- (void)test_BackgroundSavePropagation
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
        
        [[self.stack managedObjectContext] reset];
        
        Artist *matchingArtist = [Artist rzv_objectWithPrimaryKeyValue:@100 createNew:NO];
        XCTAssertNil(matchingArtist, @"Matching object should not exist after reset without save");
        
        finished = YES;
    }];
    
    [[RZWaiter waiter] waitWithTimeout:3
                          pollInterval:0.1
                        checkCondition:^BOOL{
                            return finished;
                        } onTimeout:^{
                            XCTFail(@"Operation timed out");
                        }];
    
    finished = NO;
    
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
        [[self.stack managedObjectContext] reset];
        
        Artist *matchingArtist = [Artist rzv_objectWithPrimaryKeyValue:@100 createNew:NO];
        XCTAssertNotNil(matchingArtist, @"Matching object should exist after reset after save");
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

- (void)test_FetchAll
{
    [self seedDatabase];
}

- (void)test_QueryString
{
    [self seedDatabase];
}

- (void)test_QueryPredicate
{
    [self seedDatabase];
}

- (void)test_QuerySort
{
    [self seedDatabase];
}

- (void)testCount
{
    [self seedDatabase];
}

@end
