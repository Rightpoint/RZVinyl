//
//  NSFetchedResultsController+RZVinylRecord.m
//  RZVinylDemo
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


#import "NSFetchedResultsController+RZVinylRecord.h"
#import "RZVinylDefines.h"
#import "NSFetchRequest+RZVinylRecord.h"

@implementation NSFetchedResultsController (RZVinylRecord)

+ (instancetype)rzv_forEntity:(NSString *)entityName
                    inContext:(NSManagedObjectContext *)context
                withPredicate:(NSPredicate *)predicate
              sortDescriptors:(NSArray *)sortDescriptors
{
    return [self rzv_forEntity:entityName
                     inContext:context
                 withPredicate:predicate
               sortDescriptors:sortDescriptors
            sectionNameKeyPath:nil
                     cacheName:nil];
}

+ (instancetype)rzv_forEntity:(NSString *)entityName
                    inContext:(NSManagedObjectContext *)context
                withPredicate:(NSPredicate *)predicate
              sortDescriptors:(NSArray *)sortDescriptors
           sectionNameKeyPath:(NSString *)sectionNameKeyPath
                    cacheName:(NSString *)cacheName
{
    if ( !RZVParameterAssert(entityName) || !RZVParameterAssert(context) ) {
        return nil;
    }
    
    NSFetchRequest *fetch = [NSFetchRequest rzv_forEntity:entityName
                                                inContext:context
                                            withPredicate:predicate
                                          sortDescriptors:sortDescriptors];
    
    return [[NSFetchedResultsController alloc] initWithFetchRequest:fetch
                                               managedObjectContext:context
                                                 sectionNameKeyPath:sectionNameKeyPath
                                                          cacheName:cacheName];
}

@end
