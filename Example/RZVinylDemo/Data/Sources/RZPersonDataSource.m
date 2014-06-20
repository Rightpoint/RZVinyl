//
//  RZPersonDataSource.m
//  RZVinylDemo
//
//  Created by Nick Donaldson on 6/19/14.
//  Copyright (c) 2014 Raizlabs. All rights reserved.
//

#import "RZPersonDataSource.h"
#import "RZPersonTableViewCell.h"

static NSString* const kRZPeronDataSourcePersonCellIdentifier = @"PersonCell";

@interface RZPersonDataSource () <NSFetchedResultsControllerDelegate>

@property (nonatomic, weak) UITableView *tableView;
@property (nonatomic, strong) NSFetchedResultsController *fetchedResultsController;

@end

@implementation RZPersonDataSource

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
                                                                withPredicate:nil
                                                              sortDescriptors:@[ RZVKeySort(NSStringFromSelector(@selector(sortIndex)), NO) ]];
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

- (void)setPredicate:(NSPredicate *)predicate
{
    _predicate = predicate;
    [self updateFetch];
}

#pragma mark - Private

- (void)updateFetch
{
    [self.fetchedResultsController.fetchRequest setPredicate:self.predicate];
    
    NSError *fetchError = nil;
    if ( ![self.fetchedResultsController performFetch:&fetchError] ) {
        NSLog(@"Error fetching people with predicate: %@", self.predicate);
    }
}

- (void)populateCell:(RZPersonTableViewCell *)cell forPerson:(RZPerson *)person
{
    if ( cell == nil || person == nil ) {
        return;
    }
    
    cell.nameLabel.text = person.name;
    cell.bioLabel.text = person.bio;
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
    RZPersonTableViewCell *personCell = [tableView dequeueReusableCellWithIdentifier:kRZPeronDataSourcePersonCellIdentifier];
    [self populateCell:personCell forPerson:person];
    return personCell;
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
                          withRowAnimation:UITableViewRowAnimationFade];
            break;
            
        case NSFetchedResultsChangeDelete:
            [self.tableView deleteSections:[NSIndexSet indexSetWithIndex:sectionIndex]
                          withRowAnimation:UITableViewRowAnimationFade];
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
                                  withRowAnimation:UITableViewRowAnimationFade];
            break;
            
        case NSFetchedResultsChangeDelete:
            [self.tableView deleteRowsAtIndexPaths:@[indexPath]
                                  withRowAnimation:UITableViewRowAnimationFade];
            break;
            
        case NSFetchedResultsChangeUpdate: {
            RZPersonTableViewCell *cell = (RZPersonTableViewCell *)[self.tableView cellForRowAtIndexPath:indexPath];
            [self populateCell:cell forPerson:[self personAtIndexPath:indexPath]];
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
