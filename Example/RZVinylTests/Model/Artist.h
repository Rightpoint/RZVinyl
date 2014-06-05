//
//  Artist.h
//  RZVinylDemo
//
//  Created by Nick Donaldson on 6/5/14.
//  Copyright (c) 2014 Raizlabs. All rights reserved.
//

#import "BaseObject.h"

@class Song;

@interface Artist : BaseObject

@property (nonatomic, retain) NSString * name;
@property (nonatomic, retain) NSString * genre;
@property (nonatomic, retain) NSNumber * popularity;
@property (nonatomic, retain) NSSet *songs;
@end

@interface Artist (CoreDataGeneratedAccessors)

- (void)addSongsObject:(Song *)value;
- (void)removeSongsObject:(Song *)value;
- (void)addSongs:(NSSet *)values;
- (void)removeSongs:(NSSet *)values;

@end
