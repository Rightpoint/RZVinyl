//
//  NSManagedObjectContext+RZVinylSave.h
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

@import CoreData;

typedef void (^RZVinylSaveCompletion)(NSError *error);

/**
 *  Extensions to NSManagedObjectContext to support full-stack saving.
 */
@interface NSManagedObjectContext (RZVinylSave)

/**
 *  Asynchronously save this context and all parent contexts all the way up to the persistent store.
 *  This method returns immediately.
 *
 *  @param completion An optional completion block that will be called on the main thread when the saves are all finished,
 *                    or as soon as there is a saving error.
 *
 *  @note This is safe to call from any thread.
 *
 *  @warning None of the contexts in the parent context hierarchy can have confinement concurrency type.
 *           If you try to call this method with a confined context in the hierarchy, an exception will be thrown.
 */
- (void)rzv_saveToStoreWithCompletion:(RZVinylSaveCompletion)completion;

/**
 *  Synchronously save this context and all parent contexts all the way up to the persistent store.
 *
 *  @param error Optional NSError pointer that will be filled in if there is an error.
 *
 *  @note This is safe to call from any thread.
 *
 *  @warning None of the contexts in the parent context hierarchy can have confinement concurrency type.
 *           If you try to call this method with a confined context in the hierarchy, an exception will be thrown.
 *
 *  @return YES if the save succeeded, NO otherwise.
 */
- (BOOL)rzv_saveToStoreAndWait:(NSError *__autoreleasing *)error;

@end
