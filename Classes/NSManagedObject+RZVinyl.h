//
//  NSManagedObject+RZVinyl.h
//  RZVinylDemo
//
//  Created by Nick Donaldson on 6/4/14.
//  Copyright (c) 2014 Raizlabs. All rights reserved.
//

@import CoreData;
#import "RZAutoImportable.h"

@class RZDataStack;

@interface NSManagedObject (RZVinyl) <RZAutoImportable>

+ (NSString *)rzv_primaryKey;

+ (RZDataStack *)rzv_dataStack;

@end
