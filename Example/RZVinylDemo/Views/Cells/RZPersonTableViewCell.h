//
//  RZPersonTableViewCell.h
//  RZVinylDemo
//
//  Created by Nick Donaldson on 6/20/14.
//  Copyright (c) 2014 Raizlabs. All rights reserved.
//

@class RZPerson;

@interface RZPersonTableViewCell : UITableViewCell

+ (CGFloat)nominalHeight;

- (void)updateForPerson:(RZPerson *)person;

@end
