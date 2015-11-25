//
//  RZVinylOptions.m
//  Pods
//
//  Created by Eric Slosser on 11/24/15.
//
//

#import "RZVinylOptions.h"

@implementation RZVinylOptions

+(RZVinylOptions*)sharedOptions
{
    static dispatch_once_t onceToken;
    static RZVinylOptions *singleton;
    dispatch_once(&onceToken, ^{
        singleton = [RZVinylOptions new];
    });
    return singleton;
}

@end
