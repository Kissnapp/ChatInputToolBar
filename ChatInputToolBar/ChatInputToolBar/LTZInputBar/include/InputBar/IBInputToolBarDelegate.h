//
//  LTZInputToolBarDelegate.h
//  ChatInputToolBar
//
//  Created by Peter Lee on 15/2/2.
//  Copyright (c) 2015年 Peter Lee. All rights reserved.
//

#import <UIKit/UIKit.h>

@class IBInputTool;
@class IBInputToolBar;
@class IBMoreInputView;

@protocol IBInputToolPublicDelegate;
@protocol IBMoreInputViewPublicDelegate;

@protocol IBInputToolBarDelegate <NSObject, IBInputToolPublicDelegate, IBMoreInputViewPublicDelegate>

@optional

@end

@protocol IBMoreInputViewDataSource;
@protocol IBInputToolBarDataSource <NSObject, IBMoreInputViewDataSource>

@required

@end
