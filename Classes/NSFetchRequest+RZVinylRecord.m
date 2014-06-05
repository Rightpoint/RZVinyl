//
//  NSFetchRequest+RZVinylRecord.m
//  RZVinylDemo
//
//  Created by Nick Donaldson on 6/5/14.
//  Copyright (c) 2014 Raizlabs. All rights reserved.
//

#import "NSFetchRequest+RZVinylRecord.h"

@implementation NSFetchRequest (RZVinylRecord)

+ (instancetype)rzv_forEntity:(NSString *)entityName withPredicate:(NSPredicate *)predicate sort:(NSArray *)sortDescriptors inContext:(NSManagedObjectContext *)context
{
    NSFetchRequest *fetchRequest = [[NSFetchRequest alloc] init];
    NSEntityDescription *entity = [NSEntityDescription entityForName:entityName inManagedObjectContext:context];
    [fetchRequest setEntity:entity];
    
    if ( predicate ) {
        [fetchRequest setPredicate:predicate];
    }
    
    if ( sortDescriptors ) {
        [fetchRequest setSortDescriptors:sortDescriptors];
    }
    
    return fetchRequest;
}

@end
