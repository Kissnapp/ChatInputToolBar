//
//  LTZInputTool.m
//  ChatInputToolBar
//
//  Created by Peter Lee on 15/2/3.
//  Copyright (c) 2015年 Peter Lee. All rights reserved.
//

#import "LTZInputTool.h"
#import "LTZInputToolBarConstraints.h"

#define DEFAULT_MAGIN_WIDTH 4.0f
#define DEFAULT_MAGIN_HEIGHT DEFAULT_MAGIN_WIDTH

#define DEFAULT_BUTTON_HEIGHT (self.frame.size.height - 2*DEFAULT_MAGIN_HEIGHT)
#define DEFAULT_BUTTON_WITDH DEFAULT_BUTTON_HEIGHT

#define DEFAULT_TEXT_VIEW_WIDTH (self.frame.size.width - 5*DEFAULT_MAGIN_WIDTH - 3*DEFAULT_BUTTON_WITDH)
#define DEFAULT_TEXT_VIEW_HEIGHT (self.frame.size.height - 2*DEFAULT_MAGIN_HEIGHT)

static void * LTZInputTextViewHidenKeyValueObservingContext = &LTZInputTextViewHidenKeyValueObservingContext;

////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
#pragma mark - inline methods
////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
static CGFloat LTZContentOffsetForBottom(UIScrollView *scrollView) {
    CGFloat contentHeight = scrollView.contentSize.height;
    CGFloat scrollViewHeight = scrollView.bounds.size.height;
    
    UIEdgeInsets contentInset = scrollView.contentInset;
    CGFloat bottomInset = contentInset.bottom;
    CGFloat topInset = contentInset.top;
    
    CGFloat contentOffsetY;
    contentOffsetY = contentHeight - (scrollViewHeight - bottomInset);
    contentOffsetY = MAX(contentOffsetY, -topInset);
    
    return contentOffsetY;
}

static inline UIViewAnimationOptions LTZAnimationOptionsForCurve(UIViewAnimationCurve curve) {
    return (curve << 16 | UIViewAnimationOptionBeginFromCurrentState);
}


////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
#pragma mark - UIScrollView+LTZInputTool
////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////

@interface UIScrollView (LTZInputTool)

- (BOOL)ltz_isAtBottom;
- (void)ltz_scrollToBottomAnimated:(BOOL)animated
               withCompletionBlock:(void(^)(void))completionBlock;

- (void)ltz_scrollToBottomWithOptions:(UIViewAnimationOptions)options
                             duration:(CGFloat)duration
                      completionBlock:(void(^)(void))completionBlock;

@end

#pragma mark - UIScrollView + LTZInputTool

@implementation UIScrollView (LTZInputTool)


- (BOOL)ltz_isAtBottom
{
    UIScrollView *scrollView = self;
    CGFloat y = scrollView.contentOffset.y;
    CGFloat yBottom = LTZContentOffsetForBottom(scrollView);
    
    return (y == yBottom);
}

- (void)ltz_scrollToBottomAnimated:(BOOL)animated
               withCompletionBlock:(void(^)(void))completionBlock
{
    [self ltz_scrollToBottomWithOptions:0
                               duration:LTZInputToolBarDefaultAnimationDuration
                        completionBlock:completionBlock];
}

- (void)ltz_scrollToBottomWithOptions:(UIViewAnimationOptions)options
                             duration:(CGFloat)duration
                      completionBlock:(void(^)(void))completionBlock
{
    UIScrollView *scrollView = self;
    CGPoint contentOffset = scrollView.contentOffset;
    contentOffset.y = LTZContentOffsetForBottom(scrollView);
    
    void(^animations)() = ^{
        scrollView.contentOffset = contentOffset;
    };
    
    void(^completion)(BOOL) = ^(BOOL finished){
        if (completionBlock) {
            completionBlock();
        }
    };
    
    [UIView animateWithDuration:duration
                          delay:0.0f
                        options:options
                     animations:animations
                     completion:completion];
}

@end


////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
#pragma mark - LTZInputTool
////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////


@interface LTZInputTool ()
{
    UIView          *_inView;
    UIScrollView    *_scrollView;

}

@end

@implementation LTZInputTool
@synthesize inView = _inView;
@synthesize scrollView = _scrollView;
////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
#pragma mark - LTZInputTool class public methods
////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
+ (CGFloat)LTZInputToolDefaultHeight
{
    return LTZInputToolDefaultHeight;
}

