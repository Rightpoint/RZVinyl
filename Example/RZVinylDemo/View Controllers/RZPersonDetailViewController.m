//
//  RZPersonDetailViewController.m
//  RZVinylDemo
//
//  Created by Nick Donaldson on 6/23/14.
//  Copyright (c) 2014 Raizlabs. All rights reserved.
//

#import "RZPersonDetailViewController.h"
#import "RZPersonDetailView.h"
#import "RZPerson.h"

@interface RZPersonDetailViewController ()

@property (nonatomic, strong) RZPerson *person;

@property (nonatomic, weak) UIScrollView *scrollView;
@property (nonatomic, weak) RZPersonDetailView *personView;

@end

@implementation RZPersonDetailViewController

- (id)initWithPerson:(RZPerson *)person
{
    self = [super initWithNibName:nil bundle:nil];
    if (self) {
        _person = person;
        self.title = person.name;
    }
    return self;
}

- (void)loadView
{
    self.view = [[UIView alloc] initWithFrame:[[UIScreen mainScreen] bounds]];
    self.view.backgroundColor = [UIColor whiteColor];
    
    UIScrollView *scrollView = [[UIScrollView alloc] initWithFrame:self.view.bounds];
    scrollView.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
    scrollView.bounces = YES;
    scrollView.alwaysBounceVertical = YES;
    [self.view addSubview:scrollView];
    self.scrollView = scrollView;
    
    RZPersonDetailView *personView = [RZPersonDetailView loadFromNib];
    personView.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight | UIViewAutoresizingFlexibleBottomMargin;
    personView.frame = CGRectMake(0, 0, CGRectGetWidth(scrollView.frame), CGRectGetHeight(personView.frame));
    [scrollView addSubview:personView];
    self.personView = personView;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    [self.personView updateFromPerson:self.person];
}

@end
