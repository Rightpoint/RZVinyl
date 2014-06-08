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

@implementation NSManagedObject (RZVinylImport)

//!!!: Overridden to support default context
+ (instancetype)rzai_objectFromDictionary:(NSDictionary *)dict
{
    NSManagedObjectContext *context = [[self rzv_validCoreDataStack] mainManagedObjectContext];
    return [self rzai_objectFromDictionary:dict inContext:context];
}

//!!!: Overridden to support default context
+ (NSArray *)rzai_objectsFromArray:(NSArray *)array
{
    NSManagedObjectContext *context = [[self rzv_validCoreDataStack] mainManagedObjectContext];
    return [self rzai_objectsFromArray:array inContext:context];
}

+ (instancetype)rzai_objectFromDictionary:(NSDictionary *)dict inContext:(NSManagedObjectContext *)context
{
    if ( !RZVParameterAssert(context) ) {
        return nil;
    }
    //!!!: If there is a context in the current thread dictionary, then this is a nested call to this method.
    //     In that case, do not modify the thread dictionary.
    BOOL nestedCall = ([self rzv_currentThreadImportContext] != nil);
    if ( !nestedCall ){
        [self rzv_setCurrentThreadImportContext:context];
    }
    id object = [super rzai_objectFromDictionary:dict];
    if ( !nestedCall ) {
        [self rzv_setCurrentThreadImportContext:nil];
    }
    return object;

}

+ (NSArray *)rzai_objectsFromArray:(NSArray *)array inContext:(NSManagedObjectContext *)context
{
    if ( !RZVParameterAssert(context) ) {
        return nil;
    }
    //!!!: If there is a context in the current thread dictionary, then this is a nested call to this method.
    //     In that case, do not modify the thread dictionary.
    BOOL nestedCall = ([self rzv_currentThreadImportContext] != nil);
    if ( !nestedCall ){
        [self rzv_setCurrentThreadImportContext:context];
    }
    NSArray *objects = [super rzai_objectsFromArray:array];
    if ( !nestedCall ) {
        [self rzv_setCurrentThreadImportContext:nil];
    }
    return objects;
}

#pragma mark - RZAutoImportable

+ (id)rzai_existingObjectForDict:(NSDictionary *)dict
{
    NSManagedObjectContext *context = [self rzv_currentThreadImportContext];
    if ( context == nil ){
        RZVLogError(@"This thread does not have an associated managed object context at the moment.");
        return nil;
    }
    
    id object = nil;
    NSString *externalPrimaryKey = [self rzv_externalPrimaryKey] ?: [self rzv_primaryKey];
    id primaryValue = externalPrimaryKey ? [dict objectForKey:externalPrimaryKey] : nil;
    if ( primaryValue != nil ) {
        object = [self rzv_objectWithPrimaryKeyValue:primaryValue createNew:YES inContext:context];
    }
    else {
        RZVLogInfo(@"Class %@ for entity %@ does not provide a primary key and cannot be uniqued. Creating new instance...", NSStringFromClass(self), [self rzv_entityName] );
        object = [self rzv_newObjectInContext:context];
    }
    
    return object;
}

#pragma mark - Private

static NSString * const kRZVinylImportThreadContextKey = @"RZVinylImportThreadContext";

+ (NSManagedObjectContext *)rzv_currentThreadImportContext
{
    return [[[NSThread currentThread] threadDictionary] objectForKey:kRZVinylImportThreadContextKey];
}

+ (void)rzv_setCurrentThreadImportContext:(NSManagedObjectContext *)context
{
    if ( context ) {
        [[[NSThread currentThread] threadDictionary] setObject:context forKey:kRZVinylImportThreadContextKey];
    }
    else {
        [[[NSThread currentThread] threadDictionary] removeObjectForKey:kRZVinylImportThreadContextKey];
    }
}

@end
