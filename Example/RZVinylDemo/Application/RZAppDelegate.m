//
//  RZAppDelegate.m
//  RZObjectiveRecord
//
//  Created by Nick Donaldson on 6/4/14.
//  Copyright (c) 2014 Raizlabs. All rights reserved.
//

#import "RZAppDelegate.h"
#import "RZPersonListViewController.h"

static NSString* const kRZManagedObjectModelName = @"RZVinylDemo";

@implementation RZAppDelegate

- (BOOL)application:(UIApplication *)application willFinishLaunchingWithOptions:(NSDictionary *)launchOptions
{
    RZCoreDataStackOptions options = RZCoreDataStackOptionsDeleteDatabaseIfUnreadable | RZCoreDataStackOptionsEnableAutoStalePurge;
    [RZCoreDataStack setDefaultStack:[[RZCoreDataStack alloc] initWithModelName:kRZManagedObjectModelName
                                                                  configuration:nil
                                                                      storeType:NSInMemoryStoreType
                                                                       storeURL:nil
                                                                        options:options]];
    return YES;
}

- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions
{
    RZPersonListViewController *personListVC = [[RZPersonListViewController alloc] initWithNibName:nil bundle:nil];
    UINavigationController *rootNavController = [[UINavigationController alloc] initWithRootViewController:personListVC];
    
    self.window = [[UIWindow alloc] initWithFrame:[[UIScreen mainScreen] bounds]];
    self.window.rootViewController = rootNavController;
    self.window.backgroundColor = [UIColor whiteColor];
    [self.window makeKeyAndVisible];
    return YES;
}

@end
