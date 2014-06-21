//
//  RZAppStylesheet.m
//  RZVinylDemo
//
//  Created by Nick Donaldson on 6/20/14.
//  Copyright (c) 2014 Raizlabs. All rights reserved.
//

#import "RZAppStylesheet.h"

@implementation UIColor (RZAppStylesheet)

+ (UIColor *)rz_lightRed
{
    return [UIColor colorWithRed:0.9255 green:0.3490 blue:0.3020 alpha:1.0000];
}

@end

@implementation UIFont (RZAppStylesheet)

+ (void)load
{
    NSDictionary *navbarTitleAttributes = @{
        NSFontAttributeName : [self rz_defaultFontWithSize:20]
    };
    [[UINavigationBar appearance] setTitleTextAttributes:navbarTitleAttributes];
}

+ (UIFont *)rz_defaultFontWithSize:(CGFloat)size
{
    return [UIFont fontWithName:@"AvenirNext-Medium" size:size];
}

+ (UIFont *)rz_boldFontWithSize:(CGFloat)size
{
    return [UIFont fontWithName:@"AvenirNext-Bold" size:size];
}

+ (UIFont *)rz_lightFontWithSize:(CGFloat)size
{
    return [UIFont fontWithName:@"AvenirNext-Regular" size:size];
}

@end

@implementation UITableView (RZAppStylesheet)

- (void)rz_addTableHeaderLabelWithText:(NSString *)text
{
    UILabel *headerLabel = [[UILabel alloc] init];
    headerLabel.textAlignment = NSTextAlignmentCenter;
    headerLabel.text = text;
    headerLabel.textColor = [UIColor whiteColor];
    headerLabel.font = [UIFont rz_defaultFontWithSize:18];
    headerLabel.backgroundColor = [UIColor rz_lightRed];
    [headerLabel sizeToFit];
    CGRect headerLabelFrame = headerLabel.frame;
    headerLabelFrame.size.height += 20.0;
    headerLabel.frame = headerLabelFrame;
    self.tableHeaderView = headerLabel;
}

@end