//
//  RZPersonLoader.h
//  RZVinylDemo
//
//  Created by Nick Donaldson on 6/20/14.
//  Copyright (c) 2014 Raizlabs. All rights reserved.
//

#import <Foundation/Foundation.h>

/**
 *  Imports person objects asynchronously from a static JSON file in batches.
 */
@interface RZPersonLoader : NSObject

- (void)loadPeopleWithBatchSize:(NSUInteger)batchSize
                     completion:(void(^)(NSError *err))completion;

@end
