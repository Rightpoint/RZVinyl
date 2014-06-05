//
//  NSFetchRequest+RZVinylRecord.h
//  RZVinylDemo
//
//  Created by Nick Donaldson on 6/5/14.
//  Copyright (c) 2014 Raizlabs. All rights reserved.
//

#import <CoreData/CoreData.h>

@interface NSFetchRequest (RZVinylRecord)

+ (instancetype)rzv_forEntity:(NSString *)entityName
                withPredicate:(NSPredicate *)predicate
                         sort:(NSArray *)sortDescriptors
                    inContext:(NSManagedObjectContext *)context;

@end
