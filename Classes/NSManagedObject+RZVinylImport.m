//
//  NSManagedObject+RZVinylImport.m
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


#import "NSManagedObject+RZVinylImport.h"
#import "NSManagedObject+RZVinylRecord.h"
#import "NSManagedObject+RZVinylSubclass.h"
#import "NSManagedObject+RZVinylRecord_private.h"
#import "RZVinylDefines.h"
#import <objc/runtime.h>

@implementation NSManagedObject (RZVinylImport)

+ (instancetype)rzv_objectFromDictionary:(NSDictionary *)dict inContext:(NSManagedObjectContext *)context
{
    // !!!: Performing this atomically so calls to the normal RZAutoImport methods are still valid.
    //      Otherwise, calls to those methods would risk resource contention.
    __block id object = nil;
    [self rzv_performBlockAtomically:^{
        [self rzv_pushImportContext:context];
        object = [self rzai_objectFromDictionary:dict];
        [self rzv_popImportContext];
    }];
    return object;
}

+ (NSArray *)rzv_objectsFromArray:(NSArray *)array inContext:(NSManagedObjectContext *)context
{
    // !!!: Performing this atomically so calls to the normal RZAutoImport methods are still valid.
    //      Otherwise, calls to those methods would risk resource contention.
    __block NSArray *objects = nil;
    [self rzv_performBlockAtomically:^{
        [self rzv_pushImportContext:context];
        objects = [self rzai_objectsFromArray:array];
        [self rzv_popImportContext];
    }];
    return objects;
}

#pragma mark - RZAutoImportable

+ (id)rzai_existingObjectForDict:(NSDictionary *)dict
{
    __block id object = nil;
    
    [self rzv_performBlockAtomically:^{
        
        NSManagedObjectContext *context = [self rzv_currentImportContext];
        if ( context == nil ){
            return;
        }
        
        NSString *externalPrimaryKey = [self rzv_externalPrimaryKey] ?: [self rzv_primaryKey];
        id primaryValue = externalPrimaryKey ? [dict objectForKey:externalPrimaryKey] : nil;
        if ( primaryValue != nil ) {
            object = [self rzv_objectWithPrimaryKeyValue:primaryValue createNew:YES inContext:context];
        }
        else {
            RZVLogInfo(@"Class %@ for entity %@ does not provide a primary key and cannot be uniqued. Creating new instance...", NSStringFromClass(self), [self rzv_entityName] );
            object = [self rzv_newObjectInContext:context];
        }
    
    }];
    return object;
}

#pragma mark - Private

+ (NSMutableArray *)s_rzv_importContextStack
{
    static NSMutableArray *s_importContextStack = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        s_importContextStack = [NSMutableArray array];
    });
    return s_importContextStack;
}

+ (void)rzv_performBlockAtomically:(void(^)())block
{
    // !!!: Would use a serial queue but need reentrancy here.
    static NSRecursiveLock *s_contextLock = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        s_contextLock = [[NSRecursiveLock alloc] init];
    });
    
    if ( block ) {
        [s_contextLock lock];
        block();
        [s_contextLock unlock];
    }
}

+ (NSManagedObjectContext *)rzv_currentImportContext
{
    __block NSManagedObjectContext *currentContext = nil;
    [self rzv_performBlockAtomically:^{
        currentContext = [[self s_rzv_importContextStack] lastObject];
        if ( currentContext == nil ) {
            currentContext = [[self rzv_validCoreDataStack] mainManagedObjectContext];
            [self rzv_pushImportContext:currentContext];
        }
    }];
    return currentContext;
}

+ (void)rzv_pushImportContext:(NSManagedObjectContext *)context
{
    if ( context != nil ) {
        [self rzv_performBlockAtomically:^{
            [[self s_rzv_importContextStack] addObject:context];
        }];
    }
}

+ (void)rzv_popImportContext
{
    [self rzv_performBlockAtomically:^{
        if ( [[self s_rzv_importContextStack] count] > 0 ) {
            [[self s_rzv_importContextStack] removeLastObject];
        }
    }];
}

@end
