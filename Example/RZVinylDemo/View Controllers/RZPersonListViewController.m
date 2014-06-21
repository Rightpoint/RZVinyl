//
//  RZPersonListViewController.m
//  RZVinylDemo
//
//  Created by Nick Donaldson on 6/19/14.
//  Copyright (c) 2014 Raizlabs. All rights reserved.
//

#import "RZPersonListViewController.h"
#import "RZPersonLoader.h"
#import "RZPersonDataSource.h"

@interface RZPersonListViewController ()

@property (nonatomic, strong) RZPersonLoader *personLoader;
@property (nonatomic, strong) RZPersonDataSource *dataSource;

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

    [self setupDataSource];
}

#pragma mark - Private

- (void)setupDataSource
{
    self.dataSource = [[RZPersonDataSource alloc] initWithTableView:self.tableView];
    [self.dataSource setDidSelectRowBlock:^(RZPersonDataSource *dataSource, UITableView *tableView, NSIndexPath *indexPath) {
        [tableView deselectRowAtIndexPath:indexPath animated:YES];
        // TODO: Push view controller for the person details
//        RZPerson *person = [dataSource personAtIndexPath:indexPath];
    }];
    self.tableView.delegate     = self.dataSource;
    self.tableView.dataSource   = self.dataSource;
}

- (void)refreshControlChangedState:(UIRefreshControl *)refreshControl
{
    if ( refreshControl.refreshing ) {
        [self.personLoader loadPeopleWithBatchSize:10 completion:^(NSError *err) {
            if ( err ) {
                NSLog(@"Error loading people: %@", err);
            }
            else if ( self.tableView.tableHeaderView != nil ) {
                self.tableView.tableHeaderView = nil;
            }
            [refreshControl endRefreshing];
        }];
    }
}

@end