////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
#pragma mark - LTZInputTool object public methods
////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////

- (instancetype)initWithFrame:(CGRect)frame
{
    return [self initWithFrame:frame inView:nil scrollView:nil delegate:nil];
}

- (instancetype)initWithFrame:(CGRect)frame
                       inView:(UIView *)inView
                   scrollView:(UIScrollView *)scrollView
                     delegate:(id<LTZInputToolDelegate>)delegate
{
    self = [super initWithFrame:frame];
    if (self) {
        _inView         =   inView;
        _scrollView     =   scrollView;
        self.delegate   =   delegate;
        
        [self _initData];
        [self _setupViews];
        [self beginListeningForKeyboard];
    }
    return self;
}

- (BOOL)resignFirstResponder
{
    BOOL result = NO;
    
    if ([_inputTextView isFirstResponder]) {
        result = [_inputTextView resignFirstResponder];
    }else{
        [self resumeOriginalState];
        [self hideMoreViewOrExpressionView];
        result = YES;
    }
    
    return result;
}

- (BOOL)isFirstResponder
{
    BOOL result = NO;
    
    result = [_inputTextView isFirstResponder];
    
    if (!result) {
        result = self.isMoreViewShowing || self.isRecordViewShowing || self.isExpressionViewShowing;
    }
    
    return result;
}
- (BOOL)becomeFirstResponder
{
    if ([self isFirstResponder]) return NO;
    
    return [_inputTextView becomeFirstResponder];
}

////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
#pragma mark - LTZInputTool object private methods
////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////

