//
//  RZPersonFiltersViewController.m
//  RZVinylDemo
//
//  Created by Nick Donaldson on 6/23/14.
//  Copyright (c) 2014 Raizlabs. All rights reserved.
//

#import "RZPersonFiltersViewController.h"
#import "RZPersonFiltersDataSource.h"

@interface RZPersonFiltersViewController ()

@property (nonatomic, weak) UITableView *tableView;

@property (nonatomic, strong) RZPersonFiltersDataSource *dataSource;

@end

@implementation RZPersonFiltersViewController

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
    
    self.dataSource = [[RZPersonFiltersDataSource alloc] initWithTableView:self.tableView];
    self.tableView.dataSource = self.dataSource;
}

- (void)dismiss
{
    [self.presentingViewController dismissViewControllerAnimated:YES completion:nil];
}

@end
