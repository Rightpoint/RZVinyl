//
//  RZPersonDetailView.m
//  RZVinylDemo
//
//  Created by Nick Donaldson on 6/23/14.
//  Copyright (c) 2014 Raizlabs. All rights reserved.
//

#import "RZPersonDetailView.h"
#import "RZPerson.h"
#import "RZAddress.h"
#import "RZInterest.h"

@interface RZPersonDetailView ()

@end

@implementation RZPersonDetailView

+ (instancetype)loadFromNib
{
    UINib *nib = [UINib nibWithNibName:NSStringFromClass(self) bundle:nil];
    return [[nib instantiateWithOwner:nil options:nil] objectAtIndex:0];
}

- (void)awakeFromNib
{
    [super awakeFromNib];
    [self clearLabels];
    [self configureStyling];
}

- (void)layoutSubviews
{
    [super layoutSubviews];
    self.interestsLabel.preferredMaxLayoutWidth = CGRectGetWidth(self.bioTextView.frame);
}

- (void)updateFromPerson:(RZPerson *)person
{
    self.nameTextField.text = person.name;
    self.addressLabel.text = [NSString stringWithFormat:@"%@\n%@, %@",
                              person.address.street,
                              person.address.city,
                              person.address.state];
    self.bioTextView.text = person.bio;
    
    NSMutableString *interestsString = [[NSMutableString alloc] initWithString:@"Interests:\n"];
    [[person.interests allObjects] enumerateObjectsUsingBlock:^(RZInterest *interest, NSUInteger idx, BOOL *stop) {
        [interestsString appendString:[interest.name capitalizedString]];
        if ( idx != person.interests.count - 1 ) {
            [interestsString appendString:@" - "];
        }
    }];
    self.interestsLabel.text = [NSString stringWithString:interestsString];
}

#pragma mark - Private

- (void)clearLabels
{
    self.nameTextField.text = nil;
    self.addressLabel.text = nil;
    self.bioTextView.text = nil;
    self.interestsLabel.text = nil;
}

- (void)configureStyling
{
    self.nameTextField.font     = [UIFont rz_defaultFontWithSize:24.0];
    self.addressLabel.font      = [UIFont rz_defaultFontWithSize:14.0];
    self.addressLabel.textColor = [UIColor rz_lightRed];
    self.bioTextView.font       = [UIFont rz_defaultFontWithSize:14.0];
    self.bioTextView.textColor  = [UIColor darkGrayColor];
    self.interestsLabel.font    = [UIFont rz_defaultFontWithSize:15.0];
}

@end
