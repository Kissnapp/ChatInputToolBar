//
//  IBInputTool.h
//  ChatInputToolBar
//
//  Created by Peter Lee on 15/2/3.
//  Copyright (c) 2015年 Peter Lee. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "IBGrowingTextView.h"

@protocol IBInputToolPublicDelegate;
@protocol IBInputToolPrivateDelegate;
@interface IBInputTool : UIImageView<IBGrowingTextViewDelegate>

@property (strong, nonatomic) IBGrowingTextView        *inputTextView;

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
@property (weak, nonatomic) id<IBInputToolPrivateDelegate>    privateDelegate;
@property (weak, nonatomic) id<IBInputToolPublicDelegate>    publicDelegate;

+ (CGFloat)IBInputToolDefaultHeight;

- (instancetype)initWithFrame:(CGRect)frame
                       inView:(UIView *)inView
                   scrollView:(UIScrollView *)scrollView
             privatedDelegate:(id<IBInputToolPrivateDelegate>)privateDelegate
               publicDelegate:(id<IBInputToolPublicDelegate>) publicDelegate;

- (BOOL)resignFirstResponder;
- (BOOL)isFirstResponder;
- (BOOL)becomeFirstResponder;

- (CGRect)currentFrameWhenRecord;
- (CGRect)currentFrameWhenInput;

@end

@protocol IBInputToolPrivateDelegate <NSObject>

@optional

- (void)ltzInputToolDidShowRecordView:(IBInputTool *)ltzInputTool;
- (void)ltzInputToolDidShowExpressionView:(IBInputTool *)ltzInputTool;
- (void)ltzInputToolDidShowMoreInfoView:(IBInputTool *)ltzInputTool;
- (void)ltzInputToolDidShowInputTextView:(IBInputTool *)ltzInputTool;

- (void)ltzInputToolWillBecomeFirstResponder:(IBInputTool *)ltzInputTool;
- (void)ltzInputToolWillResignFirstResponder:(IBInputTool *)ltzInputTool;

@end


@protocol IBInputToolPublicDelegate <NSObject>

@optional
/**
 *  Called when send a text
 *
 *  @param ltzInputTool The input tool
 */
- (void)ltzInputTool:(IBInputTool *)ltzInputTool didSentTextContent:content;
/**
 *  when we press the record button
 */
- (void)didStartRecordingWithLTZInputTool:(IBInputTool *)ltzInputTool;
/**
 *  When we cancel a recording action
 */
- (void)didCancelRecordingWithLTZInputTool:(IBInputTool *)ltzInputTool;
/**
 *  When we finish a recording action
 */
- (void)didFinishRecordingWithLTZInputTool:(IBInputTool *)ltzInputTool;
/**
 *  This method called when we our finger drag outside the inputTool view during recording action
 */
- (void)didDragOutsideWhenRecordingWithLTZInputTool:(IBInputTool *)ltzInputTool;
/**
 *  This method called when we our finger drag inside the inputTool again view during recording action
 */
- (void)didDragInsideWhenRecordingWithLTZInputTool:(IBInputTool *)ltzInputTool;

@end
