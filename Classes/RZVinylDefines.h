//
//  RZVinylDefines.h
//  RZVinylDemo
//
//  Created by Nick Donaldson on 6/5/14.
//  Copyright (c) 2014 Raizlabs. All rights reserved.
//

//
//  Assertion
//

#define RZVAssertReturn(cond, msg, ...) \
    NSAssert(cond, msg, ##__VA_ARGS__); \
    if ( !(cond) ) { \
        return; \
    }

#define RZVAssertReturnNO(cond, msg, ...) \
    NSAssert(cond, msg, ##__VA_ARGS__); \
    if ( !(cond) ) { \
        return NO; \
    }

//
//  Logging
//

#define RZVLogInfo(msg, ...) \
    NSLog((@"[RZDataStack]: INFO -- " msg), ##__VA_ARGS__);

#define RZVLogError(msg, ...) \
    NSLog((@"[RZDataStack]: ERROR -- " msg), ##__VA_ARGS__);
