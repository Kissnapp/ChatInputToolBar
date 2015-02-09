//
//  UIColor(extension).h
//  ChatInputToolBar
//
//  Created by Peter Lee on 15/2/9.
//  Copyright (c) 2015年 Peter Lee. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface UIColor (Extension)

+ (UIColor *) colorWithHex:(NSInteger)hexValue alpha:(CGFloat)alphaValue;
+ (UIColor *) colorWithHex:(NSInteger)hexValue;
+ (UIColor *)colorWithHexString:(NSString *)hexString;
+ (NSString *) hexFromUIColor:(UIColor*) color;

@end