- (void)_setupViews
{
    self.userInteractionEnabled = YES;
#if 1
    self.image = [[UIImage imageNamed:@"chat_input_bg"] resizableImageWithCapInsets:UIEdgeInsetsMake(2.0f, 0.0f, 0.0f, 0.0f)
                                                                       resizingMode:UIImageResizingModeStretch];
#else
    self.backgroundColor = [UIColor redColor];//For testing
#endif
    _voiceButton = ({
        UIButton *button = [UIButton buttonWithType:UIButtonTypeCustom];
        button.frame = CGRectMake(DEFAULT_MAGIN_WIDTH, DEFAULT_MAGIN_HEIGHT, DEFAULT_BUTTON_WITDH, DEFAULT_BUTTON_HEIGHT);
        button.autoresizingMask = UIViewAutoresizingFlexibleTopMargin;
        [button setBackgroundImage:[UIImage imageNamed:@"chat_input_voice_button"] forState:UIControlStateNormal];
        [button setBackgroundImage:[UIImage imageNamed:@"chat_input_voice_buttonHL"] forState:UIControlStateHighlighted];
        [button addTarget:self action:@selector(voiceButtonCliked:) forControlEvents:UIControlEventTouchUpInside];
        [self addSubview:button];
        button;
    });
    
    _inputTextView = ({
        LTZGrowingTextView *textView = [[LTZGrowingTextView alloc] initWithFrame:CGRectMake(2*DEFAULT_MAGIN_WIDTH + DEFAULT_BUTTON_WITDH, DEFAULT_MAGIN_HEIGHT, DEFAULT_TEXT_VIEW_WIDTH, DEFAULT_TEXT_VIEW_HEIGHT)];
        textView.isScrollable = NO;
        textView.contentInset = UIEdgeInsetsMake(0, 5, 0, 5);
        
        textView.minNumberOfLines = 1;
        textView.maxNumberOfLines = 4;
        // you can also set the maximum height in points with maxHeight
        // textView.maxHeight = 200.0f;
        textView.returnKeyType = UIReturnKeySend; //just as an example
        textView.font = [UIFont systemFontOfSize:16.0f];
        textView.delegate = self;
        textView.internalTextView.scrollIndicatorInsets = UIEdgeInsetsMake(5, 0, 5, 0);
        textView.backgroundColor = [UIColor whiteColor];
        textView.placeholder = @"message...";
        textView.autoresizingMask = UIViewAutoresizingFlexibleWidth;
        
        // textView.text = @"test\n\ntest";
        // textView.animateHeightChange = NO; //turns off animation
        
        CGFloat cornerRadius = 6.0f;
        textView.backgroundColor = [UIColor whiteColor];
        textView.layer.borderWidth = 0.5f;
        textView.layer.borderColor = [UIColor colorWithWhite:0.8f alpha:1.0f].CGColor;
        textView.layer.cornerRadius = cornerRadius;
        
        CGPoint center = textView.center;
        center.y = self.center.y;
        textView.center = center;
        
        [self addSubview:textView];
        
        textView;
    });
    
    _recordButton = ({
        UIButton *button = [UIButton buttonWithType:UIButtonTypeCustom];
        button.frame = CGRectMake(2*DEFAULT_MAGIN_WIDTH + DEFAULT_BUTTON_WITDH, DEFAULT_MAGIN_HEIGHT, DEFAULT_TEXT_VIEW_WIDTH, DEFAULT_TEXT_VIEW_HEIGHT);
        button.autoresizingMask = UIViewAutoresizingFlexibleTopMargin;
        [button setBackgroundImage:[[UIImage imageNamed:@"chat_record_bg"] stretchableImageWithLeftCapWidth:30 topCapHeight:30] forState:UIControlStateNormal];
        [button setBackgroundImage:[[UIImage imageNamed:@"chat_record_selected_bg"] stretchableImageWithLeftCapWidth:30 topCapHeight:30] forState:UIControlStateHighlighted];
        [button setTitle:@"按住\t对讲" forState:UIControlStateNormal];
        [button setTitle:@"松开\t完成" forState:UIControlStateHighlighted];
        [button setTitleColor:[UIColor darkGrayColor] forState:UIControlStateNormal];
        [button setTitleColor:[UIColor whiteColor] forState:UIControlStateHighlighted];
        [button setHidden:YES];
        [self addSubview:button];
        button;
    });
    
    //Ensure that _inputView's frame and _recordButton's frame are equal
    _recordButton.frame = _inputTextView.frame;
    
    _expressionButton = ({
        UIButton *button = [UIButton buttonWithType:UIButtonTypeCustom];
        button.frame = CGRectMake(3*DEFAULT_MAGIN_WIDTH+DEFAULT_BUTTON_WITDH+DEFAULT_TEXT_VIEW_WIDTH, DEFAULT_MAGIN_HEIGHT, DEFAULT_BUTTON_WITDH, DEFAULT_BUTTON_HEIGHT);
        button.autoresizingMask = UIViewAutoresizingFlexibleTopMargin;
        [button setBackgroundImage:[UIImage imageNamed:@"chat_input_emo_button"] forState:UIControlStateNormal];
        [button setBackgroundImage:[UIImage imageNamed:@"chat_input_emo_buttonHL"] forState:UIControlStateHighlighted];
        [button addTarget:self action:@selector(expressionButtonCliked:) forControlEvents:UIControlEventTouchUpInside];
        [self addSubview:button];
        button;
    });
    
    _moreButton = ({
        UIButton *button = [UIButton buttonWithType:UIButtonTypeCustom];
        button.frame = CGRectMake(4*DEFAULT_MAGIN_WIDTH+2*DEFAULT_BUTTON_WITDH+DEFAULT_TEXT_VIEW_WIDTH, DEFAULT_MAGIN_HEIGHT, DEFAULT_BUTTON_WITDH, DEFAULT_BUTTON_HEIGHT);
        button.autoresizingMask = UIViewAutoresizingFlexibleTopMargin;
        [button setBackgroundImage:[UIImage imageNamed:@"chat_input_action_button"] forState:UIControlStateNormal];
        [button setBackgroundImage:[UIImage imageNamed:@"chat_input_action_buttonHL"] forState:UIControlStateHighlighted];
        [button addTarget:self action:@selector(moreButtonCliked:) forControlEvents:UIControlEventTouchUpInside];
        [self addSubview:button];
        button;
    });
    
    [_inputTextView addObserver:self
                    forKeyPath:NSStringFromSelector(@selector(hidden))
                       options:(NSKeyValueObservingOptionOld | NSKeyValueObservingOptionNew)
                       context:LTZInputTextViewHidenKeyValueObservingContext];
}

- (void)voiceButtonCliked:(id)sender
{
    if (!self.isRecordViewShowing) {
        
        [self prepareToRecord];
        
    }else{
        
        [self prepareToInputText];
    }
}

- (void)moreButtonCliked:(id)sender
{
    if (self.isMoreViewShowing) {
        [self prepareToInputText];
    }else{
        [self prepareToInputMoreInfo];
    }
}

- (void)expressionButtonCliked:(id)sender
{
    if (self.isExpressionViewShowing) {
        [self prepareToInputText];
    }else{
        [self prepareToInputExpression];
    }
}

