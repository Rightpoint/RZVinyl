//
//  RZVinylSaveTests.m
//  RZVinylDemo
//
//  Created by Nick Donaldson on 6/25/14.
//  Copyright (c) 2014 Raizlabs. All rights reserved.
//

#import "RZCoreDataStack+TestUtils.h"
#import "Artist.h"
#import "RZWaiter.h"

@interface RZVinylSaveTests : XCTestCase

@property (nonatomic, strong) RZCoreDataStack *coreDataStack;

@end

@implementation RZVinylSaveTests

- (void)setUp
{
    [super setUp];
    [self buildStack];
}

- (void)tearDown
{
    NSURL *storeURL = [[[[self.coreDataStack persistentStoreCoordinator] persistentStores] objectAtIndex:0] URL];
    [[NSFileManager defaultManager] removeItemAtURL:storeURL error:NULL];
    [super tearDown];
}

- (void)buildStack
{
    NSURL *modelURL = [[NSBundle bundleForClass:[self class]] URLForResource:@"TestModel" withExtension:@"momd"];
    NSManagedObjectModel *model = [[NSManagedObjectModel alloc] initWithContentsOfURL:modelURL];
    self.coreDataStack = [[RZCoreDataStack alloc] initWithModel:model
                                                      storeType:NSSQLiteStoreType
                                                       storeURL:nil
                                     persistentStoreCoordinator:nil
                                                        options:RZCoreDataStackOptionsDeleteDatabaseIfUnreadable];
}

#pragma mark - Tests

- (void)testSyncSave
{
    Artist *artist = [NSEntityDescription insertNewObjectForEntityForName:@"Artist" inManagedObjectContext:self.coreDataStack.mainManagedObjectContext];
    artist.remoteID = @1;
    artist.name = @"Frank Zappa";
    artist.genre = @"Wat";
    
    XCTAssertTrue([self.coreDataStack.mainManagedObjectContext hasChanges], @"Context should have changes");
    
    NSError *err = nil;
    BOOL returnValue = [self.coreDataStack.mainManagedObjectContext rzv_saveToStoreAndWait:&err];
    XCTAssertNil(err, @"Error saving context: %@", err);
    XCTAssertTrue(returnValue, @"Return value should be YES");
    
    // rebuild the stack from the sqlite file
    self.coreDataStack = nil;
    [self buildStack];
    
    NSFetchRequest *fetchRequest = [NSFetchRequest fetchRequestWithEntityName:@"Artist"];
    fetchRequest.predicate = [NSPredicate predicateWithFormat:@"remoteID == 1"];
    
    NSError *fetchErr = nil;
    Artist *fetchedArtist = [[self.coreDataStack.mainManagedObjectContext executeFetchRequest:fetchRequest error:&fetchErr] lastObject];
    XCTAssertNil(fetchErr, @"Error fetching: %@", fetchErr);
    XCTAssertNotNil(fetchedArtist, @"Did not find matching artist after save");
    XCTAssertEqualObjects(fetchedArtist.name, @"Frank Zappa", @"Matching artist has wrong name");
}

- (void)testAsyncSave
{
    Artist *artist = [NSEntityDescription insertNewObjectForEntityForName:@"Artist" inManagedObjectContext:self.coreDataStack.mainManagedObjectContext];
    artist.remoteID = @1;
    artist.name = @"Frank Zappa";
    artist.genre = @"Wat";
    
    XCTAssertTrue([self.coreDataStack.mainManagedObjectContext hasChanges], @"Context should have changes");
    
    __block BOOL doneSaving = NO;

    [self.coreDataStack.mainManagedObjectContext rzv_saveToStoreWithCompletion:^(NSError *error) {
        XCTAssertNil(error, @"Error saving context: %@", error);
        doneSaving = YES;
    }];
    
    [RZWaiter waitWithTimeout:3.0
                 pollInterval:0.01
               checkCondition:^BOOL{
                   return doneSaving;
               } onTimeout:^{
                   XCTFail(@"Timed out waiting for save");
               }];
    
    // rebuild the stack from the sqlite file
    self.coreDataStack = nil;
    [self buildStack];
    
    NSFetchRequest *fetchRequest = [NSFetchRequest fetchRequestWithEntityName:@"Artist"];
    fetchRequest.predicate = [NSPredicate predicateWithFormat:@"remoteID == 1"];
    
    NSError *fetchErr = nil;
    Artist *fetchedArtist = [[self.coreDataStack.mainManagedObjectContext executeFetchRequest:fetchRequest error:&fetchErr] lastObject];
    XCTAssertNil(fetchErr, @"Error fetching: %@", fetchErr);
    XCTAssertNotNil(fetchedArtist, @"Did not find matching artist after save");
    XCTAssertEqualObjects(fetchedArtist.name, @"Frank Zappa", @"Matching artist has wrong name");
}

- (void)testSyncSaveError
{
    // Without an ID this will not save correctly, since it's a non-optional attribute.
    Artist *artist = [NSEntityDescription insertNewObjectForEntityForName:@"Artist" inManagedObjectContext:self.coreDataStack.mainManagedObjectContext];
    artist.name = @"Kraftwerk";
    
    XCTAssertTrue([self.coreDataStack.mainManagedObjectContext hasChanges], @"Context should have changes");
    
    NSError *err = nil;
    BOOL returnValue = [self.coreDataStack.mainManagedObjectContext rzv_saveToStoreAndWait:&err];
    XCTAssertNotNil(err, @"Saving context should produce error");
    XCTAssertFalse(returnValue, @"Return value should be NO");
}

- (void)testAsyncSaveError
{
    // Without an ID this will not save correctly, since it's a non-optional attribute.
    Artist *artist = [NSEntityDescription insertNewObjectForEntityForName:@"Artist" inManagedObjectContext:self.coreDataStack.mainManagedObjectContext];
    artist.name = @"Kraftwerk";
    
    XCTAssertTrue([self.coreDataStack.mainManagedObjectContext hasChanges], @"Context should have changes");
    
    __block BOOL doneSaving = NO;
    
    [self.coreDataStack.mainManagedObjectContext rzv_saveToStoreWithCompletion:^(NSError *error) {
        XCTAssertNotNil(error, @"Saving context should produce error");
        doneSaving = YES;
    }];
    
    [RZWaiter waitWithTimeout:3.0
                 pollInterval:0.01
               checkCondition:^BOOL{
                   return doneSaving;
               } onTimeout:^{
                   XCTFail(@"Timed out waiting for save");
               }];
}

@end
