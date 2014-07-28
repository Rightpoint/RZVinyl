//
//  BaseObject.h
//  RZVinylDemo
//
//  Created by Nick Donaldson on 7/28/14.
//  Copyright (c) 2014 Raizlabs. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>


@interface BaseObject : NSManagedObject

@property (nonatomic, retain) NSDate * lastUpdated;
@property (nonatomic, retain) NSNumber * remoteID;

@end
