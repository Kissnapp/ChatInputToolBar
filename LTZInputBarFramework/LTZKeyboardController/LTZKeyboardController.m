//
//  LTZKeyboardController.m
//  LTZInputToolBar
//
//  Created by Peter Lee on 15/1/16.
//  Copyright (c) 2015年 Peter Lee. All rights reserved.

#import "LTZKeyboardController.h"

NSString * const LTZKeyboardControllerNotificationKeyboardDidChangeFrame = @"LTZKeyboardControllerNotificationKeyboardDidChangeFrame";
NSString * const LTZKeyboardControllerUserInfoKeyKeyboardDidChangeFrame = @"LTZControllerUserInfoKeyKeyboardDidChangeFrame";

static void * LTZKeyboardControllerKeyValueObservingContext = &LTZKeyboardControllerKeyValueObservingContext;

typedef void (^LTZAnimationCompletionBlock)(BOOL finished);


@interface UIDevice (LTZ)

/**
 *  @return Whether or not the current device is running a version of iOS before 8.0.
 */
+ (BOOL)ltz_isCurrentDeviceBeforeiOS8;

@end

@implementation UIDevice (LTZ)

+ (BOOL)ltz_isCurrentDeviceBeforeiOS8
{
    // iOS < 8.0
    return [[UIDevice currentDevice].systemVersion compare:@"8.0.0" options:NSNumericSearch] == NSOrderedAscending;
}

@end


@interface LTZKeyboardController () <UIGestureRecognizerDelegate>

@property (assign, nonatomic) BOOL ltz_isObserving;

@property (weak, nonatomic) UIView *keyboardView;

- (void)ltz_registerForNotifications;
- (void)ltz_unregisterForNotifications;

- (void)ltz_didReceiveKeyboardDidShowNotification:(NSNotification *)notification;
- (void)ltz_didReceiveKeyboardWillChangeFrameNotification:(NSNotification *)notification;
- (void)ltz_didReceiveKeyboardDidChangeFrameNotification:(NSNotification *)notification;
- (void)ltz_didReceiveKeyboardDidHideNotification:(NSNotification *)notification;
- (void)ltz_handleKeyboardNotification:(NSNotification *)notification completion:(LTZAnimationCompletionBlock)completion;

- (void)ltz_setKeyboardViewHidden:(BOOL)hidden;

- (void)ltz_notifyKeyboardFrameNotificationForFrame:(CGRect)frame;

- (void)ltz_removeKeyboardFrameObserver;

- (void)ltz_handlePanGestureRecognizer:(UIPanGestureRecognizer *)pan;

@end



@implementation LTZKeyboardController

#pragma mark - Initialization

- (instancetype)initWithTextView:(UITextView *)textView
                     contextView:(UIView *)contextView
            panGestureRecognizer:(UIPanGestureRecognizer *)panGestureRecognizer
                        delegate:(id<LTZKeyboardControllerDelegate>)delegate

{
    NSParameterAssert(textView != nil);
    NSParameterAssert(contextView != nil);
    NSParameterAssert(panGestureRecognizer != nil);
    
    self = [super init];
    if (self) {
        _textView = textView;
        _contextView = contextView;
        _panGestureRecognizer = panGestureRecognizer;
        _delegate = delegate;
        _ltz_isObserving = NO;
    }
    return self;
}

- (void)dealloc
{
    [self ltz_removeKeyboardFrameObserver];
    [self ltz_unregisterForNotifications];
    _textView = nil;
    _contextView = nil;
    _panGestureRecognizer = nil;
    _delegate = nil;
    _keyboardView = nil;
}

#pragma mark - Setters

- (void)setKeyboardView:(UIView *)keyboardView
{
    if (_keyboardView) {
        [self ltz_removeKeyboardFrameObserver];
    }
    
    _keyboardView = keyboardView;
    
    if (keyboardView && !_ltz_isObserving) {
        [_keyboardView addObserver:self
                        forKeyPath:NSStringFromSelector(@selector(frame))
                           options:(NSKeyValueObservingOptionOld | NSKeyValueObservingOptionNew)
                           context:LTZKeyboardControllerKeyValueObservingContext];
        
        _ltz_isObserving = YES;
    }
}

#pragma mark - Getters

- (BOOL)keyboardIsVisible
{
    return self.keyboardView != nil;
}

- (CGRect)currentKeyboardFrame
{
    if (!self.keyboardIsVisible) {
        return CGRectNull;
    }
    
    return self.keyboardView.frame;
}

#pragma mark - Keyboard controller

- (void)beginListeningForKeyboard
{
    if (self.textView.inputAccessoryView == nil) {
        self.textView.inputAccessoryView = [[UIView alloc] init];
    }
    
    [self ltz_registerForNotifications];
}

