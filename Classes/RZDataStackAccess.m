//
//  RZDataStackAccess.m
//  RZVinylDemo
//
//  Created by Nick Donaldson on 6/4/14.
//  Copyright (c) 2014 Raizlabs. All rights reserved.
//

#import "RZDataStackAccess.h"

@implementation RZDataStackAccess

static RZDataStack *s_defaultStack = nil;

+ (void)load
{
    [self buildDefaultStack];
}

+ (RZDataStack *)defaultStack
{
    return s_defaultStack;
}

+ (void)setDefaultStack:(RZDataStack *)defaultStack
{
    s_defaultStack = defaultStack;
}

#pragma mark - Privte

+ (void)buildDefaultStack
{
    NSString *modelName    = [[NSBundle mainBundle] objectForInfoDictionaryKey:@"RZVDataModelName"];
    if ( modelName == nil ) {
        return;
    }
    
    NSString *configName   = [[NSBundle mainBundle] objectForInfoDictionaryKey:@"RZVDataModelConfiguration"];
    NSString *storeTypeRaw = [[NSBundle mainBundle] objectForInfoDictionaryKey:@"RZVPersistentStoreType"];
    
    NSString *storeType = nil;
    if ( storeTypeRaw ) {
        if ( [storeTypeRaw isEqualToString:@"memory"] ) {
            storeType = NSInMemoryStoreType;
        }
        else if ( [storeTypeRaw isEqualToString:@"sqlite"] ) {
            storeType = NSSQLiteStoreType;
        }
        else {
            storeType = NSInMemoryStoreType;
            NSLog(@"[RZDataStackAccess] WARNING: Unknown store type \"%@\" in info.plist. Defaulting to in-memory store.", storeTypeRaw);
        }
    }
    
    RZDataStack *defaultStack = [[RZDataStack alloc] initWithModelName:modelName
                                                         configuration:configName
                                                             storeType:storeType
                                                              storeURL:nil
                                                               options:kNilOptions];
    
    if ( defaultStack != nil ) {
        [self setDefaultStack:defaultStack];
    }
    else {
        NSLog(@"[RZDataStackAccess] ERROR: Could not build default CoreData stack from info.plist values. Please check your entries:");
        NSLog(@"Model Name (RZVDataModelName): %@", modelName);
        if ( configName ) {
            NSLog(@"Config Name (RZVDataModelConfiguration): %@", configName);
        }
        if ( storeTypeRaw ) {
            NSLog(@"Persistent Store Type (RZVPersistentStoreType): %@", storeTypeRaw);
        }
    }
}

@end
