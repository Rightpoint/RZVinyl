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
    if ( refreshControl.refreshing ) {
        [self.personLoader loadPeopleWithBatchSize:10 completion:^(NSError *err) {
            if ( err ) {
                NSLog(@"Error loading people: %@", err);
            }
            [refreshControl endRefreshing];
        }];
    }
}

@end
