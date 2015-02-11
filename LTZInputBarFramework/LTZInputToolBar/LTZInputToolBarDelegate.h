//
//  LTZInputToolBarDelegate.h
//  ChatInputToolBar
//
//  Created by Peter Lee on 15/2/2.
//  Copyright (c) 2015年 Peter Lee. All rights reserved.
//

#import <UIKit/UIKit.h>

@class LTZInputTool;
@class LTZInputToolBar;
@class LTZMoreInputView;

@protocol LTZInputToolPublicDelegate;
@protocol LTZMoreInputViewPublicDelegate;

@protocol LTZInputToolBarDelegate <NSObject, LTZInputToolPublicDelegate, LTZMoreInputViewPublicDelegate>

@optional

@end

@protocol LTZMoreInputViewDataSource;
@protocol LTZInputToolBarDataSource <NSObject, LTZMoreInputViewDataSource>

@required

@end
