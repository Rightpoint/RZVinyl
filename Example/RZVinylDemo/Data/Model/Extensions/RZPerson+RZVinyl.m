//
//  RZPerson+RZVinyl.m
//  RZVinylDemo
//
//  Created by Nick Donaldson on 6/20/14.
//  Copyright (c) 2014 Raizlabs. All rights reserved.
//

#import "RZPerson+RZVinyl.h"

@implementation RZPerson (RZVinyl)

+ (NSString *)rzv_primaryKey
{
    return NSStringFromSelector(@selector(remoteId));
}

+ (NSString *)rzv_externalPrimaryKey
{
    return @"id";
}

- (BOOL)rzi_shouldImportValue:(id)value forKey:(NSString *)key inContext:(NSManagedObjectContext *)context
{
#warning Fix this
    if ( [key isEqualToString:@"interests"] ) {
        return NO;
    }
    
    return [super rzi_shouldImportValue:value forKey:key inContext:context];
}

@end