- (void)prepareToRecord
{
    self.isMoreViewShowing = NO;
    self.isExpressionViewShowing = NO;
    self.isRecordViewShowing = YES;
    
    if ([self.inputTextView isFirstResponder]) {
        [self.inputTextView resignFirstResponder];
    }else{
        [self hideMoreViewOrExpressionView];
    }
    
    if (self.delegate && [self.delegate respondsToSelector:@selector(ltzInputToolDidShowRecordView:)]) {
        [self.delegate ltzInputToolDidShowRecordView:self];
    }
}

- (void)prepareToInputText
{
    [self resumeOriginalState];
    
    if (![self.inputTextView isFirstResponder]) {
        [self.inputTextView becomeFirstResponder];
    }
    
    if (self.delegate && [self.delegate respondsToSelector:@selector(ltzInputToolDidShowInputTextView:)]) {
        [self.delegate ltzInputToolDidShowInputTextView:self];
    }
}

- (void)prepareToInputExpression
{
    self.isMoreViewShowing = NO;
    self.isExpressionViewShowing = YES;
    self.isRecordViewShowing = NO;
    
    if ([self.inputTextView isFirstResponder]) {
        [self.inputTextView resignFirstResponder];
    }
    
    if (self.delegate && [self.delegate respondsToSelector:@selector(ltzInputToolDidShowExpressionView:)]) {
        [self.delegate ltzInputToolDidShowExpressionView:self];
    }
    
    [self showMoreViewOrExpressionView];
    
}

- (void)prepareToInputMoreInfo
{
    self.isMoreViewShowing = YES;
    self.isExpressionViewShowing = NO;
    self.isRecordViewShowing = NO;
    
    if ([self.inputTextView isFirstResponder]) {
        [self.inputTextView resignFirstResponder];
    }
    
    if (self.delegate && [self.delegate respondsToSelector:@selector(ltzInputToolDidShowMoreInfoView:)]) {
        [self.delegate ltzInputToolDidShowMoreInfoView:self];
    }
    
    [self showMoreViewOrExpressionView];
}

- (void)resumeOriginalState
{
    self.isMoreViewShowing = NO;
    self.isExpressionViewShowing = NO;
    self.isRecordViewShowing = NO;
}

- (void)showMoreViewOrExpressionView
{
    if (!self.isMoreViewShowing && !self.isExpressionViewShowing) return;
    
    // begin animation action
    [UIView beginAnimations:nil context:NULL];
    [UIView setAnimationDuration:LTZInputToolBarDefaultAnimationDuration];
    [UIView setAnimationCurve:(UIViewAnimationCurve)LTZInputToolBarDefaultAnimationCurve];
    
    UIWindow *window = [[UIApplication sharedApplication] keyWindow];
    UIView *view = window.rootViewController.view;
    
    CGRect newFrame = self.inView.frame;
    newFrame.origin.y = view.frame.size.height - self.frame.size.height - LTZInputToolBarDefaultKetboardHeight;
    _inView.frame = newFrame;
    
    // end animation action
    [UIView commitAnimations];
    
    [self.scrollView ltz_scrollToBottomWithOptions:LTZAnimationOptionsForCurve(LTZInputToolBarDefaultAnimationCurve)
                                          duration:LTZInputToolBarDefaultAnimationDuration
                                   completionBlock:nil];
}

- (void)hideMoreViewOrExpressionView
{
    if (self.isMoreViewShowing || self.isExpressionViewShowing) return;
    
    // begin animation action
    [UIView beginAnimations:nil context:NULL];
    [UIView setAnimationDuration:LTZInputToolBarDefaultAnimationDuration];
    [UIView setAnimationCurve:(UIViewAnimationCurve)LTZInputToolBarDefaultAnimationCurve];
    
    UIWindow *window = [[UIApplication sharedApplication] keyWindow];
    UIView *view = window.rootViewController.view;
    
    CGRect newFrame = self.inView.frame;
    newFrame.origin.y = view.frame.size.height - self.frame.size.height;
    _inView.frame = newFrame;
    
    // end animation action
    [UIView commitAnimations];
    
}

- (void)_initData
{
    self.isKeyboardShowing = NO;
    self.isRecordViewShowing = NO;
    self.isExpressionViewShowing = NO;
    self.isMoreViewShowing = NO;
}


- (void)dealloc
{
    @try {
        [_inputTextView removeObserver:self
                            forKeyPath:NSStringFromSelector(@selector(frame))
                               context:LTZInputTextViewHidenKeyValueObservingContext];
    }@catch (NSException * __unused exception) {
    
    }
    _voiceButton = nil;
    _inputTextView = nil;
    _recordButton = nil;
    _expressionButton = nil;
    _moreButton = nil;
    [self endListeningForKeyboard];
}

