//
//  RZVinylBaseTestCase.m
//  RZVinylDemo
//
//  Created by Nick Donaldson on 6/8/14.
//  Copyright (c) 2014 Raizlabs. All rights reserved.
//

#import "RZVinylBaseTestCase.h"

@interface RZVinylBaseTestCase ()

@property (nonatomic, readwrite, strong) RZCoreDataStack *stack;

@end

@implementation RZVinylBaseTestCase

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

@end
