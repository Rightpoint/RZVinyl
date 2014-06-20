//
//  RZAppStylesheet.m
//  RZVinylDemo
//
//  Created by Nick Donaldson on 6/20/14.
//  Copyright (c) 2014 Raizlabs. All rights reserved.
//

#import "RZAppStylesheet.h"

@implementation RZAppStylesheet

+ (void)load
{
    NSDictionary *navbarTitleAttributes = @{
        NSFontAttributeName : [self boldFontWithSize:20]
    };
    [[UINavigationBar appearance] setTitleTextAttributes:navbarTitleAttributes];
}

+ (UIFont *)defaultFontWithSize:(CGFloat)size
{
    return [UIFont fontWithName:@"AvenirNext-Medium" size:size];
}

+ (UIFont *)boldFontWithSize:(CGFloat)size
{
    return [UIFont fontWithName:@"AvenirNext-Bold" size:size];
}

+ (UIFont *)lightFontWithSize:(CGFloat)size
{
    return [UIFont fontWithName:@"AvenirNext-UltraLight" size:size];
}

@end
