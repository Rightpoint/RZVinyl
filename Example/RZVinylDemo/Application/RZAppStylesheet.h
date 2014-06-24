//
//  RZAppStylesheet.h
//  RZVinylDemo
//
//  Created by Nick Donaldson on 6/20/14.
//  Copyright (c) 2014 Raizlabs. All rights reserved.
//

@interface UIColor (RZAppStylesheet)

+ (UIColor *)rz_lightRed;

@end

@interface UIFont (RZAppStylesheet)

+ (UIFont *)rz_defaultFontWithSize:(CGFloat)size;
+ (UIFont *)rz_boldFontWithSize:(CGFloat)size;
+ (UIFont *)rz_lightFontWithSize:(CGFloat)size;

@end

@interface UITableView (RZAppStylesheet)

- (void)rz_addTableHeaderLabelWithText:(NSString *)text;

@end