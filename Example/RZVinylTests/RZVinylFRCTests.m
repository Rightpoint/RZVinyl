//
//  RZVinylFRCTests.m
//  RZVinylDemo
//
//  Created by Brian King on 12/8/14.
//  Copyright (c) 2014 Raizlabs. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "RZVinylBaseTestCase.h"

@interface RZVinylFRCTests : RZVinylBaseTestCase <NSFetchedResultsControllerDelegate>

@property (strong, nonatomic) NSFetchedResultsController *frc;
@property (strong, nonatomic) NSMutableArray *objectsDelegatedToChange;


@end

@implementation RZVinylFRCTests

- (void)setUp {
    [super setUp];
    NSPredicate *match = RZVPred(@"title ENDSWITH %@", @"TEST");
    self.frc = [NSFetchedResultsController rzv_forEntity:@"Song"
                                               inContext:[[RZCoreDataStack defaultStack] mainManagedObjectContext]
                                                   where:match
                                                    sort:@[[NSSortDescriptor sortDescriptorWithKey:@"title" ascending:YES]]];
    self.frc.delegate = self;
    self.objectsDelegatedToChange = [NSMutableArray array];

    // Import the seed data, and ensure that it is not created in the main context.
    XCTestExpectation *initialSaveDone = [self expectationWithDescription:@"Initial Seeding"];
    [[RZCoreDataStack defaultStack] performBlockUsingBackgroundContext:^(NSManagedObjectContext *context) {
        [self seedDatabaseInContext:context];
    } completion:^(NSError *err) {
        [initialSaveDone fulfill];
    }];
}

- (void)tearDown {
    // Put teardown code here. This method is called after the invocation of each test method in the class.
    [super tearDown];
}

- (void)controller:(NSFetchedResultsController *)controller didChangeObject:(id)anObject atIndexPath:(NSIndexPath *)indexPath forChangeType:(NSFetchedResultsChangeType)type newIndexPath:(NSIndexPath *)newIndexPath
{
    [self.objectsDelegatedToChange addObject:anObject];
}

/**
 * This test is to aggrevate a non-straight-forward issue with the multi-context core data stack setup.
 *
 * Setup the main context with a NSFRC looking for a song that does not exist.   Modfiy a song on the background
 * thread such that it would be matched by the predicate and ensure it appears.  Note that none of the data actually
 * exists in the mainManagedObjectContext.
 *
 * This aggrevates a bug in mergeChangesFromContextDidSaveNotification:
 */
- (void)test_changeObjectOutOfMainContextForInclusionInFRC
{
    [self waitForExpectationsWithTimeout:5 handler:^(NSError *error) {
        XCTAssertNil(error);
    }];

    [self.frc performFetch:nil];
    XCTestExpectation *saveDone = [self expectationWithDescription:@"Core Data Save Complete"];

    [[RZCoreDataStack defaultStack] performBlockUsingBackgroundContext:^(NSManagedObjectContext *context) {
        Song *songUpdate = [[Song rzv_allInContext:context] lastObject];
        songUpdate.title = @"This is a TEST";
        
        Song *songInsert = [NSEntityDescription insertNewObjectForEntityForName:@"Song" inManagedObjectContext:context];
        songInsert.remoteID = @(2342342323);
        songInsert.title = @"Insert TEST";
        songInsert.length = @(232);
    } completion:^(NSError *err) {
        XCTAssertNil(err);
        [saveDone fulfill];
    }];
    [self waitForExpectationsWithTimeout:5 handler:^(NSError *error) {
        XCTAssertNil(error);
    }];
    XCTAssertTrue(self.objectsDelegatedToChange.count == 2);
}

@end
