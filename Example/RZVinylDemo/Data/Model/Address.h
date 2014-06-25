//
//  Address.h
//  RZVinylDemo
//
//  Created by Nick Donaldson on 6/20/14.
//  Copyright (c) 2014 Raizlabs. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>

@class RZPerson;

@interface Address : NSManagedObject

@property (nonatomic, retain) NSString * street;
@property (nonatomic, retain) NSString * city;
@property (nonatomic, retain) NSString * state;
@property (nonatomic, retain) RZPerson *person;

@end
