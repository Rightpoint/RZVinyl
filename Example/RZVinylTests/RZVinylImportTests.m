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
    NSDictionary *duskyRaw = [self.rawArtists objectAtIndex:0];
    XCTAssertNotNil(duskyRaw, @"Failed to import test json");
    
    Artist *dusky = [Artist rzai_objectFromDictionary:duskyRaw];
    XCTAssertNotNil(dusky, @"Failed to import from dict");
    XCTAssertEqualObjects(dusky.managedObjectContext, self.stack.mainManagedObjectContext, @"Wrong context");
    XCTAssertEqualObjects(dusky.name, @"Dusky", @"Name import failed");
    XCTAssertEqualObjects(dusky.genre, @"Deep House", @"Genre import failed");
    
    [self.stack.mainManagedObjectContext reset];
    
    __block BOOL finished = NO;
    [self.stack performBlockUsingBackgroundContext:^(NSManagedObjectContext *context) {
        
        Artist *dusky = [Artist rzai_objectFromDictionary:duskyRaw inContext:context];
        XCTAssertNotNil(dusky, @"Failed to import from dict");
        XCTAssertEqualObjects(dusky.managedObjectContext, context, @"Wrong context");
        XCTAssertEqualObjects(dusky.name, @"Dusky", @"Name import failed");
        XCTAssertEqualObjects(dusky.genre, @"Deep House", @"Genre import failed");
        
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
    
}

@end