- (void)endListeningForKeyboard
{
    [self ltz_unregisterForNotifications];
    
    [self ltz_setKeyboardViewHidden:NO];
    self.keyboardView = nil;
}

#pragma mark - Notifications

- (void)ltz_registerForNotifications
{
    [self ltz_unregisterForNotifications];
    
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(ltz_didReceiveKeyboardDidShowNotification:)
                                                 name:UIKeyboardDidShowNotification
                                               object:nil];
    
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(ltz_didReceiveKeyboardWillChangeFrameNotification:)
                                                 name:UIKeyboardWillChangeFrameNotification
                                               object:nil];
    
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(ltz_didReceiveKeyboardDidChangeFrameNotification:)
                                                 name:UIKeyboardDidChangeFrameNotification
                                               object:nil];
    
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(ltz_didReceiveKeyboardDidHideNotification:)
                                                 name:UIKeyboardDidHideNotification
                                               object:nil];
}

- (void)ltz_unregisterForNotifications
{
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

- (void)ltz_didReceiveKeyboardDidShowNotification:(NSNotification *)notification
{
    self.keyboardView = self.textView.inputAccessoryView.superview;
    [self ltz_setKeyboardViewHidden:NO];
    
    [self ltz_handleKeyboardNotification:notification completion:^(BOOL finished) {
        [self.panGestureRecognizer addTarget:self action:@selector(ltz_handlePanGestureRecognizer:)];
    }];
}

- (void)ltz_didReceiveKeyboardWillChangeFrameNotification:(NSNotification *)notification
{
    [self ltz_handleKeyboardNotification:notification completion:nil];
}

- (void)ltz_didReceiveKeyboardDidChangeFrameNotification:(NSNotification *)notification
{
    [self ltz_setKeyboardViewHidden:NO];
    
    [self ltz_handleKeyboardNotification:notification completion:nil];
}

- (void)ltz_didReceiveKeyboardDidHideNotification:(NSNotification *)notification
{
    self.keyboardView = nil;
    
    [self ltz_handleKeyboardNotification:notification completion:^(BOOL finished) {
        [self.panGestureRecognizer removeTarget:self action:NULL];
        
        [self.delegate keyboardControllerKeyboardDidHide:self];
    }];
}

- (void)ltz_handleKeyboardNotification:(NSNotification *)notification completion:(LTZAnimationCompletionBlock)completion
{
    NSDictionary *userInfo = [notification userInfo];
    
    CGRect keyboardEndFrame = [userInfo[UIKeyboardFrameEndUserInfoKey] CGRectValue];
    
    if (CGRectIsNull(keyboardEndFrame)) {
        return;
    }
    
    UIViewAnimationCurve animationCurve = [userInfo[UIKeyboardAnimationCurveUserInfoKey] integerValue];
    NSInteger animationCurveOption = (animationCurve << 16);
    
    double animationDuration = [userInfo[UIKeyboardAnimationDurationUserInfoKey] doubleValue];
    
    CGRect keyboardEndFrameConverted = [self.contextView convertRect:keyboardEndFrame fromView:nil];
    
    [UIView animateWithDuration:animationDuration
                          delay:0.0
                        options:animationCurveOption
                     animations:^{
                         [self ltz_notifyKeyboardFrameNotificationForFrame:keyboardEndFrameConverted];
                     }
                     completion:^(BOOL finished) {
                         if (completion) {
                             completion(finished);
                         }
                     }];
}

#pragma mark - Utilities

- (void)ltz_setKeyboardViewHidden:(BOOL)hidden
{
    self.keyboardView.hidden = hidden;
    self.keyboardView.userInteractionEnabled = !hidden;
}

- (void)ltz_notifyKeyboardFrameNotificationForFrame:(CGRect)frame
{
    [self.delegate keyboardController:self keyboardDidChangeFrame:frame];
    
    [[NSNotificationCenter defaultCenter] postNotificationName:LTZKeyboardControllerNotificationKeyboardDidChangeFrame
                                                        object:self
                                                      userInfo:@{ LTZKeyboardControllerUserInfoKeyKeyboardDidChangeFrame : [NSValue valueWithCGRect:frame] }];
}

#pragma mark - Key-value observing

- (void)observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary *)change context:(void *)context
{
    if (context == LTZKeyboardControllerKeyValueObservingContext) {
        
        if (object == self.keyboardView && [keyPath isEqualToString:NSStringFromSelector(@selector(frame))]) {
            
            CGRect oldKeyboardFrame = [[change objectForKey:NSKeyValueChangeOldKey] CGRectValue];
            CGRect newKeyboardFrame = [[change objectForKey:NSKeyValueChangeNewKey] CGRectValue];
            
            if (CGRectEqualToRect(newKeyboardFrame, oldKeyboardFrame) || CGRectIsNull(newKeyboardFrame)) {
                return;
            }
            
            //  do not convert frame to contextView coordinates here
            //  KVO is triggered during panning (see below)
            //  panning occurs in contextView coordinates already
            [self ltz_notifyKeyboardFrameNotificationForFrame:newKeyboardFrame];
        }
    }
}

