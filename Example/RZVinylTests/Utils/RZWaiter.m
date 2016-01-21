//
//  RZWaiter.h
//  RZVinylDemo
//
//  Created by Nick Bonatsakis on 06/19/2013.
//  Copyright (c) 2014 RaizLabs. All rights reserved.
//

#import "RZWaiter.h"

@implementation RZWaiter

- (id)init
{
    return nil;
}

+ (void) waitWithTimeout:(NSTimeInterval)timeout
                   pollInterval:(NSTimeInterval)delay
          checkCondition:(RZWaiterPollBlock)conditionBlock
               onTimeout:(RZWaiterTimeout)timeoutBlock
{
    int times = timeout / delay;
    for (int i=0; i<times; i++) {
        [[NSRunLoop mainRunLoop] runUntilDate:[NSDate dateWithTimeIntervalSinceNow:delay]];
        if (conditionBlock()) {
            return;
        }
    }
    
    if (timeoutBlock) {
        timeoutBlock();
    }
}

@end
