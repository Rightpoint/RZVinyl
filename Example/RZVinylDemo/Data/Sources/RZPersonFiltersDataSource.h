//
//  RZPersonFiltersDataSource.h
//  RZVinylDemo
//
//  Created by Nick Donaldson on 6/23/14.
//  Copyright (c) 2014 Raizlabs. All rights reserved.
//

#import "RZPerson.h"
#import "RZAddress.h"
#import "RZInterest.h"

@interface RZPersonFiltersDataSource : NSObject <UITableViewDataSource, UITableViewDelegate>

- (instancetype)initWithTableView:(UITableView *)tableView;

@property (nonatomic, readonly) NSUInteger activeFilterCount;
@property (nonatomic, readonly) NSPredicate *filterPredicate;

@end
