//
//  RZPersonFiltersViewController.h
//  RZVinylDemo
//
//  Created by Nick Donaldson on 6/23/14.
//  Copyright (c) 2014 Raizlabs. All rights reserved.
//

@class RZPersonFiltersViewController;

@protocol  RZPersonFiltersViewControllerDelegate <NSObject>

- (void)filtersViewController:(RZPersonFiltersViewController *)viewController
       dismissedWithPredicate:(NSPredicate *)filterPredicate
                  filterCount:(NSUInteger)filterCount;

@end

@interface RZPersonFiltersViewController : UIViewController

@property (nonatomic, weak) id<RZPersonFiltersViewControllerDelegate> delegate;

@end
