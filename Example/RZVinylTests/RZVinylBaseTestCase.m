//
//  RZVinylBaseTestCase.m
//  RZVinylDemo
//
//  Created by Nick Donaldson on 6/8/14.
//  Copyright (c) 2014 Raizlabs. All rights reserved.
//

#import "RZVinylBaseTestCase.h"
#import "RZCoreDataStack+TestUtils.h"

@interface RZVinylBaseTestCase ()

@property (nonatomic, readwrite, strong) RZCoreDataStack *stack;

@end

@implementation RZVinylBaseTestCase

- (void)setUp
{
    [super setUp];
    
    [RZCoreDataStack resetDefaultStack];
    
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

- (void)seedDatabase
{
    [self seedDatabaseInContext:self.stack.mainManagedObjectContext];
}

- (void)seedDatabaseInContext:(NSManagedObjectContext *)context
{
    // Manual import for this test
    NSURL *testJSONURL = [[NSBundle bundleForClass:[self class]] URLForResource:@"record_tests" withExtension:@"json"];
    NSArray *testArtists = [NSJSONSerialization JSONObjectWithData:[NSData dataWithContentsOfURL:testJSONURL] options:kNilOptions error:NULL];
    [testArtists enumerateObjectsUsingBlock:^(NSDictionary *artistDict, NSUInteger idx, BOOL *stop) {
        Artist *artist = [NSEntityDescription insertNewObjectForEntityForName:@"Artist" inManagedObjectContext:context];
        artist.remoteID = artistDict[@"id"];
        artist.name = artistDict[@"name"];
        artist.genre = artistDict[@"genre"];
        
        NSMutableSet *songs = [NSMutableSet set];
        NSArray *songArray = artistDict[@"songs"];
        [songArray enumerateObjectsUsingBlock:^(NSDictionary *songDict, NSUInteger songIdx, BOOL *stop) {
            Song *song = [NSEntityDescription insertNewObjectForEntityForName:@"Song" inManagedObjectContext:context];
            song.remoteID = songDict[@"id"];
            song.title = songDict[@"title"];
            song.length = songDict[@"length"];
            [songs addObject:song];
        }];
        
        artist.songs = songs;
    }];
    
    [context rzv_saveToStoreAndWait:NULL];
}

@end
