//
//  NSManagedObject+RZVinylSubclass.m
//  RZVinylDemo
//
//  Created by Nick Donaldson on 6/6/14.
//  Copyright (c) 2014 Raizlabs. All rights reserved.
//

#import "NSManagedObject+RZVinylSubclass.h"

@implementation NSManagedObject (RZVinylSubclass)

+ (NSString *)rzv_primaryKey
{
    return nil;
}

+ (RZCoreDataStack *)rzv_coreDataStack
{
    return [RZCoreDataStack defaultStack];
}

@end
