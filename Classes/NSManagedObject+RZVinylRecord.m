//
//  NSManagedObject+RZVinylRecord.m
//  RZVinylDemo
//
//  Created by Nick Donaldson on 6/4/14.
//  Copyright (c) 2014 Raizlabs. All rights reserved.
//

#import "NSManagedObject+RZVinylRecord.h"
#import "RZCoreDataStack.h"
#import "RZVinylDefines.h"

@implementation NSManagedObject (RZVinylRecord)

+ (instancetype)rzv_objectWithPrimaryValue:(id)primaryValue createNew:(BOOL)createNew
{
    NSString *primaryKey = [self rzv_primaryKey];
    if ( primaryKey == nil ) {
        RZVLogError(@"No primary key provided for class %@", NSStringFromClass(self));
        return nil;
    }
    
    return nil;
}

#pragma mark - Subclassable

+ (NSString *)rzv_primaryKey
{
    return nil;
}

+ (RZCoreDataStack *)rzv_coreDataStack
{
    return [RZCoreDataStack defaultStack];
}

@end