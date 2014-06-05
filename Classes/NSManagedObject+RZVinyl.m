//
//  NSManagedObject+RZVinyl.m
//  RZVinylDemo
//
//  Created by Nick Donaldson on 6/4/14.
//  Copyright (c) 2014 Raizlabs. All rights reserved.
//

#import "NSManagedObject+RZVinyl.h"
#import "RZCoreDataStack.h"

@implementation NSManagedObject (RZVinyl)

+ (NSString *)rzv_primaryKey
{
    return nil;
}

+ (RZCoreDataStack *)rzv_dataStack
{
    return [RZCoreDataStack defaultStack];
}

#pragma mark - RZAutoImportable

+ (id)rzai_existingObjectForDict:(NSDictionary *)dict
{
    return nil;
}

@end
