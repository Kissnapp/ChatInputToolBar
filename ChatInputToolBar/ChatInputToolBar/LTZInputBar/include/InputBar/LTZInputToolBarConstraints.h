//
//  LTZInputToolBarConstraints.h
//  ChatInputToolBar
//
//  Created by Peter Lee on 15/2/3.
//  Copyright (c) 2015年 Peter Lee. All rights reserved.
//

@import UIKit;

#ifndef LTZInputBarImagePathWithName

#define LTZInputBarImagePathWithName(name) \
[@"LTZInputBar.bundle/images" stringByAppendingPathComponent:(name)]

#endif

#ifndef LTZInputBarLocalizedString

#define LTZInputBarLocalizedString(key) \
    NSLocalizedStringFromTableInBundle(key, @"LTZInputBar", [NSBundle bundleWithPath:[[[NSBundle mainBundle] resourcePath] stringByAppendingPathComponent:@"LTZInputBar.bundle/LTZInputBarLocalString"]], nil)

#endif

UIKIT_EXTERN CGFloat const LTZInputToolDefaultHeight;
UIKIT_EXTERN CGFloat const LTZInputToolBarDefaultHeight;
UIKIT_EXTERN CGFloat const LTZInputToolBarDefaultKetboardHeight;

UIKIT_EXTERN CGFloat const LTZMoreInputViewItemDefaultWidth;
UIKIT_EXTERN CGFloat const LTZMoreInputViewItemDefaultHeight;

FOUNDATION_EXTERN NSTimeInterval const LTZInputToolBarDefaultAnimationDuration;
FOUNDATION_EXTERN NSInteger const LTZInputToolBarDefaultAnimationCurve;

FOUNDATION_EXTERN NSInteger const LTZInputToolBarDefaultMutableViewRows;
FOUNDATION_EXTERN NSInteger const LTZInputToolBarDefaultMutableViewColumns;
