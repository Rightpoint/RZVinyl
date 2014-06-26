//
//  RZFetchedPersonDataSource.m
//  RZVinylDemo
//
//  Created by Nick Donaldson on 6/19/14.
//  Copyright (c) 2014 Raizlabs. All rights reserved.
//

#import "RZFetchedPersonDataSource.h"
#import "RZPersonTableViewCell.h"
#import "RZAddress.h"

static NSString* const kRZPeronDataSourcePersonCellIdentifier = @"PersonCell";

@interface RZFetchedPersonDataSource () <NSFetchedResultsControllerDelegate>

@property (nonatomic, weak) UITableView *tableView;
@property (nonatomic, strong) NSFetchedResultsController *fetchedResultsController;

@property (nonatomic, copy) RZTableViewDataSourceDidSelectRowBlock didSelectRowBlock;

@end

@implementation RZFetchedPersonDataSource

- (instancetype)initWithTableView:(UITableView *)tableView
{
    self = [super init];
    if ( self ) {
        _tableView = tableView;
        
        UINib *personCellNib = [UINib nibWithNibName:NSStringFromClass([RZPersonTableViewCell class]) bundle:nil];
        [_tableView registerNib:personCellNib forCellReuseIdentifier:kRZPeronDataSourcePersonCellIdentifier];
        [_tableView setRowHeight:[RZPersonTableViewCell nominalHeight]];

        _fetchedResultsController = [NSFetchedResultsController rzv_forEntity:[RZPerson rzv_entityName]
                                                                    inContext:[[RZCoreDataStack defaultStack] mainManagedObjectContext]
                                                                        where:nil
                                                                         sort:@[ RZVKeySort(NSStringFromSelector(@selector(sortIndex)), NO) ]];
        _fetchedResultsController.delegate = self;
        [self updateFetch];
    }
    return self;
}

- (RZPerson *)personAtIndexPath:(NSIndexPath *)indexPath
{
    if ( indexPath.section >= [[self.fetchedResultsController sections] count] ) {
        return nil;
    }
    
    NSArray *sectionObjects = [[[self.fetchedResultsController sections] objectAtIndex:indexPath.section] objects];
    if ( indexPath.row >= sectionObjects.count ) {
        return nil;
    }
    
    return sectionObjects[indexPath.row];
}

- (NSArray *)allObjects
{
    return [self.fetchedResultsController fetchedObjects];
}

- (void)setFilterPredicate:(NSPredicate *)filterPredicate
{
    _filterPredicate = filterPredicate;
    [self updateFetch];
}

#pragma mark - Private

- (void)updateFetch
{
    [self.fetchedResultsController.fetchRequest setPredicate:self.filterPredicate];
    
    NSError *fetchError = nil;
    if ( ![self.fetchedResultsController performFetch:&fetchError] ) {
        NSLog(@"Error fetching people: %@", fetchError);
    }
    
    [self.tableView reloadData];
}

#pragma mark - TableView Data Source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return [[self.fetchedResultsController sections] count];
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return [[[self.fetchedResultsController sections] objectAtIndex:section] numberOfObjects];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    RZPerson *person = [self personAtIndexPath:indexPath];
    RZPersonTableViewCell *personCell = [tableView dequeueReusableCellWithIdentifier:kRZPeronDataSourcePersonCellIdentifier forIndexPath:indexPath];
    [personCell updateForPerson:person];
    return personCell;
}

- (BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath
{
    return YES;
}

- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath
{
    if ( editingStyle == UITableViewCellEditingStyleDelete ) {
        RZPerson *person = [self personAtIndexPath:indexPath];
        [person rzv_delete];
        
        [person.managedObjectContext rzv_saveToStoreWithCompletion:^(NSError *error) {
            if ( error ) {
                NSLog(@"Error saving delete of person: %@", error);
            }
        }];
        
    }
}

#pragma mark - Table View Delegate

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    if ( self.didSelectRowBlock ) {
        self.didSelectRowBlock(tableView, [self personAtIndexPath:indexPath], indexPath);
    }
}

#pragma mark - NSFetchedResultsControllerDelegate

- (void)controllerWillChangeContent:(NSFetchedResultsController *)controller
{
    [self.tableView beginUpdates];
}

- (void)controller:(NSFetchedResultsController *)controller
  didChangeSection:(id<NSFetchedResultsSectionInfo>)sectionInfo
           atIndex:(NSUInteger)sectionIndex
     forChangeType:(NSFetchedResultsChangeType)type
{
    switch ( type ) {
        case NSFetchedResultsChangeInsert:
            [self.tableView insertSections:[NSIndexSet indexSetWithIndex:sectionIndex]
                          withRowAnimation:UITableViewRowAnimationAutomatic];
            break;
            
        case NSFetchedResultsChangeDelete:
            [self.tableView deleteSections:[NSIndexSet indexSetWithIndex:sectionIndex]
                          withRowAnimation:UITableViewRowAnimationAutomatic];
            break;
            
        default:
            break;
    }
}

- (void)controller:(NSFetchedResultsController *)controller
   didChangeObject:(id)anObject
       atIndexPath:(NSIndexPath *)indexPath
     forChangeType:(NSFetchedResultsChangeType)type
      newIndexPath:(NSIndexPath *)newIndexPath
{
    switch ( type ) {
            
        case NSFetchedResultsChangeInsert:
            [self.tableView insertRowsAtIndexPaths:@[newIndexPath]
                                  withRowAnimation:UITableViewRowAnimationAutomatic];
            break;
            
        case NSFetchedResultsChangeDelete:
            [self.tableView deleteRowsAtIndexPaths:@[indexPath]
                                  withRowAnimation:UITableViewRowAnimationAutomatic];
            break;
            
        case NSFetchedResultsChangeUpdate: {
            RZPersonTableViewCell *cell = (RZPersonTableViewCell *)[self.tableView cellForRowAtIndexPath:indexPath];
            [cell updateForPerson:[self personAtIndexPath:indexPath]];
        }
            break;
            
        case NSFetchedResultsChangeMove:
            [self.tableView moveRowAtIndexPath:indexPath toIndexPath:newIndexPath];
            break;
            
        default:
            break;
    }
}

- (void)controllerDidChangeContent:(NSFetchedResultsController *)controller
{
    [self.tableView endUpdates];
}

@end