- (void)ltz_removeKeyboardFrameObserver
{
    if (!_ltz_isObserving) {
        return;
    }
    
    @try {
        [_keyboardView removeObserver:self
                           forKeyPath:NSStringFromSelector(@selector(frame))
                              context:LTZKeyboardControllerKeyValueObservingContext];
    }
    @catch (NSException * __unused exception) { }
    
    _ltz_isObserving = NO;
}

#pragma mark - Pan gesture recognizer

- (void)ltz_handlePanGestureRecognizer:(UIPanGestureRecognizer *)pan
{
    CGPoint touch = [pan locationInView:self.contextView];
    
    //  system keyboard is added to a new UIWindow, need to operate in window coordinates
    //  also, keyboard always slides from bottom of screen, not the bottom of a view
    CGFloat contextViewWindowHeight = CGRectGetHeight(self.contextView.window.frame);
    
    if ([UIDevice ltz_isCurrentDeviceBeforeiOS8]) {
        //  handle iOS 7 bug when rotating to landscape
        if (UIInterfaceOrientationIsLandscape([UIApplication sharedApplication].statusBarOrientation)) {
            contextViewWindowHeight = CGRectGetWidth(self.contextView.window.frame);
        }
    }
    
    CGFloat keyboardViewHeight = CGRectGetHeight(self.keyboardView.frame);
    
    CGFloat dragThresholdY = (contextViewWindowHeight - keyboardViewHeight - self.keyboardTriggerPoint.y);
    
    CGRect newKeyboardViewFrame = self.keyboardView.frame;
    
    BOOL userIsDraggingNearThresholdForDismissing = (touch.y > dragThresholdY);
    
    self.keyboardView.userInteractionEnabled = !userIsDraggingNearThresholdForDismissing;
    
    switch (pan.state) {
        case UIGestureRecognizerStateChanged:
        {
            newKeyboardViewFrame.origin.y = touch.y + self.keyboardTriggerPoint.y;
            
            //  bound frame between bottom of view and height of keyboard
            newKeyboardViewFrame.origin.y = MIN(newKeyboardViewFrame.origin.y, contextViewWindowHeight);
            newKeyboardViewFrame.origin.y = MAX(newKeyboardViewFrame.origin.y, contextViewWindowHeight - keyboardViewHeight);
            
            if (CGRectGetMinY(newKeyboardViewFrame) == CGRectGetMinY(self.keyboardView.frame)) {
                return;
            }
            
            [UIView animateWithDuration:0.0
                                  delay:0.0
                                options:UIViewAnimationOptionBeginFromCurrentState | UIViewAnimationOptionTransitionNone
                             animations:^{
                                 self.keyboardView.frame = newKeyboardViewFrame;
                             }
                             completion:nil];
        }
            break;
            
        case UIGestureRecognizerStateEnded:
        case UIGestureRecognizerStateCancelled:
        case UIGestureRecognizerStateFailed:
        {
            BOOL keyboardViewIsHidden = (CGRectGetMinY(self.keyboardView.frame) >= contextViewWindowHeight);
            if (keyboardViewIsHidden) {
                return;
            }
            
            CGPoint velocity = [pan velocityInView:self.contextView];
            BOOL userIsScrollingDown = (velocity.y > 0.0f);
            BOOL shouldHide = (userIsScrollingDown && userIsDraggingNearThresholdForDismissing);
            
            newKeyboardViewFrame.origin.y = shouldHide ? contextViewWindowHeight : (contextViewWindowHeight - keyboardViewHeight);
            
            [UIView animateWithDuration:0.25
                                  delay:0.0
                                options:UIViewAnimationOptionBeginFromCurrentState | UIViewAnimationCurveEaseOut
                             animations:^{
                                 self.keyboardView.frame = newKeyboardViewFrame;
                             }
                             completion:^(BOOL finished) {
                                 self.keyboardView.userInteractionEnabled = !shouldHide;
                                 
                                 if (shouldHide) {
                                     [self ltz_setKeyboardViewHidden:YES];
                                     [self ltz_removeKeyboardFrameObserver];
                                     [self.textView resignFirstResponder];
                                 }
                             }];
        }
            break;
            
        default:
            break;
    }
}

@end
