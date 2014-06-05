//
//  RZWaiter.h
//  Costco
//
//  Created by Nick Bonatsakis on 06/19/2013.
//  Copyright (c) 2014 RaizLabs. All rights reserved.
//

#import <Foundation/Foundation.h>

typedef BOOL(^RZWaiterPollBlock)(void);
typedef void(^RZWaiterTimeout)(void);


@interface RZWaiter : NSObject

+ (RZWaiter*)waiter;

- (void)waitWithTimeout:(NSTimeInterval)timeout
           pollInterval:(NSTimeInterval)delay
         checkCondition:(RZWaiterPollBlock)conditionBlock
              onTimeout:(RZWaiterTimeout)timeoutBlock;

@end
