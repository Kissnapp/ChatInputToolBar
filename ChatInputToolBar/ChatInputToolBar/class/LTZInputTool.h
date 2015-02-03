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

@property (assign, nonatomic) BOOL                      isKeyboardShowing;
@property (assign, nonatomic) BOOL                      isRecordViewShowing;
@property (assign, nonatomic) BOOL                      isExpressionViewShowing;
@property (assign, nonatomic) BOOL                      isMoreViewShowing;
@property (weak, nonatomic) id<LTZInputToolDelegate>    delegate;

+ (CGFloat)LTZInputToolDefaultHeight;

- (instancetype)initWithFrame:(CGRect)frame inView:(UIView *)inView delegate:(id<LTZInputToolDelegate>)delegate;

@end

@protocol LTZInputToolDelegate <NSObject>

@optional

- (void)ltzInputTool:(LTZInputTool *)ltzInputTool didSentTextContent:content;
/*
- (void)ltzInputTool:(LTZInputTool *)ltzInputTool didPrepareToRecord
{
    self.isMoreViewShowing = NO;
    self.isExpressionViewShowing = NO;
    self.isRecordViewShowing = YES;
    
    
}

- (void)prepareToInputText
{
    self.isMoreViewShowing = NO;
    self.isExpressionViewShowing = NO;
    self.isRecordViewShowing = NO;
    
    if (![self isFirstResponder]) {
        [self becomeFirstResponder];
    }
}

- (void)prepareToInputExpression
{
    self.isMoreViewShowing = NO;
    self.isExpressionViewShowing = YES;
    self.isRecordViewShowing = NO;
    
    if ([self isFirstResponder]) {
        [self resignFirstResponder];
    }
    
    [self showMoreViewOrExpressionView];
    
}

- (void)prepareToInputMoreInfo
{
    self.isMoreViewShowing = YES;
    self.isExpressionViewShowing = NO;
    self.isRecordViewShowing = NO;
    
    if ([self isFirstResponder]) {
        [self resignFirstResponder];
    }
    
    [self showMoreViewOrExpressionView];
}

- (void)stopToInput
{
    if ([_inputTextView isFirstResponder]) {
        self.isMoreViewShowing = NO;
        self.isExpressionViewShowing = NO;
        self.isRecordViewShowing = NO;
        
    }else{
        
    }
}

- (void)showMoreViewOrExpressionView
{
    // begin animation action
    [UIView beginAnimations:nil context:NULL];
    [UIView setAnimationDuration:LTZInputToolBarDefaultAnimationDuration];
    [UIView setAnimationCurve:(UIViewAnimationCurve)LTZInputToolBarDefaultAnimationCurve];
    
    
    
    //    // for ipad modal form presentations
    //    CGFloat messageViewFrameBottom = self.contextView.frame.size.height - self.frame.size.height;
    //
    //    if(inputViewFrameY > messageViewFrameBottom) inputViewFrameY = messageViewFrameBottom;
    
    self.frame = self.defaultFrame;
    
    // end animation action
    [UIView commitAnimations];
}

- (void)hideMoreViewOrExpressionView
*/

@end
