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
    [[NSFileManager defaultManager] createDirectoryAtURL:[self.customFileURL URLByDeletingLastPathComponent] withIntermediateDirectories:YES attributes:nil error:NULL];
}

- (void)tearDown
{
    [super tearDown];
    
    // Delete test file
    NSURL *testTempDirURL = [self.customFileURL URLByDeletingLastPathComponent];
    if ( [[NSFileManager defaultManager] fileExistsAtPath:[testTempDirURL path]] ){
        [[NSFileManager defaultManager] removeItemAtURL:testTempDirURL error:NULL];
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
    XCTAssertNotNil(stack.mainManagedObjectContext, @"MOC should not be nil");
    XCTAssertNotNil(stack.persistentStoreCoordinator, @"PSC should not be nil");
}

- (void)test_CustomStoreURL
{
    XCTAssertFalse([[NSFileManager defaultManager] fileExistsAtPath:[self.customFileURL path]], @"sqlite file should not exist yet");
    
    RZCoreDataStack *stack = nil;
    XCTAssertNoThrow(stack = [[RZCoreDataStack alloc] initWithModelName:nil
                                                          configuration:nil
                                                              storeType:NSSQLiteStoreType
                                                               storeURL:self.customFileURL
                                                                options:kNilOptions], @"Init threw an exception");
    
    XCTAssertNotNil(stack, @"Stack should not be nil");
    XCTAssertNotNil(stack.managedObjectModel, @"Model should not be nil");
    XCTAssertNotNil(stack.mainManagedObjectContext, @"MOC should not be nil");
    XCTAssertNotNil(stack.persistentStoreCoordinator, @"PSC should not be nil");
    
    XCTAssertTrue([[NSFileManager defaultManager] fileExistsAtPath:[self.customFileURL path]], @"sqlite file not created");
}

- (void)test_CustomModel
{
    XCTAssertFalse([[NSFileManager defaultManager] fileExistsAtPath:[self.customFileURL path]], @"sqlite file should not exist yet");
    
    RZCoreDataStack *stack = nil;
    XCTAssertNoThrow(stack = [[RZCoreDataStack alloc] initWithModelName:@"RZVinylDemo"
                                                          configuration:nil
                                                              storeType:NSSQLiteStoreType
                                                               storeURL:self.customFileURL
                                                                options:kNilOptions], @"Init threw an exception");
    
    XCTAssertNotNil(stack, @"Stack should not be nil");
    XCTAssertNotNil(stack.managedObjectModel, @"Model should not be nil");
    XCTAssertNotNil(stack.mainManagedObjectContext, @"MOC should not be nil");
    XCTAssertNotNil(stack.persistentStoreCoordinator, @"PSC should not be nil");
    
    XCTAssertTrue([[NSFileManager defaultManager] fileExistsAtPath:[self.customFileURL path]], @"sqlite file not created");
}

- (void)test_ExistingPSC
{
    NSURL *otherStoreURL = [[self.customFileURL URLByDeletingLastPathComponent] URLByAppendingPathComponent:@"RZCoreDataOtherConfig.sqlite"];
    
    XCTAssertFalse([[NSFileManager defaultManager] fileExistsAtPath:[self.customFileURL path]], @"sqlite file should not exist yet");
    XCTAssertFalse([[NSFileManager defaultManager] fileExistsAtPath:[otherStoreURL path]], @"sqlite file should not exist yet");

    RZCoreDataStack *stack = nil;
    XCTAssertNoThrow(stack = [[RZCoreDataStack alloc] initWithModelName:@"RZVinylDemo"
                                                          configuration:nil
                                                              storeType:NSSQLiteStoreType
                                                               storeURL:self.customFileURL
                                                                options:kNilOptions], @"Init threw an exception");
    
    XCTAssertNotNil(stack, @"Stack should not be nil");
    XCTAssertNotNil(stack.managedObjectModel, @"Model should not be nil");
    XCTAssertNotNil(stack.mainManagedObjectContext, @"MOC should not be nil");
    XCTAssertNotNil(stack.persistentStoreCoordinator, @"PSC should not be nil");
    
    RZCoreDataStack *stack2 = nil;
    XCTAssertNoThrow(stack2 = [[RZCoreDataStack alloc] initWithModelName:@"RZVinylDemo"
                                                           configuration:@"OtherConfig"
                                                               storeType:NSSQLiteStoreType
                                                                storeURL:otherStoreURL
                                              persistentStoreCoordinator:stack.persistentStoreCoordinator
                                                                 options:kNilOptions], @"Init threw an exception");
    
    XCTAssertNotNil(stack2, @"Stack should not be nil");
    XCTAssertNotNil(stack2.managedObjectModel, @"Model should not be nil");
    XCTAssertNotNil(stack2.mainManagedObjectContext, @"MOC should not be nil");
    XCTAssertNotNil(stack2.persistentStoreCoordinator, @"PSC should not be nil");
    XCTAssertEqualObjects(stack.persistentStoreCoordinator, stack2.persistentStoreCoordinator, @"PSC's should be equal");
    
    XCTAssertTrue([[NSFileManager defaultManager] fileExistsAtPath:[self.customFileURL path]], @"sqlite file not created");
    XCTAssertTrue([[NSFileManager defaultManager] fileExistsAtPath:[otherStoreURL path]], @"sqlite file not created");

}

- (void)test_DeleteUnreadable
{
    XCTAssertFalse([[NSFileManager defaultManager] fileExistsAtPath:[self.customFileURL path]], @"sqlite file should not exist yet");
    
    RZCoreDataStack *stack = nil;
    XCTAssertNoThrow(stack = [[RZCoreDataStack alloc] initWithModelName:@"RZVinylDemo"
                                                          configuration:nil
                                                              storeType:NSSQLiteStoreType
                                                               storeURL:self.customFileURL
                                                                options:kNilOptions], @"Init threw an exception");
    
    XCTAssertNotNil(stack, @"Stack should not be nil");
    XCTAssertNotNil(stack.managedObjectModel, @"Model should not be nil");
    XCTAssertNotNil(stack.mainManagedObjectContext, @"MOC should not be nil");
    XCTAssertNotNil(stack.persistentStoreCoordinator, @"PSC should not be nil");
    
    XCTAssertTrue([[NSFileManager defaultManager] fileExistsAtPath:[self.customFileURL path]], @"sqlite file not created");
    
    RZCoreDataStack *stack2 = nil;
    NSURL *testStoreURL = [[NSBundle bundleForClass:[self class]] URLForResource:@"TestModel" withExtension:@"momd"];
    NSManagedObjectModel *testModel = [[NSManagedObjectModel alloc] initWithContentsOfURL:testStoreURL];
    XCTAssertNotNil(testModel, @"Test model failed to load");
    XCTAssertNoThrow(stack2 = [[RZCoreDataStack alloc] initWithModel:testModel
                                                           storeType:NSSQLiteStoreType
                                                            storeURL:self.customFileURL
                                          persistentStoreCoordinator:nil
                                                             options:RZCoreDataStackOptionDisableAutoLightweightMigration], @"Init threw an exception");
    
    XCTAssertNil(stack2, @"Database should be unreadable with this model");
    
    XCTAssertNoThrow(stack2 = [[RZCoreDataStack alloc] initWithModel:testModel
                                                           storeType:NSSQLiteStoreType
                                                            storeURL:self.customFileURL
                                          persistentStoreCoordinator:nil
                                                             options:RZCoreDataStackOptionDeleteDatabaseIfUnreadable], @"Init threw an exception");
    
    XCTAssertNotNil(stack2, @"Stack should have been deleted and rebuilt");
    XCTAssertNotNil(stack2.managedObjectModel, @"Model should not be nil");
    XCTAssertNotNil(stack2.mainManagedObjectContext, @"MOC should not be nil");
    XCTAssertNotNil(stack2.persistentStoreCoordinator, @"PSC should not be nil");
}

@end
