//
//  Song.h
//  RZVinylDemo
//
//  Created by Nick Donaldson on 7/28/14.
//  Copyright (c) 2014 Raizlabs. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>
#import "BaseObject.h"

@class Artist;

@interface Song : BaseObject

@property (nonatomic, retain) NSNumber * length;
@property (nonatomic, retain) NSString * title;
@property (nonatomic, retain) Artist *artist;
@property (nonatomic, retain) Artist *orderedArtist;

@end
