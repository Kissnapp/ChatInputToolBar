//
//  LTZInputToolBarDelegate.h
//  ChatInputToolBar
//
//  Created by Peter Lee on 15/2/2.
//  Copyright (c) 2015年 Peter Lee. All rights reserved.
//

#import <UIKit/UIKit.h>

@class LTZInputToolBar;

@protocol LTZInputToolBarDelegate <NSObject>

@optional

- (void)ltzInputToolBar:(LTZInputToolBar *)ltzInputToolBar didSentTextContent:(NSString *)content;
//***************语音相关事件*****************//
//按下录音按钮开始录音
- (void)didStartRecordingVoiceAction:(UIView *)recordView;
//手指向上滑动取消录音
- (void)didCancelRecordingVoiceAction:(UIView *)recordView;
//松开手指完成录音
- (void)didFinishRecoingVoiceAction:(UIView *)recordView;
//当手指离开按钮的范围内时，主要为了通知外部的HUD
- (void)didDragOutsideAction:(UIView *)recordView;
//当手指再次进入按钮的范围内时，主要也是为了通知外部的HUD
- (void)didDragInsideAction:(UIView *)recordView;
//在普通状态和语音状态之间进行切换时，会触发这个回调函数  changedToRecord 是否改为发送语音状态
- (void)didStyleChangeToRecord:(BOOL)changedToRecord;

@end

