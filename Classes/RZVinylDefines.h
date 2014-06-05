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

#define RZVParameterAssert(param) \
    ({ NSParameterAssert(param); (param != nil); })

#define RZVAssert(cond, msg, ...) \
    ({ NSAssert(cond, msg, ##__VA_ARGS__); cond; })
//
//  Logging
//

#define RZVLogInfo(msg, ...) \
    NSLog((@"[RZDataStack]: INFO -- " msg), ##__VA_ARGS__);

#define RZVLogError(msg, ...) \
    NSLog((@"[RZDataStack]: ERROR -- " msg), ##__VA_ARGS__);
