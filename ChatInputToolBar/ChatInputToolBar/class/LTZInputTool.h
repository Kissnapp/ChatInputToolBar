//
//  LTZInputTool.h
//  ChatInputToolBar
//
//  Created by Peter Lee on 15/2/3.
//  Copyright (c) 2015年 Peter Lee. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "LTZGrowingTextView.h"

@protocol LTZInputToolDelegate;

@interface LTZInputTool : UIImageView<LTZGrowingTextViewDelegate>

@property (strong, nonatomic) LTZGrowingTextView        *inputTextView;

@property (strong, nonatomic) UIButton                  *voiceButton;
@property (strong, nonatomic) UIButton                  *expressionButton;
@property (strong, nonatomic) UIButton                  *moreButton;
@property (strong, nonatomic) UIButton                  *recordButton;

@property (strong, nonatomic, readonly) UIView          *inView;
@property (strong, nonatomic, readonly) UIScrollView    *scrollView;

@property (assign, nonatomic) BOOL                      isKeyboardShowing;
@property (assign, nonatomic) BOOL                      isRecordViewShowing;
@property (assign, nonatomic) BOOL                      isExpressionViewShowing;
@property (assign, nonatomic) BOOL                      isMoreViewShowing;
@property (weak, nonatomic) id<LTZInputToolDelegate>    delegate;

+ (CGFloat)LTZInputToolDefaultHeight;

- (instancetype)initWithFrame:(CGRect)frame
                       inView:(UIView *)inView
                   scrollView:(UIScrollView *)scrollView
                     delegate:(id<LTZInputToolDelegate>)delegate;

- (BOOL)resignFirstResponder;
- (BOOL)isFirstResponder;
- (BOOL)becomeFirstResponder;

- (CGRect)currentFrameWhenRecord;
- (CGRect)currentFrameWhenInput;

@end

@protocol LTZInputToolDelegate <NSObject>

@optional

- (void)ltzInputTool:(LTZInputTool *)ltzInputTool didSentTextContent:content;

- (void)ltzInputToolDidShowRecordView:(LTZInputTool *)ltzInputTool;
- (void)ltzInputToolDidShowExpressionView:(LTZInputTool *)ltzInputTool;
- (void)ltzInputToolDidShowMoreInfoView:(LTZInputTool *)ltzInputTool;
- (void)ltzInputToolDidShowInputTextView:(LTZInputTool *)ltzInputTool;

- (void)ltzInputToolWillBecomeFirstResponder:(LTZInputTool *)ltzInputTool;
- (void)ltzInputToolWillResignFirstResponder:(LTZInputTool *)ltzInputTool;

@end
