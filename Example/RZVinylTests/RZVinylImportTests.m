//
//  RZVinylImportTests.m
//  RZVinylDemo
//
//  Created by Nick Donaldson on 6/8/14.
//  Copyright (c) 2014 Raizlabs. All rights reserved.
//

#import "RZVinylBaseTestCase.h"

@interface RZVinylImportTests : RZVinylBaseTestCase

@property (nonatomic, strong) NSArray *rawArtists;

@end

@implementation RZVinylImportTests

- (void)setUp
{
    [super setUp];
    NSURL *testJSONURL = [[NSBundle bundleForClass:[self class]] URLForResource:@"record_tests" withExtension:@"json"];
    self.rawArtists = [NSJSONSerialization JSONObjectWithData:[NSData dataWithContentsOfURL:testJSONURL] options:kNilOptions error:NULL];
}

- (void)tearDown
{
    [super tearDown];
    self.rawArtists = nil;
}

- (void)test_ObjectImport
{
    NSDateFormatter *testFormatter  = [[NSDateFormatter alloc] init];
    testFormatter.dateFormat        = @"yyyy-MM-dd'T'HH:mm:ss'Z'";
    testFormatter.locale            = [NSLocale localeWithLocaleIdentifier:@"en_US_POSIX"];
    testFormatter.timeZone          = [NSTimeZone timeZoneForSecondsFromGMT:0];
    
    NSDictionary *duskyRaw = [self.rawArtists objectAtIndex:0];
    XCTAssertNotNil(duskyRaw, @"Failed to import test json");
    
    Artist *dusky = [Artist rzai_objectFromDictionary:duskyRaw];
    XCTAssertNotNil(dusky, @"Failed to import from dict");
    XCTAssertEqualObjects(dusky.managedObjectContext, self.stack.mainManagedObjectContext, @"Wrong context");
    XCTAssertEqualObjects(dusky.name, duskyRaw[@"name"], @"Name import failed");
    XCTAssertEqualObjects(dusky.remoteID, duskyRaw[@"id"], @"Remote ID import failed");
    XCTAssertEqualObjects(dusky.genre, duskyRaw[@"genre"], @"Genre import failed");
    XCTAssertEqualObjects([testFormatter stringFromDate:dusky.lastUpdated], duskyRaw[@"lastUpdated"], @"Date import failed");
    
    [self.stack.mainManagedObjectContext reset];
    
    __block BOOL finished = NO;
    [self.stack performBlockUsingBackgroundContext:^(NSManagedObjectContext *context) {
        
        Artist *dusky = [Artist rzai_objectFromDictionary:duskyRaw inContext:context];
        XCTAssertNotNil(dusky, @"Failed to import from dict");
        XCTAssertEqualObjects(dusky.managedObjectContext, context, @"Wrong context");
        XCTAssertEqualObjects(dusky.name, duskyRaw[@"name"], @"Name import failed");
        XCTAssertEqualObjects(dusky.remoteID, duskyRaw[@"id"], @"Remote ID import failed");
        XCTAssertEqualObjects(dusky.genre, duskyRaw[@"genre"], @"Genre import failed");
        XCTAssertEqualObjects([testFormatter stringFromDate:dusky.lastUpdated], duskyRaw[@"lastUpdated"], @"Date import failed");
        
    } completion:^(NSError *err) {
        XCTAssertNil(err, @"Error during background context save: %@", err);
        finished = YES;
    }];
    
    [RZWaiter waitWithTimeout:3 pollInterval:0.1 checkCondition:^BOOL{
        return finished;
    } onTimeout:^{
        XCTFail(@"Operation timed out");
    }];
}

- (void)test_ArrayImport
{
    XCTAssertNotNil(self.rawArtists, @"Failed to import test json");
    
    NSArray *artists = [Artist rzai_objectsFromArray:self.rawArtists];
    XCTAssertNotNil(artists, @"Failed to import array");
    XCTAssertEqual(artists.count, 3, @"Wrong number of artists");
    
    NSSet *expectedNames = [NSSet setWithArray:@[@"BCee", @"Dusky", @"Tool"]];
    NSSet *importedNames = [NSSet setWithArray:[artists valueForKey:@"name"]];
    XCTAssertTrue([expectedNames isEqualToSet:importedNames], @"Failed to import names correctly");

    [self.stack.mainManagedObjectContext reset];
    
    __block BOOL finished = NO;
    [self.stack performBlockUsingBackgroundContext:^(NSManagedObjectContext *context) {
        
        NSArray *artists = [Artist rzai_objectsFromArray:self.rawArtists inContext:context];
        XCTAssertNotNil(artists, @"Failed to import array");
        XCTAssertEqual(artists.count, 3, @"Wrong number of artists");
        XCTAssertEqualObjects(context, [artists[0] managedObjectContext], @"Wrong context");
        
        NSSet *expectedNames = [NSSet setWithArray:@[@"BCee", @"Dusky", @"Tool"]];
        NSSet *importedNames = [NSSet setWithArray:[artists valueForKey:@"name"]];
        XCTAssertTrue([expectedNames isEqualToSet:importedNames], @"Failed to import names correctly");
        
    } completion:^(NSError *err) {
        XCTAssertNil(err, @"Error during background context save: %@", err);
        finished = YES;
    }];
    
    [RZWaiter waitWithTimeout:3 pollInterval:0.1 checkCondition:^BOOL{
        return finished;
    } onTimeout:^{
        XCTFail(@"Operation timed out");
    }];
}

@end
