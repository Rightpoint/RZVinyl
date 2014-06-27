//
//  RZInterest.h
//  RZVinylDemo
//
//  Created by Nick Donaldson on 6/20/14.
//  Copyright (c) 2014 Raizlabs. All rights reserved.
//

@import CoreData;

@class RZPerson;

@interface RZInterest : NSManagedObject

@property (nonatomic, retain) NSString * name;
@property (nonatomic, retain) NSSet *people;
@end

@interface RZInterest (CoreDataGeneratedAccessors)

- (void)addPeopleObject:(RZPerson *)value;
- (void)removePeopleObject:(RZPerson *)value;
- (void)addPeople:(NSSet *)values;
- (void)removePeople:(NSSet *)values;

@end
