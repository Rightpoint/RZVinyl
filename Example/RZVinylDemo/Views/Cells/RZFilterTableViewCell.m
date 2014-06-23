//
//  RZFilterTableViewCell.m
//  RZVinylDemo
//
//  Created by Nick Donaldson on 6/23/14.
//  Copyright (c) 2014 Raizlabs. All rights reserved.
//

#import "RZFilterTableViewCell.h"

@implementation RZFilterTableViewCell

- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier
{
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if ( self ) {
        self.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
    }
    return self;
}

- (void)updateForFilterName:(NSString *)filterName count:(NSUInteger)count
{
    NSMutableDictionary *attributes = [@{
        NSFontAttributeName : [UIFont rz_defaultFontWithSize:18.0]
    } mutableCopy];
    NSMutableAttributedString *cellText = [[NSMutableAttributedString alloc] initWithString:[filterName capitalizedString]
                                                                                 attributes:attributes];
    
    [attributes setValue:[UIFont rz_lightFontWithSize:16.0] forKey:NSFontAttributeName];
    [attributes setValue:[UIColor grayColor] forKey:NSForegroundColorAttributeName];
    
    [cellText appendAttributedString:[[NSAttributedString alloc] initWithString:[NSString stringWithFormat:@" (%lu %@)", (unsigned long)count, count == 1 ? @"person" : @"people"]
                                                                     attributes:attributes]];
    self.textLabel.attributedText = cellText;
}

@end
