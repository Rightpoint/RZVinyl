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
    XCTAssertEqual(dusky.songs.count, 1, @"Song relationship import failed");
    if ( dusky.songs.count > 0 ) {
        NSDictionary *rawSong = duskyRaw[@"songs"][0];
        Song *anySong = [dusky.songs anyObject];
        XCTAssertEqualObjects(anySong.remoteID, rawSong[@"id"], @"Song ID import failed");
        XCTAssertEqualObjects(anySong.title, rawSong[@"title"], @"Song title import failed");
    }
    
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
        XCTAssertEqual(dusky.songs.count, 1, @"Song relationship import failed");
        if ( dusky.songs.count > 0 ) {
            NSDictionary *rawSong = duskyRaw[@"songs"][0];
            Song *anySong = [dusky.songs anyObject];
            XCTAssertEqualObjects(anySong.managedObjectContext, context, @"Wrong context");
            XCTAssertEqualObjects(anySong.remoteID, rawSong[@"id"], @"Song ID import failed");
            XCTAssertEqualObjects(anySong.title, rawSong[@"title"], @"Song title import failed");
        }
        
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

    Artist *tool = [Artist rzv_objectWithAttributes:@{ @"name" : @"Tool" } createNew:NO];
    XCTAssertNotNil(tool, @"Failed to find Tool");
    XCTAssertEqual(tool.songs.count, 2, @"Song relationship import failed");
    NSSet *songTitles = [[tool songs] valueForKey:@"title"];
    NSSet *expectedSongTitles = [NSSet setWithArray:@[@"Lateralus", @"Aenima"]];
    XCTAssertEqualObjects(songTitles, expectedSongTitles, @"Song title import failed");
    
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
        
        Artist *tool = [Artist rzv_objectWithAttributes:@{ @"name" : @"Tool" } createNew:NO inContext:context];
        XCTAssertNotNil(tool, @"Failed to find Tool");
        XCTAssertEqual(tool.songs.count, 2, @"Song relationship import failed");
        NSSet *songTitles = [[tool songs] valueForKey:@"title"];
        NSSet *expectedSongTitles = [NSSet setWithArray:@[@"Lateralus", @"Aenima"]];
        XCTAssertEqualObjects(songTitles, expectedSongTitles, @"Song title import failed");
        
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

- (void)test_BigImport_100
{
    const NSUInteger iterations = 100;
    
    NSDictionary *templateDict = @{
       @"name" : @"Rick Astley",
       @"genre" : @"Pop",
       @"songs" : @[
          @{
              @"id" : @1337,
              @"title" : @"Never Gonna Give You Up"
           }
       ]
    };
    
    NSMutableArray *artistArray = [NSMutableArray array];
    for ( NSUInteger i = 0; i < iterations; i++ ) {
        NSMutableDictionary *artistDict = [templateDict mutableCopy];
        [artistDict setObject:@(i+1) forKey:@"id"];
        [artistArray addObject:artistDict];
    }
    
    // Without optimization: 4.9 seconds
    // With optimization: 2.96 seconds
    __block NSArray *artists = nil;
    uint64_t time = dispatch_benchmark(iterations, ^{
        artists = [Artist rzai_objectsFromArray:artistArray];
    });
    
    NSLog(@"Import of %lu artists took %llu ns", (unsigned long)iterations, time);
    
    XCTAssertNotNil(artists, @"Failed to import artists");
    XCTAssertEqual(artists.count, iterations, @"Incorrect number of artists imported");
    
    NSSet *artistNames = [NSSet setWithArray:[artists valueForKey:@"name"]];
    XCTAssertEqual(artistNames.count, 1, @"Should all be the same artist name");
    XCTAssertEqualObjects([artistNames anyObject], @"Rick Astley", @"Wrong artist name");
    
}

@end
