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
}

- (void)prepareForReuse
{
    [super prepareForReuse];
    [self clearLabels];
}

- (void)clearLabels
{
    self.nameLabel.text = nil;
    self.bioLabel.text = nil;
}

@end
