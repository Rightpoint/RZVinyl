//
//  NSManagedObject+RZImportableSubclass.m
//  RZVinyl
//
//  Created by Nick Donaldson on 6/6/14.
//
//  Copyright 2014 Raizlabs and other contributors
//  http://raizlabs.com/
//
//  Permission is hereby granted, free of charge, to any person obtaining
//  a copy of this software and associated documentation files (the
//  "Software"), to deal in the Software without restriction, including
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

#import "NSManagedObject+RZVinylUtils.h"
#import "NSManagedObjectContext+RZImport.h"
#import "RZVinylDefines.h"

@implementation NSManagedObject (RZImportableSubclass)

+ (NSString *)rzv_externalPrimaryKey
{
    return nil;
}

+ (BOOL)rzv_shouldAlwaysCreateNewObjectOnImport
{
    return NO;
}

- (void)rzi_setNilForPropertyNamed:(NSString *)propName;
{
    NSManagedObjectContext *context = [NSManagedObjectContext rzi_currentThreadImportContext];
    NSManagedObjectModel *model = [[context persistentStoreCoordinator] managedObjectModel];
    NSEntityDescription *entity = [[model entitiesByName] objectForKey:[self.class rzv_entityName]];
    NSPropertyDescription *property = entity.propertiesByName[propName];
    if ([property isKindOfClass:[NSAttributeDescription class]]) {
        NSAttributeDescription *attributedProperty = (NSAttributeDescription *)property;
        [self setValue:attributedProperty.defaultValue forKey:propName];
    }
}

@end
