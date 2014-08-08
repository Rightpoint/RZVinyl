//
//  Artist.h
//  RZVinylDemo
//
//  Created by Nick Donaldson on 7/28/14.
//  Copyright (c) 2014 Raizlabs. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>
#import "BaseObject.h"

@class Song;

@interface Artist : BaseObject

@property (nonatomic, retain) NSString * genre;
@property (nonatomic, retain) NSString * name;
@property (nonatomic, retain) NSNumber * popularity;
@property (nonatomic, retain) NSSet *songs;
@property (nonatomic, retain) NSOrderedSet *orderedSongs;
@end

@interface Artist (CoreDataGeneratedAccessors)

- (void)addSongsObject:(Song *)value;
- (void)removeSongsObject:(Song *)value;
- (void)addSongs:(NSSet *)values;
- (void)removeSongs:(NSSet *)values;

- (void)insertObject:(Song *)value inOrderedSongsAtIndex:(NSUInteger)idx;
- (void)removeObjectFromOrderedSongsAtIndex:(NSUInteger)idx;
- (void)insertOrderedSongs:(NSArray *)value atIndexes:(NSIndexSet *)indexes;
- (void)removeOrderedSongsAtIndexes:(NSIndexSet *)indexes;
- (void)replaceObjectInOrderedSongsAtIndex:(NSUInteger)idx withObject:(Song *)value;
- (void)replaceOrderedSongsAtIndexes:(NSIndexSet *)indexes withOrderedSongs:(NSArray *)values;
- (void)addOrderedSongsObject:(Song *)value;
- (void)removeOrderedSongsObject:(Song *)value;
- (void)addOrderedSongs:(NSOrderedSet *)values;
- (void)removeOrderedSongs:(NSOrderedSet *)values;
@end
