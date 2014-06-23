//
//  RZPersonStatsDataSource.m
//  RZVinylDemo
//
//  Created by Nick Donaldson on 6/23/14.
//  Copyright (c) 2014 Raizlabs. All rights reserved.
//

#import "RZPersonStatsDataSource.h"
#import "RZInterestTableViewCell.h"

static NSString* const kRZPersonDataSourceInterestCell = @"InterestCell";

typedef NS_ENUM(NSInteger, RZPersonStatsSectionType)
{
    RZPersonStatsSectionGender = 0,
    RZPersonStatsSectionInterests
};

@interface RZPersonStatsDataSource ()

@property (nonatomic, weak) UITableView *tableView;

@property (nonatomic, strong) NSArray *interestObjects;

@end

@implementation RZPersonStatsDataSource

- (instancetype)initWithTableView:(UITableView *)tableView
{
    self = [super init];
    if ( self ) {
        _tableView = tableView;
        [_tableView registerClass:[RZInterestTableViewCell class] forCellReuseIdentifier:kRZPersonDataSourceInterestCell];
        [self configureStaticData];
    }
    return self;
}

- (void)configureStaticData
{
    self.interestObjects = [RZInterest rzv_all];
}

#pragma mark - TableView Data Source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 2;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    NSInteger count = 0;
    switch (section) {
            
        case RZPersonStatsSectionGender:
            count = 0;
            break;
            
        case RZPersonStatsSectionInterests:
            count = self.interestObjects.count;
            break;
            
        default:
            break;
    }
    return count;
}

- (NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section
{
    NSString *titleString = nil;
    switch (section) {
            
        case RZPersonStatsSectionGender:
            titleString = @"Gender";
            break;
            
        case RZPersonStatsSectionInterests:
            titleString = @"Interests";
            break;
            
        default:
            break;
    }
    return titleString;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    UITableViewCell *cell = nil;
    if ( indexPath.section == RZPersonStatsSectionInterests ) {
        
        // Get the interest object
        RZInterest *interest = [[self interestObjects] objectAtIndex:indexPath.row];
        
        // Get the count of people with that particular interest
        // NOTE: In a real app, should cache this so we don't have to query over and over
        NSUInteger count = [RZPerson rzv_countWhere:[NSPredicate predicateWithFormat:@"%@ IN interests", interest]];
        
        RZInterestTableViewCell *interestCell = [tableView dequeueReusableCellWithIdentifier:kRZPersonDataSourceInterestCell forIndexPath:indexPath];
        [interestCell updateForInterestName:interest.name count:count];
        cell = interestCell;
    }
    return cell;
}

#pragma mark - TableView Delegate

@end
