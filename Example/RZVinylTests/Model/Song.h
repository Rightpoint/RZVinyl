//
//  Song.h
//  RZVinylDemo
//
//  Created by Nick Donaldson on 6/5/14.
//  Copyright (c) 2014 Raizlabs. All rights reserved.
//

#import "BaseObject.h"

@interface Song : BaseObject

@property (nonatomic, retain) NSString * title;
@property (nonatomic, retain) NSNumber * length;
@property (nonatomic, retain) NSManagedObject *artist;

@end
