//
//  RZPersonStatsDataSource.h
//  RZVinylDemo
//
//  Created by Nick Donaldson on 6/23/14.
//  Copyright (c) 2014 Raizlabs. All rights reserved.
//

#import "RZPerson.h"
#import "RZAddress.h"
#import "RZInterest.h"

@interface RZPersonStatsDataSource : NSObject <UITableViewDataSource>

- (instancetype)initWithTableView:(UITableView *)tableView;

@end
