//
//  BaseObject+RZVinyl.m
//  RZVinylDemo
//
//  Created by Nick Donaldson on 6/5/14.
//  Copyright (c) 2014 Raizlabs. All rights reserved.
//

#import "BaseObject+RZVinyl.h"

@implementation BaseObject (RZVinyl)

+ (NSString *)rzv_primaryKey
{
    return NSStringFromSelector(@selector(remoteID));
}

+ (NSString *)rzv_externalPrimaryKey
{
    return @"id";
}

@end
