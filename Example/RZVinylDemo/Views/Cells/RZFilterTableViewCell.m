//
//  RZFilterTableViewCell.m
//  RZVinylDemo
//
//  Created by Nick Donaldson on 6/23/14.
//  Copyright (c) 2014 Raizlabs. All rights reserved.
//

#import "RZFilterTableViewCell.h"

@interface RZFilterTableViewCell ()

@property (nonatomic, weak) UILabel *checkLabel;

@end

@implementation RZFilterTableViewCell

- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier
{
    self = [super initWithStyle:UITableViewCellStyleValue1 reuseIdentifier:reuseIdentifier];
    if ( self ) {
        self.textLabel.font = [UIFont rz_defaultFontWithSize:18.0];
        self.detailTextLabel.font = [UIFont rz_lightFontWithSize:14.0];
        self.detailTextLabel.textColor = [UIColor rz_lightRed];
        self.selectionStyle = UITableViewCellSelectionStyleNone;
        
        UILabel *checkLabel = [[UILabel alloc] init];
        checkLabel.translatesAutoresizingMaskIntoConstraints = NO;
        checkLabel.font = [UIFont rz_boldFontWithSize:20];
        checkLabel.backgroundColor = [UIColor clearColor];
        checkLabel.textColor = [UIColor darkGrayColor];
        
        UIView *labelHostView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, 44, 44)];
        labelHostView.backgroundColor = [UIColor clearColor];
        labelHostView.userInteractionEnabled = NO;
        [labelHostView addSubview:checkLabel];
        
        [labelHostView addConstraint:[NSLayoutConstraint constraintWithItem:checkLabel
                                                                  attribute:NSLayoutAttributeCenterX
                                                                  relatedBy:NSLayoutRelationEqual
                                                                     toItem:labelHostView
                                                                  attribute:NSLayoutAttributeCenterX
                                                                 multiplier:1.0
                                                                   constant:0.0]];
        
        [labelHostView addConstraint:[NSLayoutConstraint constraintWithItem:checkLabel
                                                                  attribute:NSLayoutAttributeCenterY
                                                                  relatedBy:NSLayoutRelationEqual
                                                                     toItem:labelHostView
                                                                  attribute:NSLayoutAttributeCenterY
                                                                 multiplier:1.0
                                                                   constant:0.0]];
        
        self.checkLabel = checkLabel;
        self.accessoryView = labelHostView;
    }
    return self;
}

- (void)updateForFilterName:(NSString *)filterName count:(NSUInteger)count
{
    self.textLabel.text = [filterName capitalizedString];
    self.detailTextLabel.text = [NSString stringWithFormat:@" (%lu %@)", (unsigned long)count, count == 1 ? @"person" : @"people"];
}

- (void)setHighlighted:(BOOL)highlighted animated:(BOOL)animated
{
    [super setHighlighted:highlighted animated:animated];
    self.backgroundColor = highlighted ? [UIColor colorWithWhite:0.9 alpha:1.0] : [UIColor whiteColor];
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated
{
    [super setSelected:selected animated:animated];
    self.checkLabel.text = selected ? @"☑" : @"☐";
}

@end
