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

@interface RZPersonDetailViewController () <UIAlertViewDelegate>

@property (nonatomic, strong) RZPerson *person;
@property (nonatomic, strong) RZPerson *editingPerson;

@property (nonatomic, weak) UIScrollView *scrollView;
@property (nonatomic, weak) RZPersonDetailView *personView;

@property (nonatomic, strong) NSManagedObjectContext *scratchContext;

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
    
    self.navigationItem.rightBarButtonItem = [self editButtonItem];
    [self.personView updateFromPerson:self.person];
    [self.personView.deletePersonButton addTarget:self
                                           action:@selector(deletePersonPressed)
                                 forControlEvents:UIControlEventTouchUpInside];
}

- (void)setEditing:(BOOL)editing animated:(BOOL)animated
{
    [super setEditing:editing animated:animated];
    
    self.personView.bioTextView.editable = editing;
    self.personView.deletePersonButton.enabled = !editing;
    
    if ( editing ) {
        
        // Create a "scratch" context for editing
        self.scratchContext = [[RZCoreDataStack defaultStack] temporaryManagedObjectContext];
        
        // Get a copy of this person from the scratch context
        self.editingPerson = [RZPerson rzv_objectWithPrimaryKeyValue:self.person.remoteId createNew:NO];
        NSAssert(self.editingPerson != nil, @"Should be able to find matching person in scratch context");
        
        UIBarButtonItem *cancelButton = [[UIBarButtonItem alloc] initWithTitle:@"Cancel"
                                                                         style:UIBarButtonItemStylePlain
                                                                        target:self
                                                                        action:@selector(cancelEdits)];
        
        [self.navigationItem setLeftBarButtonItem:cancelButton animated:animated];
    }
    else {
        
        [self.navigationItem setLeftBarButtonItem:nil animated:animated];
        
        // If there is a valid scratch context, save it.
        if ( self.scratchContext != nil ) {

            NSError *err = nil;
            
            if ( [self.scratchContext save:&err] ) {
                [[RZCoreDataStack defaultStack] save:YES];
            }
            
            self.scratchContext = nil;
            self.editingPerson = nil;
            
            if ( err ) {
                NSLog(@"Error saving person: %@", err);
            }
        }
        
        [self.personView endEditing:YES];
        
        // Our person should have automatically been udpated by saving the scratch context.
        // If the edits were cancelled, this will revert back to the original values.
        [self.personView updateFromPerson:self.person];
    }
}

#pragma mark - Actions

- (void)cancelEdits
{
    self.editingPerson = nil;
    self.scratchContext = nil;
    [self setEditing:NO animated:YES];
}

- (void)deletePersonPressed
{
    [[[UIAlertView alloc] initWithTitle:@"Delete Person"
                                message:@"Are you sure?"
                               delegate:self
                      cancelButtonTitle:@"No"
                      otherButtonTitles:@"Yes", nil] show];
}

#pragma mark - Alert View

- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex
{
    if ( buttonIndex != [alertView cancelButtonIndex] ) {
        [self.person rzv_delete];
        [self.navigationController popViewControllerAnimated:YES];
    }
}

@end
