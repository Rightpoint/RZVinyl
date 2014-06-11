//
//  RZVinylRelationshipInfo.m
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

#import "RZVinylRelationshipInfo.h"

@interface RZVinylRelationshipInfo ()

@property (nonatomic, readwrite, copy)   NSString *sourcePropertyName;
@property (nonatomic, readwrite, copy)   NSString *sourceEntityName;
@property (nonatomic, readwrite, assign) Class    sourceClass;
@property (nonatomic, readwrite, copy)   NSString *destinationPropertyName;
@property (nonatomic, readwrite, copy)   NSString *destinationEntityName;
@property (nonatomic, readwrite, assign) Class    destinationClass;
@property (nonatomic, readwrite, assign) BOOL     isToMany;

@end

@implementation RZVinylRelationshipInfo

+ (RZVinylRelationshipInfo *)relationshipInfoFromDescription:(NSRelationshipDescription *)description
{
    RZVinylRelationshipInfo *info = [[RZVinylRelationshipInfo alloc] init];
    info.sourcePropertyName         = description.name;
    info.sourceEntityName           = description.entity.name;
    info.sourceClass                = NSClassFromString(description.entity.managedObjectClassName);
    info.destinationPropertyName    = description.inverseRelationship.name;
    info.destinationEntityName      = description.destinationEntity.name;
    info.destinationClass           = NSClassFromString(description.destinationEntity.managedObjectClassName);
    info.isToMany                   = description.isToMany;
    return info;
}


@end