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

typedef NS_ENUM(NSInteger, RZPersonFilterGenderRow)
{
    RZPersonFilterGenderRowFemale = 0,
    RZPersonFilterGenderRowMale
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

- (NSUInteger)activeFilterCount
{
    return [[self.tableView indexPathsForSelectedRows] count];
}

- (NSPredicate *)filterPredicate
{
    if ( self.activeFilterCount == 0) {
        return nil;
    }
    
    NSMutableArray *subPredicates = [NSMutableArray array];
    [[self.tableView indexPathsForSelectedRows] enumerateObjectsUsingBlock:^(NSIndexPath *indexPath, NSUInteger idx, BOOL *stop) {
        NSPredicate *predicate = [self filterPredicateForIndexPath:indexPath];
        if ( predicate ) {
            [subPredicates addObject:predicate];
        }
    }];
    
    return [NSCompoundPredicate andPredicateWithSubpredicates:subPredicates];
}

#pragma mark - Private

- (void)configureStaticData
{
    self.interestObjects = [RZInterest rzv_all];
}

- (NSPredicate *)filterPredicateForIndexPath:(NSIndexPath *)indexPath
{
    NSPredicate *predicate = nil;
    if ( indexPath.section == RZPersonFiltersSectionGender ) {
        NSString *gender = indexPath.row == RZPersonFilterGenderRowFemale ? @"female" : @"male";
        predicate = [NSPredicate predicateWithFormat:@"gender == %@", gender];
    }
    else if ( indexPath.section == RZPersonFiltersSectionInterests ) {
        RZInterest *interest = [self.interestObjects objectAtIndex:indexPath.row];
        if ( interest ) {
            predicate = [NSPredicate predicateWithFormat:@"%@ IN interests", interest];
        }
    }
    
    return predicate;
}

- (void)updateValidFilters
{
    [[self.tableView indexPathsForVisibleRows] enumerateObjectsUsingBlock:^(NSIndexPath *indexPath, NSUInteger idx, BOOL *stop) {
        [self updateCellForFilterValidity:[self.tableView cellForRowAtIndexPath:indexPath] atIndexPath:indexPath];
    }];
}

- (void)updateCellForFilterValidity:(UITableViewCell *)cell atIndexPath:(NSIndexPath *)indexPath
{
    BOOL selectedRow = [[self.tableView indexPathsForSelectedRows] containsObject:indexPath];
    cell.contentView.alpha = ( selectedRow || [self isFilterValidForIndexPath:indexPath] ) ? 1.0 : 0.3;
}

- (BOOL)isFilterValidForIndexPath:(NSIndexPath *)indexPath
{
    NSPredicate *basePredicate = [self filterPredicate];
    if ( basePredicate == nil ) {
        return YES;
    }
    
    NSPredicate *filterPredicate = [self filterPredicateForIndexPath:indexPath];
    if ( filterPredicate == nil ) {
        return YES;
    }
    
    NSPredicate *compoundPredicate = [NSCompoundPredicate andPredicateWithSubpredicates:@[basePredicate, filterPredicate]];
    return ([RZPerson rzv_countWhere:compoundPredicate] > 0);
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
            count = 2;
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
    if ( indexPath.section == RZPersonFiltersSectionGender ) {
        
        // NOTE: In a real app, should cache this so we don't have to query over and over,
        //       and this might be wrapped by a category method on the managed object class.
        NSString *gender = indexPath.row == RZPersonFilterGenderRowFemale ? @"female" : @"male";
        NSUInteger count = [RZPerson rzv_countWhere:[self filterPredicateForIndexPath:indexPath]];
        [interestCell updateForFilterName:gender count:count];
    }
    else if ( indexPath.section == RZPersonFiltersSectionInterests ) {
        
        // Get the interest object
        RZInterest *interest = [[self interestObjects] objectAtIndex:indexPath.row];
        
        // Get the count of people with that particular interest
        // NOTE: In a real app, should cache this so we don't have to query over and over,
        //       and this might be wrapped by a category method on the managed object class.
        
        NSUInteger count = [RZPerson rzv_countWhere:[self filterPredicateForIndexPath:indexPath]];
        [interestCell updateForFilterName:interest.name count:count];
    }
    
    [self updateCellForFilterValidity:interestCell atIndexPath:indexPath];
    
    return interestCell;
}

#pragma mark - TableView Delegate

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    [self updateValidFilters];
}

- (void)tableView:(UITableView *)tableView didDeselectRowAtIndexPath:(NSIndexPath *)indexPath
{
    [self updateValidFilters];
}

@end