- (void)beginListeningForKeyboard
{
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(inputKeyboardWillShow:)
                                                 name:UIKeyboardWillShowNotification
                                               object:nil];
    
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(inputKeyboardWillHide:)
                                                 name:UIKeyboardWillHideNotification
                                               object:nil];
}
- (void)endListeningForKeyboard
{
    [[NSNotificationCenter defaultCenter] removeObserver:self name:UIKeyboardWillShowNotification object:nil];
    [[NSNotificationCenter defaultCenter] removeObserver:self name:UIKeyboardWillHideNotification object:nil];
}

#pragma mark - 监听键盘的显示与隐藏
-(void)inputKeyboardWillShow:(NSNotification *)notification
{
    self.isKeyboardShowing = YES;
    [self keyboardWillShowHide:notification];
}
-(void)inputKeyboardWillHide:(NSNotification *)notification
{
    self.isKeyboardShowing = NO;
    [self keyboardWillShowHide:notification];
}

- (void)keyboardWillShowHide:(NSNotification *)notification
{
    
    if (!self.isMoreViewShowing && !self.isExpressionViewShowing) {
        
        CGRect keyboardRect = [[notification.userInfo objectForKey:UIKeyboardFrameEndUserInfoKey] CGRectValue];
        
        // The keyboard animation time duration
        NSTimeInterval animationDuration = [[notification.userInfo objectForKey:UIKeyboardAnimationDurationUserInfoKey] doubleValue];
        
        // The keyboard animation curve
        NSUInteger animationCurve = [[notification.userInfo valueForKey:UIKeyboardAnimationCurveUserInfoKey] unsignedIntegerValue];
        
        // begin animation action
        [UIView beginAnimations:nil context:NULL];
        [UIView setAnimationDuration:animationDuration];
        [UIView setAnimationCurve:(UIViewAnimationCurve)animationCurve];
        
        {
            UIWindow *window = [[UIApplication sharedApplication] keyWindow];
            UIView *view = window.rootViewController.view;
            
            CGFloat keyboardY = [view convertRect:keyboardRect fromView:nil].origin.y;
            
            CGRect inputViewFrame = self.inView.frame;
            
            CGFloat inputViewFrameY = keyboardY - self.frame.size.height;
            
            // for ipad modal form presentations
            CGFloat messageViewFrameBottom = view.frame.size.height - self.frame.size.height;
            
            if(inputViewFrameY > messageViewFrameBottom) inputViewFrameY = messageViewFrameBottom;
            
            inputViewFrame.origin.y = inputViewFrameY;
            
            _inView.frame = inputViewFrame;
            
        }
        
        // end animation action
        [UIView commitAnimations];
        
        
        [self.scrollView ltz_scrollToBottomWithOptions:LTZAnimationOptionsForCurve(animationCurve)
                                              duration:animationDuration
                                       completionBlock:nil];
    }
}


////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
#pragma mark - LTZInputTool properites
////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////

- (void)setIsMoreViewShowing:(BOOL)isMoreViewShowing
{
    _isMoreViewShowing = isMoreViewShowing;
    [_moreButton setBackgroundImage:[UIImage imageNamed:(isMoreViewShowing ? @"chat_input_keyboard_button":@"chat_input_action_button")] forState:UIControlStateNormal];
    [_moreButton setBackgroundImage:[UIImage imageNamed:(isMoreViewShowing ? @"chat_input_keyboard_buttonHL":@"chat_input_action_buttonHL")] forState:UIControlStateHighlighted];
    
}

- (void)setIsExpressionViewShowing:(BOOL)isExpressionViewShowing
{
    _isExpressionViewShowing = isExpressionViewShowing;
    [_expressionButton setBackgroundImage:[UIImage imageNamed:(isExpressionViewShowing ? @"chat_input_keyboard_button":@"chat_input_emo_button")] forState:UIControlStateNormal];
    [_expressionButton setBackgroundImage:[UIImage imageNamed:(isExpressionViewShowing ? @"chat_input_keyboard_buttonHL":@"chat_input_emo_buttonHL")] forState:UIControlStateHighlighted];
}

