//
//  RZStatsViewController.m
//  RZVinylDemo
//
//  Created by Nick Donaldson on 6/23/14.
//  Copyright (c) 2014 Raizlabs. All rights reserved.
//

#import "RZStatsViewController.h"
#import "RZPersonStatsDataSource.h"

@interface RZStatsViewController ()

@property (nonatomic, weak) UITableView *tableView;

@property (nonatomic, strong) RZPersonStatsDataSource *dataSource;

@end

@implementation RZStatsViewController

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if ( self ) {
        self.title = @"Statistics";
    }
    return self;
}

- (void)loadView
{
    UITableView *tableView = [[UITableView alloc] initWithFrame:[[UIScreen mainScreen] bounds]
                                                          style:UITableViewStylePlain];
    self.view = tableView;
    self.tableView = tableView;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc] initWithTitle:@"Done"
                                                                              style:UIBarButtonItemStyleDone
                                                                             target:self
                                                                             action:@selector(dismiss)];
    
    self.dataSource = [[RZPersonStatsDataSource alloc] initWithTableView:self.tableView];
    self.tableView.dataSource = self.dataSource;
}

- (void)dismiss
{
    [self.presentingViewController dismissViewControllerAnimated:YES completion:nil];
}

@end
