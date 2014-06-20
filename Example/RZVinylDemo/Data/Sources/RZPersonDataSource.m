//
//  RZPersonDataSource.m
//  RZVinylDemo
//
//  Created by Nick Donaldson on 6/19/14.
//  Copyright (c) 2014 Raizlabs. All rights reserved.
//

#import "RZPersonDataSource.h"

static NSString* const kRZPersonDataSourceRefreshPromptCellIdentifier = @"RefreshPromptCell";

@interface RZPersonDataSource ()

@property (nonatomic, weak) UITableView *tableView;

@end

@implementation RZPersonDataSource

- (instancetype)initWithTableView:(UITableView *)tableView
{
    self = [super init];
    if ( self ) {
        _tableView = tableView;
        [_tableView registerClass:[UITableViewCell class] forCellReuseIdentifier:kRZPersonDataSourceRefreshPromptCellIdentifier];
    }
    return self;
}

#pragma mark - TableView Data Source

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return 1;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    UITableViewCell *cell = nil;
    if ( indexPath.section == tableView.numberOfSections - 1 ) {
        cell = [tableView dequeueReusableCellWithIdentifier:kRZPersonDataSourceRefreshPromptCellIdentifier];
        cell.textLabel.textAlignment = NSTextAlignmentCenter;
        cell.textLabel.text = @"Pull to load more people";
    }
    return cell;
}

@end
