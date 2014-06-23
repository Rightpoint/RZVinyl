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
    scrollView.translatesAutoresizingMaskIntoConstraints = NO;
    scrollView.bounces = YES;
    scrollView.alwaysBounceVertical = YES;
    [self.view addSubview:scrollView];
    self.scrollView = scrollView;
    
    RZPersonDetailView *personView = [RZPersonDetailView loadFromNib];
    personView.translatesAutoresizingMaskIntoConstraints = NO;
    [scrollView addSubview:personView];
    self.personView = personView;
    
    NSDictionary *viewBindings = NSDictionaryOfVariableBindings(scrollView, personView);
    [self.view addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"H:|[scrollView]|" options:kNilOptions metrics:nil views:viewBindings]];
    [self.view addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"V:|[scrollView]|" options:kNilOptions metrics:nil views:viewBindings]];
    [self.scrollView addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"H:|[personView(==scrollView)]|" options:kNilOptions metrics:nil views:viewBindings]];
    [self.scrollView addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"V:|[personView]|" options:kNilOptions metrics:nil views:viewBindings]];
    
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    [self.personView updateFromPerson:self.person];
}

@end
