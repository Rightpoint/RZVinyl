//
//  RZPersonListViewController.m
//  RZVinylDemo
//
//  Created by Nick Donaldson on 6/19/14.
//  Copyright (c) 2014 Raizlabs. All rights reserved.
//

#import "RZPersonListViewController.h"
#import "RZPersonFiltersViewController.h"
#import "RZPersonLoader.h"
#import "RZFetchedPersonDataSource.h"

@interface RZPersonListViewController () <RZPersonFiltersViewControllerDelegate>

@property (nonatomic, strong) RZPersonLoader *personLoader;
@property (nonatomic, strong) RZFetchedPersonDataSource *dataSource;

@property (nonatomic, strong) RZPersonFiltersViewController *filtersVC;

@end

@implementation RZPersonListViewController

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        _personLoader = [[RZPersonLoader alloc] init];
        self.title = @"RZVinyl Demo";
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    self.tableView.backgroundColor = [UIColor rz_lightRed];
    self.tableView.separatorStyle = UITableViewCellSeparatorStyleNone;
    [self.tableView rz_addTableHeaderLabelWithText:@"pull to load people"];
        
    UIRefreshControl *refreshControl = [[UIRefreshControl alloc] init];
    refreshControl.tintColor = [UIColor whiteColor];
    [refreshControl addTarget:self action:@selector(refreshControlChangedState:) forControlEvents:UIControlEventValueChanged];
    self.refreshControl = refreshControl;
    
    UIBarButtonItem *filtersButton = [[UIBarButtonItem alloc] initWithTitle:@"Filters"
                                                                      style:UIBarButtonItemStylePlain
                                                                     target:self
                                                                     action:@selector(showFilters)];
    filtersButton.enabled = NO;
    self.navigationItem.rightBarButtonItem = filtersButton;
    
    // Keeping this around to persist the selected filters.
    self.filtersVC = [[RZPersonFiltersViewController alloc] initWithNibName:nil bundle:nil];
    self.filtersVC.delegate = self;

    [self setupDataSource];
}

#pragma mark - Private

- (void)setupDataSource
{
    self.dataSource = [[RZFetchedPersonDataSource alloc] initWithTableView:self.tableView];
    [self.dataSource setDidSelectRowBlock:^(UITableView *tableView, RZPerson *person, NSIndexPath *indexPath) {
        [tableView deselectRowAtIndexPath:indexPath animated:YES];
        // TODO: Push view controller for the person details
    }];
    self.tableView.delegate     = self.dataSource;
    self.tableView.dataSource   = self.dataSource;
}

- (void)showFilters
{
    UINavigationController *modalNav = [[UINavigationController alloc] initWithRootViewController:self.filtersVC];
    [self presentViewController:modalNav animated:YES completion:nil];
}

- (void)refreshControlChangedState:(UIRefreshControl *)refreshControl
{
    if ( refreshControl.refreshing ) {
        [self.personLoader loadPeopleWithBatchSize:10 completion:^(NSError *err) {
            if ( err ) {
                NSLog(@"Error loading people: %@", err);
            }
            else if ( self.tableView.tableHeaderView != nil ) {
                self.navigationItem.rightBarButtonItem.enabled = YES;
                self.tableView.tableHeaderView = nil;
            }
            [refreshControl endRefreshing];
        }];
    }
}

#pragma mark - Filters Delegate

- (void)filtersViewController:(RZPersonFiltersViewController *)viewController dismissedWithPredicate:(NSPredicate *)filterPredicate filterCount:(NSUInteger)filterCount
{
    if ( filterPredicate == nil ) {
        
    }
    else {
        
    }
}

@end
