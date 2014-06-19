//
//  RZAppDelegate.m
//  RZObjectiveRecord
//
//  Created by Nick Donaldson on 6/4/14.
//  Copyright (c) 2014 Raizlabs. All rights reserved.
//

#import "RZAppDelegate.h"

static NSString* const kRZManagedObjectModelName = @"RZVinylDemo";

@implementation RZAppDelegate

- (BOOL)application:(UIApplication *)application willFinishLaunchingWithOptions:(NSDictionary *)launchOptions
{
    [RZCoreDataStack setDefaultStack:[[RZCoreDataStack alloc] initWithModelName:kRZManagedObjectModelName
                                                                  configuration:nil
                                                                      storeType:NSSQLiteStoreType
                                                                       storeURL:nil
                                                                        options:RZCoreDataStackOptionsEnableAutoStalePurge]];
    
    return YES;
}

- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions
{
    self.window = [[UIWindow alloc] initWithFrame:[[UIScreen mainScreen] bounds]];
    // Override point for customization after application launch.
    self.window.backgroundColor = [UIColor whiteColor];
    [self.window makeKeyAndVisible];
    return YES;
}


@end
