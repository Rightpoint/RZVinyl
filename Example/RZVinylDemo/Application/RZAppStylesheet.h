//
//  RZAppStylesheet.h
//  RZVinylDemo
//
//  Created by Nick Donaldson on 6/20/14.
//  Copyright (c) 2014 Raizlabs. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface RZAppStylesheet : NSObject

+ (UIFont *)defaultFontWithSize:(CGFloat)size;
+ (UIFont *)boldFontWithSize:(CGFloat)size;
+ (UIFont *)lightFontWithSize:(CGFloat)size;

@end
