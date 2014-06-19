//
//  RZPersonListViewController.m
//  RZVinylDemo
//
//  Created by Nick Donaldson on 6/19/14.
//  Copyright (c) 2014 Raizlabs. All rights reserved.
//

#import "RZPersonListViewController.h"
#import "RZPersonDataSource.h"

@interface RZPersonListViewController ()

@property (nonatomic, strong) RZPersonDataSource *dataSource;

@end

@implementation RZPersonListViewController

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        self.title = @"People";
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
        
    UIRefreshControl *refreshControl = [[UIRefreshControl alloc] init];
    [refreshControl addTarget:self action:@selector(refreshControlChangedState:) forControlEvents:UIControlEventValueChanged];
    self.refreshControl = refreshControl;
    
    self.dataSource = [[RZPersonDataSource alloc] initWithTableView:self.tableView];
    self.tableView.dataSource = self.dataSource;
}

- (void)setEditing:(BOOL)editing
{
    [super setEditing:editing];
}

#pragma mark - Private

- (void)refreshControlChangedState:(UIRefreshControl *)refreshControl
{
    [refreshControl endRefreshing];
}

@end
