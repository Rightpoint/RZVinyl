//
//  RZPersonDetailView.h
//  RZVinylDemo
//
//  Created by Nick Donaldson on 6/23/14.
//  Copyright (c) 2014 Raizlabs. All rights reserved.
//

@class RZPerson;

@interface RZPersonDetailView : UIView

+ (instancetype)loadFromNib;

@property (weak, nonatomic) IBOutlet UILabel    *nameLabel;
@property (weak, nonatomic) IBOutlet UILabel    *addressLabel;
@property (weak, nonatomic) IBOutlet UITextView *bioTextView;
@property (weak, nonatomic) IBOutlet UILabel    *interestsLabel;
@property (weak, nonatomic) IBOutlet UIButton   *deletePersonButton;

- (void)updateFromPerson:(RZPerson *)person;

@end
