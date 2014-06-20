//
//  RZPerson.h
//  RZVinylDemo
//
//  Created by Nick Donaldson on 6/20/14.
//  Copyright (c) 2014 Raizlabs. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>

@class RZAddress, RZInterest;

@interface RZPerson : NSManagedObject

@property (nonatomic, retain) NSString * bio;
@property (nonatomic, retain) NSString * gender;
@property (nonatomic, retain) NSString * name;
@property (nonatomic, retain) NSNumber * remoteId;
@property (nonatomic, retain) NSNumber * sortIndex;
@property (nonatomic, retain) NSSet *interests;
@property (nonatomic, retain) RZAddress *address;
@end

@interface RZPerson (CoreDataGeneratedAccessors)

- (void)addInterestsObject:(RZInterest *)value;
- (void)removeInterestsObject:(RZInterest *)value;
- (void)addInterests:(NSSet *)values;
- (void)removeInterests:(NSSet *)values;

@end
