//
//  RZPersonDataSource.h
//  RZVinylDemo
//
//  Created by Nick Donaldson on 6/19/14.
//  Copyright (c) 2014 Raizlabs. All rights reserved.
//

#import "RZPerson.h"

@class  RZPersonDataSource;

typedef void (^RZPersonDataSourceDidSelectRowBlock)(RZPersonDataSource *dataSource, UITableView *tableView, NSIndexPath *indexPath);

/**
 *  Data source for person objects.
 */
@interface RZPersonDataSource : NSObject <UITableViewDataSource, UITableViewDelegate>

/**
 *  The predicate for the internal fetched results controller.
 *  Set to nil to fetch all objects.
 */
@property (nonatomic, strong) NSPredicate *predicate;

- (instancetype)initWithTableView:(UITableView *)tableView;
- (RZPerson *)personAtIndexPath:(NSIndexPath *)indexPath;
- (NSArray *)allObjects;

- (void)setDidSelectRowBlock:(RZPersonDataSourceDidSelectRowBlock)block;

@end
