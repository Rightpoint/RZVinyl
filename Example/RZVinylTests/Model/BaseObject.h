//
//  BaseObject.h
//  RZVinylDemo
//
//  Created by Nick Donaldson on 6/5/14.
//  Copyright (c) 2014 Raizlabs. All rights reserved.
//

@import Foundation;
@import CoreData;

@interface BaseObject : NSManagedObject

@property (nonatomic, retain) NSNumber * remoteID;
@property (nonatomic, retain) NSDate * lastUpdated;

@end
