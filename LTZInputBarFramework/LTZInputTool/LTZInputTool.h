//
//  LTZInputTool.h
//  ChatInputToolBar
//
//  Created by Peter Lee on 15/2/3.
//  Copyright (c) 2015年 Peter Lee. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "LTZGrowingTextView.h"

@protocol LTZInputToolPublicDelegate;
@protocol LTZInputToolPrivateDelegate;
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
@property (weak, nonatomic) id<LTZInputToolPrivateDelegate>    privateDelegate;
@property (weak, nonatomic) id<LTZInputToolPublicDelegate>    publicDelegate;

+ (CGFloat)LTZInputToolDefaultHeight;

- (instancetype)initWithFrame:(CGRect)frame
                       inView:(UIView *)inView
                   scrollView:(UIScrollView *)scrollView
             privatedDelegate:(id<LTZInputToolPrivateDelegate>)privateDelegate
               publicDelegate:(id<LTZInputToolPublicDelegate>) publicDelegate;

- (BOOL)resignFirstResponder;
- (BOOL)isFirstResponder;
- (BOOL)becomeFirstResponder;

- (CGRect)currentFrameWhenRecord;
- (CGRect)currentFrameWhenInput;

@end

@protocol LTZInputToolPrivateDelegate <NSObject>

@optional

- (void)ltzInputToolDidShowRecordView:(LTZInputTool *)ltzInputTool;
- (void)ltzInputToolDidShowExpressionView:(LTZInputTool *)ltzInputTool;
- (void)ltzInputToolDidShowMoreInfoView:(LTZInputTool *)ltzInputTool;
- (void)ltzInputToolDidShowInputTextView:(LTZInputTool *)ltzInputTool;

- (void)ltzInputToolWillBecomeFirstResponder:(LTZInputTool *)ltzInputTool;
- (void)ltzInputToolWillResignFirstResponder:(LTZInputTool *)ltzInputTool;

@end


@protocol LTZInputToolPublicDelegate <NSObject>

@optional
/**
 *  Called when send a text
 *
 *  @param ltzInputTool The input tool
 */
- (void)ltzInputTool:(LTZInputTool *)ltzInputTool didSentTextContent:content;
/**
 *  when we press the record button
 */
- (void)didStartRecordingWithLTZInputTool:(LTZInputTool *)ltzInputTool;
/**
 *  When we cancel a recording action
 */
- (void)didCancelRecordingWithLTZInputTool:(LTZInputTool *)ltzInputTool;
/**
 *  When we finish a recording action
 */
- (void)didFinishRecordingWithLTZInputTool:(LTZInputTool *)ltzInputTool;
/**
 *  This method called when we our finger drag outside the inputTool view during recording action
 */
- (void)didDragOutsideWhenRecordingWithLTZInputTool:(LTZInputTool *)ltzInputTool;
/**
 *  This method called when we our finger drag inside the inputTool again view during recording action
 */
- (void)didDragInsideWhenRecordingWithLTZInputTool:(LTZInputTool *)ltzInputTool;

@end