- (void)setIsRecordViewShowing:(BOOL)isRecordViewShowing
{
    _isRecordViewShowing = isRecordViewShowing;
    [_voiceButton setBackgroundImage:[UIImage imageNamed:(isRecordViewShowing ? @"chat_input_keyboard_button":@"chat_input_voice_button")] forState:UIControlStateNormal];
    [_voiceButton setBackgroundImage:[UIImage imageNamed:(isRecordViewShowing ? @"chat_input_keyboard_buttonHL":@"chat_input_voice_buttonHL")] forState:UIControlStateHighlighted];
    
    [_inputTextView setHidden:isRecordViewShowing];
    [_recordButton setHidden:!isRecordViewShowing];
    
}
////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
#pragma mark - LTZGrowingTextViewDelegate methods
////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
- (BOOL)growingTextViewShouldBeginEditing:(LTZGrowingTextView *)growingTextView
{
    [self resumeOriginalState];
    if (self.delegate && [self.delegate respondsToSelector:@selector(ltzInputToolWillBecomeFirstResponder:)]) {
        [self.delegate ltzInputToolWillBecomeFirstResponder:self];
    }
    return YES;
}
- (BOOL)growingTextViewShouldEndEditing:(LTZGrowingTextView *)growingTextView
{
    return YES;
}
- (void)growingTextView:(LTZGrowingTextView *)growingTextView willChangeHeight:(float)height
{
    float changedHeight = (growingTextView.frame.size.height - height);
    
    //changed its height of frame
    CGRect newFrame = self.frame;
    newFrame.size.height -= changedHeight;
    //newFrame.origin.y += changedHeight;
    self.frame = newFrame;
    
    //changed its futher view frame
    CGRect inViewFrame = self.inView.frame;
    inViewFrame.size.height -= changedHeight;
    inViewFrame.origin.y += changedHeight;
    _inView.frame = inViewFrame;
    
    [self.scrollView ltz_scrollToBottomWithOptions:LTZAnimationOptionsForCurve(LTZInputToolBarDefaultAnimationCurve)
                                          duration:LTZInputToolBarDefaultAnimationDuration
                                   completionBlock:nil];
}

- (BOOL)growingTextView:(LTZGrowingTextView *)growingTextView shouldChangeTextInRange:(NSRange)range replacementText:(NSString *)text
{
    
    if ([text isEqualToString:@"\n"])
    {
        NSString * content = growingTextView.text;
        if (content.length == 0 || [content isEqualToString:@""]){
            NSLog(@"请输入内容");
        }
        else {
            
            if (self.delegate && [self.delegate respondsToSelector:@selector(ltzInputTool:didSentTextContent:)]) {
                [self.delegate ltzInputTool:self didSentTextContent:content];
            }
            
            growingTextView.text = @"";
        }
        return NO;
    }
    return YES;
}

#pragma mark - Key-value observing

- (void)observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary *)change context:(void *)context
{
    if (context == LTZInputTextViewHidenKeyValueObservingContext) {
        
        if (object == _inputTextView && [keyPath isEqualToString:NSStringFromSelector(@selector(hidden))]) {
            
            BOOL oldHidenState = [[change objectForKey:NSKeyValueChangeOldKey] boolValue];
            BOOL newHidenState = [[change objectForKey:NSKeyValueChangeNewKey] boolValue];
            
            if (newHidenState == oldHidenState) {
                return;
            }
            
            //  do not convert frame to contextView coordinates here
            //  KVO is triggered during panning (see below)
            //  panning occurs in contextView coordinates already
            [self adjustInViewFrameWithInputViewHiddenState:newHidenState];
        }
    }
}

- (void)adjustInViewFrameWithInputViewHiddenState:(BOOL)hidde
{
    CGFloat changedHeight = _inputTextView.frame.size.height - _recordButton.frame.size.height;
    
    if (changedHeight == 0) return;
    
    CGRect newFrame = self.frame;
    CGRect inViewFrame = self.inView.frame;
    
    if (hidde) {//inputView :show->hidden
        
        //changed its height of frame
        newFrame.size.height -= changedHeight;
        
        //changed its futher view frame
        inViewFrame.size.height -= changedHeight;
        inViewFrame.origin.y += changedHeight;
        
        
    }else{//inputView :hidden->show
    
        //changed its height of frame
        newFrame.size.height += changedHeight;
        
        //changed its futher view frame
        inViewFrame.size.height += changedHeight;
        inViewFrame.origin.y -= changedHeight;
    }
    
    self.frame = newFrame;
    _inView.frame = inViewFrame;
}

@end
