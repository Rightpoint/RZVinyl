//
//  RZFetchedPersonDataSource.h
//  RZVinylDemo
//
//  Created by Nick Donaldson on 6/19/14.
//  Copyright (c) 2014 Raizlabs. All rights reserved.
//

#import "RZPerson.h"
#import "RZTableViewDataSourceBlocks.h"

@class RZFetchedPersonDataSource;

/**
 *  Data source for person objects.
 */
@interface RZFetchedPersonDataSource : NSObject <UITableViewDataSource, UITableViewDelegate>

- (instancetype)initWithTableView:(UITableView *)tableView;
- (RZPerson *)personAtIndexPath:(NSIndexPath *)indexPath;
- (NSArray *)allObjects;

- (void)setDidSelectRowBlock:(RZTableViewDataSourceDidSelectRowBlock)block;

@end
