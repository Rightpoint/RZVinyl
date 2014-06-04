//
//  RZDataStackAccess.h
//  RZVinylDemo
//
//  Created by Nick Donaldson on 6/4/14.
//  Copyright (c) 2014 Raizlabs. All rights reserved.
//

#import "RZDataStack.h"

@interface RZDataStackAccess : NSObject

+ (RZDataStack *)defaultStack;
+ (void)setDefaultStack:(RZDataStack *)defaultStack;

//+ (RZDataStack *)stackWithName:(NSString *)name;
//+ (void)setStack:(RZDataStack *)stack forName:(NSString *)name;

@end
