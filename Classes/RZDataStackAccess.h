//
//  RZDataStackAccess.h
//  RZVinylDemo
//
//  Created by Nick Donaldson on 6/4/14.
//  Copyright (c) 2014 Raizlabs. All rights reserved.
//

#import "RZDataStack.h"

@interface RZDataStackAccess : NSObject

/**
 *  The default CoreData stack for this application.
 *  Automatically configured on app launch using default settings, if @p RZVDataModelName is present in @p info.plist.
 *  Otherwise defaults to nil.
 *  
 *  Can be further customized by adding the following keys to the @p info.plist.
 *
 *  @p RZVDataModelName (required) - The name of the CoreData model file, without any extension
 *
 *  @p RZVDataModelConfiguration - The name of a configuration from the data model to use. 
 *                                 Defaults to the default configuration.
 *
 *  @p RZVPersistentStoreType  - Either "sqlite" or "memory". Defaults to "memory".
 *
 *  @note More specialized configurations should init and set the default stack manually using @p +setDefaultStack:
 *
 *  @return The default @p RZDataStack for this application.
 */
+ (RZDataStack *)defaultStack;

/**
 *  Set the default CoreData stack for this application.
 *  This is not necessary if using @p info.plist keys to define
 *  the CoreData stack (see above).
 *
 *  @warning It is recommended to set this early in app lifetime,
 *           such as during @p appDidFinishLaunching:. Do NOT change
 *           the default stack while it is in use.
 *
 *  @param defaultStack The new default CoreData stack.
 */
+ (void)setDefaultStack:(RZDataStack *)defaultStack;

// TODO:
//+ (RZDataStack *)stackWithName:(NSString *)name;
//+ (void)setStack:(RZDataStack *)stack forName:(NSString *)name;

@end
