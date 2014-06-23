//
//  RZPersonFiltersDataSource.m
//  RZVinylDemo
//
//  Created by Nick Donaldson on 6/23/14.
//  Copyright (c) 2014 Raizlabs. All rights reserved.
//

#import "RZPersonFiltersDataSource.h"
#import "RZFilterTableViewCell.h"

static NSString* const kRZPersonFiltersDataSourceFilterCellIdentifier = @"FilterCell";

typedef NS_ENUM(NSInteger, RZPersonFiltersSectionType)
{
    RZPersonFiltersSectionGender = 0,
    RZPersonFiltersSectionInterests
};

@interface RZPersonFiltersDataSource ()

@property (nonatomic, weak) UITableView *tableView;

@property (nonatomic, strong) NSArray *interestObjects;

@end

@implementation RZPersonFiltersDataSource

- (instancetype)initWithTableView:(UITableView *)tableView
{
    self = [super init];
    if ( self ) {
        _tableView = tableView;
        [_tableView registerClass:[RZFilterTableViewCell class] forCellReuseIdentifier:kRZPersonFiltersDataSourceFilterCellIdentifier];
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
            
        case RZPersonFiltersSectionGender:
            count = 0;
            break;
            
        case RZPersonFiltersSectionInterests:
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
            
        case RZPersonFiltersSectionGender:
            titleString = @"Gender";
            break;
            
        case RZPersonFiltersSectionInterests:
            titleString = @"Interests";
            break;
            
        default:
            break;
    }
    return titleString;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    RZFilterTableViewCell *interestCell = [tableView dequeueReusableCellWithIdentifier:kRZPersonFiltersDataSourceFilterCellIdentifier
                                                                          forIndexPath:indexPath];
    if ( indexPath.section == RZPersonFiltersSectionInterests ) {
        
        // Get the interest object
        RZInterest *interest = [[self interestObjects] objectAtIndex:indexPath.row];
        
        // Get the count of people with that particular interest
        // NOTE: In a real app, should cache this so we don't have to query over and over
        NSUInteger count = [RZPerson rzv_countWhere:[NSPredicate predicateWithFormat:@"%@ IN interests", interest]];

        [interestCell updateForFilterName:interest.name count:count];
    }
    return interestCell;
}

#pragma mark - TableView Delegate

@end
