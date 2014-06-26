//
//  NSManagedObjectContext+RZVinylSave.m
//  RZVinyl
//
//  Created by Nick Donaldson on 6/25/14.
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
//

#import "NSManagedObjectContext+RZVinylSave.h"
#import "RZVinylDefines.h"

static void rzv_performSaveCompletionAsync(RZVinylSaveCompletion completion, NSError *error)
{
    if ( completion ) {
        dispatch_async(dispatch_get_main_queue(), ^{
            completion(error);
        });
    }
}

@implementation NSManagedObjectContext (RZVinylSave)

- (void)rzv_saveToStoreWithCompletion:(void (^)(NSError *))completion
{
    if ( !RZVAssert(self.concurrencyType != NSConfinementConcurrencyType, @"RZVinylSave methods cannot be used on contexts with thread confinement.") ) {
        return;
    }
    
    [self performBlock:^{
        if ( ![self hasChanges] ) {
            RZVLogInfo(@"Managed object context %@ does not have changes, not saving", self);
            rzv_performSaveCompletionAsync(completion, nil);
            return;
        }
        
        NSError *saveErr = nil;
        if ( ![self save:&saveErr] ) {
            RZVLogError(@"Error saving managed object context context %@: %@", self, saveErr);
            rzv_performSaveCompletionAsync(completion, saveErr);

        }
        else if ( self.parentContext != nil ) {
            [self.parentContext rzv_saveToStoreWithCompletion:completion];
        }
        else if ( completion ) {
            rzv_performSaveCompletionAsync(completion, nil);
        }
    }];
}

- (BOOL)rzv_saveToStoreAndWait:(NSError *__autoreleasing *)error
{
    __block NSError *saveErr = nil;
    __block BOOL hasChanges = NO;
    NSManagedObjectContext *currentContext = self;
    
    do {
        if ( !RZVAssert(currentContext.concurrencyType != NSConfinementConcurrencyType, @"RZVinylSave methods cannot be used on contexts with thread confinement.") ) {
            return NO;
        }

        [currentContext performBlockAndWait:^{
            hasChanges = [currentContext hasChanges];
            if ( !hasChanges ) {
                RZVLogInfo(@"Managed object context %@ does not have changes, not saving", self);
            }
            else if ( ![currentContext save:&saveErr] ) {
                RZVLogError(@"Error saving managed object context context %@: %@", self, saveErr);
            }
        }];
        
        currentContext = currentContext.parentContext;
        
    } while ( hasChanges && saveErr == nil && currentContext != nil );
    
    if ( error != nil && saveErr != nil ) {
        *error = saveErr;
    }
    
    return (saveErr == nil);
}

@end
