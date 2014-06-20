//
//  RZPersonTableViewCell.m
//  RZVinylDemo
//
//  Created by Nick Donaldson on 6/20/14.
//  Copyright (c) 2014 Raizlabs. All rights reserved.
//

#import "RZPersonTableViewCell.h"

@implementation RZPersonTableViewCell

+ (CGFloat)nominalHeight
{
    return 96.0;
}

- (void)awakeFromNib
{
    [super awakeFromNib];
    [self clearLabels];
    
    self.nameLabel.font     = [RZAppStylesheet boldFontWithSize:18.0];
    self.bioLabel.font      = [RZAppStylesheet defaultFontWithSize:14.0];
    self.bioLabel.textColor = [UIColor lightGrayColor];
}

- (void)prepareForReuse
{
    [super prepareForReuse];
    [self clearLabels];
}

- (void)clearLabels
{
    self.nameLabel.text = nil;
    self.bioLabel.text  = nil;
}

@end
