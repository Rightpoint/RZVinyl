//
//  NSFetchedResultsController+RZVinylRecord.h
//  RZVinyl
//
//  Created by Nick Donaldson on 6/5/14.
//
//  Copyright 2014 Raizlabs and other contributors
//  http://raizlabs.com/
//
//  Permission is hereby granted, free of charge, to any person obtaining
//  a copy of this software and associated documentation files (the
//                                                                "Software"), to deal in the Software without restriction, including
//  without limitation the rights to use, copy, modify, merge, publish,
//  distribute, sublicense, and/or sell copies of the Software, and to
//  permit persons to whom the Software is furnished to do so, subject to
//  the following conditions:
//
//  The above copyright notice and this permission notice shall be
//  included in all copies or substantial portions of the Software.
//
//  THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND,
//  EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF
//  MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND
//  NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT HOLDERS BE
//  LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER IN AN ACTION
//  OF CONTRACT, TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN CONNECTION
//  WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE.


@import CoreData;
#import "RZVCompatibility.h"

@interface NSFetchedResultsController (RZVinylRecord)


/**
 *  Returns a configured fetched results controller based on the provided arguments.
 *
 *  @param entityName      The name of the entity to fetch. Must not be nil.
 *  @param context         The context in which to fetch. Must not be nil.
 *  @param predicate       An optional predicate for the fetch.
 *  @param sortDescriptors An optional array of sort descriptors to sort the results.
 *
 *  @return A configured fetched results controller.
 */
+ (RZNullable instancetype)rzv_forEntity:(NSString* RZCNonnull)entityName
                               inContext:(NSManagedObjectContext* RZCNonnull)context
                                predicate:(NSPredicate* RZCNullable)predicate
                                    sort:(RZGeneric(NSArray, NSSortDescriptor *) * RZCNullable)sortDescriptors;

/**
 *  Returns a configured fetched results controller based on the provided arguments.
 *
 *  @param entityName      The name of the entity to fetch. Must not be nil.
 *  @param context         The context in which to fetch. Must not be nil.
 *  @param predicate       An optional predicate for the fetch.
 *  @param sortDescriptors An optional array of sort descriptors to sort the results.
 *  @param sectionNameKeyPath An optional keypath by which to group the results into sections.
 *  @param cacheName       An optional cache name for the controller. Pass nil to disable caching.
 *
 *  @return A configured fetched results controller.
 */
+ (RZNullable instancetype)rzv_forEntity:(NSString* RZCNonnull)entityName
                               inContext:(NSManagedObjectContext* RZCNonnull)context
                                   predicate:(NSPredicate* RZCNullable)predicate
                                    sort:(RZGeneric(NSArray, NSSortDescriptor *) * RZCNullable)sortDescriptors
                      sectionNameKeyPath:(NSString* RZCNullable)sectionNameKeyPath
                               cacheName:(NSString* RZCNullable)cacheName;

@end
