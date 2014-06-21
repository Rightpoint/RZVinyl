//
//  RZPersonTableViewCell.m
//  RZVinylDemo
//
//  Created by Nick Donaldson on 6/20/14.
//  Copyright (c) 2014 Raizlabs. All rights reserved.
//

#import "RZPersonTableViewCell.h"

@interface RZPersonTableViewCellBackgroundView : UIView

@end

@implementation RZPersonTableViewCellBackgroundView

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if ( self ) {
        self.backgroundColor = [UIColor whiteColor];
    }
    return self;
}

- (void)drawRect:(CGRect)rect
{
    CGContextRef ctx = UIGraphicsGetCurrentContext();
    CGContextSetStrokeColorWithColor(ctx, [[UIColor colorWithWhite:0.9 alpha:1.0] CGColor]);
    CGContextSetLineWidth(ctx, 1.0);
    CGContextBeginPath(ctx);
    
    CGFloat lineY = CGRectGetHeight(self.bounds) - 1.0;
    CGContextMoveToPoint(ctx, 0, lineY);
    CGContextAddLineToPoint(ctx, CGRectGetWidth(self.bounds), lineY);
    CGContextStrokePath(ctx);
}

@end

@implementation RZPersonTableViewCell

+ (CGFloat)nominalHeight
{
    return 106.0;
}

- (void)awakeFromNib
{
    [super awakeFromNib];
    
    self.backgroundView = [[RZPersonTableViewCellBackgroundView alloc] initWithFrame:self.bounds];
    
    self.nameLabel.font     = [UIFont rz_boldFontWithSize:20.0];
    self.addressLabel.font  = [UIFont rz_defaultFontWithSize:14.0];
    self.addressLabel.textColor = [UIColor rz_lightRed];
    self.bioLabel.font      = [UIFont rz_lightFontWithSize:15.0];
    self.bioLabel.textColor = [UIColor grayColor];
    
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
    self.addressLabel.text = nil;
    self.bioLabel.text  = nil;
}

@end
