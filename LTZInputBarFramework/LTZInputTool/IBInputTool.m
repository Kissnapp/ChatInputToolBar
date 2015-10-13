 //
//  LTZInputTool.m
//  ChatInputToolBar
//
//  Created by Peter Lee on 15/2/3.
//  Copyright (c) 2015年 Peter Lee. All rights reserved.
//

#import "IBInputTool.h"
#import "IBInputToolBarConstraints.h"

#define DEFAULT_MAGIN_WIDTH 4.0f
#define DEFAULT_MAGIN_HEIGHT DEFAULT_MAGIN_WIDTH

#define DEFAULT_BUTTON_HEIGHT (self.frame.size.height - 2*DEFAULT_MAGIN_HEIGHT)
#define DEFAULT_BUTTON_WITDH DEFAULT_BUTTON_HEIGHT

#define DEFAULT_TEXT_VIEW_WIDTH (self.frame.size.width - 5*DEFAULT_MAGIN_WIDTH - 3*DEFAULT_BUTTON_WITDH)
#define DEFAULT_TEXT_VIEW_HEIGHT (self.frame.size.height - 2*DEFAULT_MAGIN_HEIGHT)

#define DEFAULT_RECORD_BUTTON_WIDTH DEFAULT_TEXT_VIEW_WIDTH
#define DEFAULT_RECORD_BUTTON_HEIGHT self.frame.size.height

static void * LTZInputTextViewHidenKeyValueObservingContext = &LTZInputTextViewHidenKeyValueObservingContext;

typedef NS_ENUM(NSUInteger, LTZInputToolStateType) {
    LTZInputToolStateTypeNone = 0,
    LTZInputToolStateTypeText,
    LTZInputToolStateTypeRecord,
    LTZInputToolStateTypeExpression,
    LTZInputToolStateTypeMore
};

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


@interface IBInputTool ()
{
    UIView          __weak  *_inView;
    UIView          __weak  *_backgroundView;
    UIScrollView    __weak  *_scrollView;
}

@property (assign ,nonatomic) LTZInputToolStateType inputToolCurrentStateType;
@property (assign, nonatomic) CGFloat spacingBetweenTextViewAndRecordButton;

@end

@implementation IBInputTool
@synthesize inView = _inView;
@synthesize backgroundView = _backgroundView;
@synthesize scrollView = _scrollView;
@synthesize placeholder = _placeholder;

////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
#pragma mark - LTZInputTool class public methods
////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
+ (CGFloat)IBInputToolDefaultHeight
{
    return LTZInputToolDefaultHeight;
}

////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
#pragma mark - LTZInputTool object public methods
////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////

- (instancetype)initWithFrame:(CGRect)frame
{
    return [self initWithFrame:frame inView:nil scrollView:nil backgroundView:nil privatedDelegate:nil publicDelegate:nil];
}

- (instancetype)initWithFrame:(CGRect)frame
                       inView:(UIView *)inView
                   scrollView:(UIScrollView *)scrollView
               backgroundView:(UIView *)backgroundView
             privatedDelegate:(id<IBInputToolPrivateDelegate>)privateDelegate
               publicDelegate:(id<IBInputToolPublicDelegate>) publicDelegate
{
    return [self initWithFrame:frame
                        inView:inView
                    scrollView:scrollView
                   placeholder:nil
                backgroundView:backgroundView
              privatedDelegate:privateDelegate
                publicDelegate:publicDelegate];
}

- (instancetype)initWithFrame:(CGRect)frame
                       inView:(UIView *)inView
                   scrollView:(UIScrollView *)scrollView
                  placeholder:(NSString *)placeholder
               backgroundView:(UIView *)backgroundView
             privatedDelegate:(id<IBInputToolPrivateDelegate>)privateDelegate
               publicDelegate:(id<IBInputToolPublicDelegate>) publicDelegate
{
    self = [super initWithFrame:frame];
    if (self) {
        _inView                 =   inView;
        _scrollView             =   scrollView;
        _placeholder            =   placeholder;
        if (backgroundView == nil){
            UIWindow *window = [[UIApplication sharedApplication] keyWindow];
            _backgroundView = window.rootViewController.view;
        }else{
            _backgroundView = backgroundView;
        }
        self.privateDelegate    =   privateDelegate;
        self.publicDelegate     =   publicDelegate;
        
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
        [self hideMoreViewOrExpressionView];
        
        if (self.inputToolCurrentStateType != LTZInputToolStateTypeRecord) {
            [self resumeOriginalState];
        }

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

- (CGRect)currentFrameWhenRecord
{
    CGRect frame = self.frame;
    frame.size.height = LTZInputToolDefaultHeight;
    return frame;
}

- (CGRect)currentFrameWhenInput
{
    CGRect frame = self.frame;
    frame.size.height = LTZInputToolDefaultHeight + ((_inputTextView.frame.size.height + self.spacingBetweenTextViewAndRecordButton) - _recordButton.frame.size.height);
    return frame;
}

////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
#pragma mark - LTZInputTool object private methods
////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////

- (void)_setupViews
{
    self.userInteractionEnabled = YES;
#if 1
    self.image = [[UIImage imageNamed:LTZInputBarImagePathWithName(@"chat_input_bg")] resizableImageWithCapInsets:UIEdgeInsetsMake(2.0f, 0.0f, 0.0f, 0.0f)
                                                                       resizingMode:UIImageResizingModeStretch];
#else
    self.backgroundColor = [UIColor redColor];//For testing
#endif
    _voiceButton = ({
        UIButton *button = [UIButton buttonWithType:UIButtonTypeCustom];
        button.frame = CGRectMake(DEFAULT_MAGIN_WIDTH, DEFAULT_MAGIN_HEIGHT, DEFAULT_BUTTON_WITDH, DEFAULT_BUTTON_HEIGHT);
        button.autoresizingMask = UIViewAutoresizingFlexibleTopMargin;
        [button setBackgroundImage:[UIImage imageNamed:LTZInputBarImagePathWithName(@"chat_input_voice_button")] forState:UIControlStateNormal];
        [button setBackgroundImage:[UIImage imageNamed:LTZInputBarImagePathWithName(@"chat_input_voice_buttonHL")] forState:UIControlStateHighlighted];
        [button addTarget:self action:@selector(voiceButtonCliked:) forControlEvents:UIControlEventTouchUpInside];
        [self addSubview:button];
        button;
    });
    
    _inputTextView = ({
        IBGrowingTextView *textView = [[IBGrowingTextView alloc] initWithFrame:CGRectMake(2*DEFAULT_MAGIN_WIDTH + DEFAULT_BUTTON_WITDH, DEFAULT_MAGIN_HEIGHT, DEFAULT_TEXT_VIEW_WIDTH, DEFAULT_TEXT_VIEW_HEIGHT)];
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
        textView.backgroundColor = [UIColor clearColor];
        textView.placeholder = self.placeholder ? :LTZInputBarLocalizedString(@"input_text_view_placeholder");
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
        button.frame = CGRectMake(2*DEFAULT_MAGIN_WIDTH + DEFAULT_BUTTON_WITDH, 0, DEFAULT_RECORD_BUTTON_WIDTH, DEFAULT_RECORD_BUTTON_HEIGHT);
        button.autoresizingMask = UIViewAutoresizingFlexibleTopMargin;
        [button setBackgroundImage:[[UIImage imageNamed:LTZInputBarImagePathWithName(@"chat_record_bg")] stretchableImageWithLeftCapWidth:30 topCapHeight:30] forState:UIControlStateNormal];
        [button setBackgroundImage:[[UIImage imageNamed:LTZInputBarImagePathWithName(@"chat_record_selected_bg")] stretchableImageWithLeftCapWidth:30 topCapHeight:30] forState:UIControlStateHighlighted];
        [button setTitle:LTZInputBarLocalizedString(@"record_button_normal_title") forState:UIControlStateNormal];
        [button setTitle:LTZInputBarLocalizedString(@"record_button_Highlighted_title") forState:UIControlStateHighlighted];
        [button setTitleColor:[UIColor darkGrayColor] forState:UIControlStateNormal];
        [button setTitleColor:[UIColor whiteColor] forState:UIControlStateHighlighted];
        [button setHidden:YES];
        
        [button addTarget:self action:@selector(recordButtonTouchDown:) forControlEvents:UIControlEventTouchDown];
        [button addTarget:self action:@selector(recordButtonTouchUpOutside:) forControlEvents:UIControlEventTouchUpOutside];
        [button addTarget:self action:@selector(recordButtonTouchUpInside:) forControlEvents:UIControlEventTouchUpInside];
        [button addTarget:self action:@selector(recordDragOutside:) forControlEvents:UIControlEventTouchDragExit];
        [button addTarget:self action:@selector(recordDragInside:) forControlEvents:UIControlEventTouchDragEnter];
        
        [self addSubview:button];
        button;
    });

    //Ensure that _inputView's frame and _recordButton's frame are equal
    self.spacingBetweenTextViewAndRecordButton = _recordButton.frame.size.height - _inputTextView.frame.size.height;
    
    _expressionButton = ({
        UIButton *button = [UIButton buttonWithType:UIButtonTypeCustom];
        button.frame = CGRectMake(3*DEFAULT_MAGIN_WIDTH+DEFAULT_BUTTON_WITDH+DEFAULT_TEXT_VIEW_WIDTH, DEFAULT_MAGIN_HEIGHT, DEFAULT_BUTTON_WITDH, DEFAULT_BUTTON_HEIGHT);
        button.autoresizingMask = UIViewAutoresizingFlexibleTopMargin;
        [button setBackgroundImage:[UIImage imageNamed:LTZInputBarImagePathWithName(@"chat_input_emo_button")] forState:UIControlStateNormal];
        [button setBackgroundImage:[UIImage imageNamed:LTZInputBarImagePathWithName(@"chat_input_emo_buttonHL")] forState:UIControlStateHighlighted];
        [button addTarget:self action:@selector(expressionButtonCliked:) forControlEvents:UIControlEventTouchUpInside];
        [self addSubview:button];
        button;
    });
    
    _moreButton = ({
        UIButton *button = [UIButton buttonWithType:UIButtonTypeCustom];
        button.frame = CGRectMake(4*DEFAULT_MAGIN_WIDTH+2*DEFAULT_BUTTON_WITDH+DEFAULT_TEXT_VIEW_WIDTH, DEFAULT_MAGIN_HEIGHT, DEFAULT_BUTTON_WITDH, DEFAULT_BUTTON_HEIGHT);
        button.autoresizingMask = UIViewAutoresizingFlexibleTopMargin;
        [button setBackgroundImage:[UIImage imageNamed:LTZInputBarImagePathWithName(@"chat_input_action_button")] forState:UIControlStateNormal];
        [button setBackgroundImage:[UIImage imageNamed:LTZInputBarImagePathWithName(@"chat_input_action_buttonHL")] forState:UIControlStateHighlighted];
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
    if ([self.inputTextView isFirstResponder]) {
        [self.inputTextView resignFirstResponder];
    }else{
        [self hideMoreViewOrExpressionView];
    }
    
    if (self.privateDelegate && [self.privateDelegate respondsToSelector:@selector(ltzInputToolDidShowRecordView:)]) {
        [self.privateDelegate ltzInputToolDidShowRecordView:self];
    }
    
    self.isMoreViewShowing = NO;
    self.isExpressionViewShowing = NO;
    self.isRecordViewShowing = YES;
    
    self.inputToolCurrentStateType = LTZInputToolStateTypeRecord;
}

- (void)prepareToInputText
{
    self.inputToolCurrentStateType = LTZInputToolStateTypeText;
    
    if (![self.inputTextView isFirstResponder]) {
        [self.inputTextView becomeFirstResponder];
    }
    
    if (self.privateDelegate && [self.privateDelegate respondsToSelector:@selector(ltzInputToolDidShowInputTextView:)]) {
        [self.privateDelegate ltzInputToolDidShowInputTextView:self];
    }
    
    [self resumeOriginalState];
    self.inputToolCurrentStateType = LTZInputToolStateTypeText;
}

- (void)prepareToInputExpression
{
    self.inputToolCurrentStateType = LTZInputToolStateTypeExpression;
    
    if (self.privateDelegate && [self.privateDelegate respondsToSelector:@selector(ltzInputToolDidShowExpressionView:)]) {
        [self.privateDelegate ltzInputToolDidShowExpressionView:self];
    }
    
    if ([self.inputTextView isFirstResponder]) {
        [self.inputTextView resignFirstResponder];
    }
    
    [self showMoreViewOrExpressionView];
    
    self.isMoreViewShowing = NO;
    self.isExpressionViewShowing = YES;
    self.isRecordViewShowing = NO;
}

- (void)prepareToInputMoreInfo
{
    self.inputToolCurrentStateType = LTZInputToolStateTypeMore;
    
    if (self.privateDelegate && [self.privateDelegate respondsToSelector:@selector(ltzInputToolDidShowMoreInfoView:)]) {
        [self.privateDelegate ltzInputToolDidShowMoreInfoView:self];
    }
    
    if ([self.inputTextView isFirstResponder]) {
        [self.inputTextView resignFirstResponder];
    }
    
    [self showMoreViewOrExpressionView];
    
    self.isMoreViewShowing = YES;
    self.isExpressionViewShowing = NO;
    self.isRecordViewShowing = NO;
}

- (void)resumeOriginalState
{
    self.isMoreViewShowing = NO;
    self.isExpressionViewShowing = NO;
    self.isRecordViewShowing = NO;
    self.inputToolCurrentStateType = LTZInputToolStateTypeNone;
}

- (void)showMoreViewOrExpressionView
{
    if (self.isMoreViewShowing || self.isExpressionViewShowing) return;
    
    // begin animation action
    [UIView beginAnimations:nil context:NULL];
    [UIView setAnimationDuration:LTZInputToolBarDefaultAnimationDuration];
    [UIView setAnimationCurve:(UIViewAnimationCurve)LTZInputToolBarDefaultAnimationCurve];

    CGRect newFrame = self.inView.frame;
    newFrame.origin.y = self.backgroundView.bounds.size.height - self.frame.size.height - LTZInputToolBarDefaultKetboardHeight;
    _inView.frame = newFrame;
    NSLog(@"frame:super:%@####root:%@",NSStringFromCGRect(self.inView.frame),NSStringFromCGRect(self.backgroundView.frame));
    // end animation action
    [UIView commitAnimations];
    
    [self scrollToBottom];
}

- (void)hideMoreViewOrExpressionView
{
    if (!self.isMoreViewShowing && !self.isExpressionViewShowing) return;
    
    // begin animation action
    [UIView beginAnimations:nil context:NULL];
    [UIView setAnimationDuration:LTZInputToolBarDefaultAnimationDuration];
    [UIView setAnimationCurve:(UIViewAnimationCurve)LTZInputToolBarDefaultAnimationCurve];
    
    CGRect newFrame = self.inView.frame;
    newFrame.origin.y = self.backgroundView.bounds.size.height - self.frame.size.height;
    _inView.frame = newFrame;
    
    // end animation action
    [UIView commitAnimations];
    
}

- (void)scrollToBottom
{
    if (!self.scrollView) return;
    
    [self.scrollView ltz_scrollToBottomWithOptions:LTZAnimationOptionsForCurve(LTZInputToolBarDefaultAnimationCurve)
                                          duration:LTZInputToolBarDefaultAnimationDuration
                                   completionBlock:nil];
}

- (void)_initData
{
    self.isKeyboardShowing = NO;
    self.isRecordViewShowing = NO;
    self.isExpressionViewShowing = NO;
    self.isMoreViewShowing = NO;
    self.inputToolCurrentStateType = LTZInputToolStateTypeNone;
}


- (void)dealloc
{
    @try {
        [_inputTextView removeObserver:self
                            forKeyPath:NSStringFromSelector(@selector(hidden))
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
////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
#pragma mark - record button actions
////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
- (void)recordButtonTouchDown:(id)sender
{
    if ([self.publicDelegate respondsToSelector:@selector(didStartRecordingWithLTZInputTool:)]) {
        [self.publicDelegate didStartRecordingWithLTZInputTool:self];
    }
}
- (void)recordButtonTouchUpOutside:(id)sender
{
    if ([self.publicDelegate respondsToSelector:@selector(didCancelRecordingWithLTZInputTool:)]) {
        [self.publicDelegate didCancelRecordingWithLTZInputTool:self];
    }
}
- (void)recordButtonTouchUpInside:(id)sender
{
    if ([self.publicDelegate respondsToSelector:@selector(didFinishRecordingWithLTZInputTool:)]) {
        [self.publicDelegate didFinishRecordingWithLTZInputTool:self];
    }
}
- (void)recordDragOutside:(id)sender
{
    if ([self.publicDelegate respondsToSelector:@selector(didDragOutsideWhenRecordingWithLTZInputTool:)]) {
        [self.publicDelegate didDragOutsideWhenRecordingWithLTZInputTool:self];
    }

}
- (void)recordDragInside:(id)sender
{
    if ([self.publicDelegate respondsToSelector:@selector(didDragInsideWhenRecordingWithLTZInputTool:)]) {
        [self.publicDelegate didDragInsideWhenRecordingWithLTZInputTool:self];
    }
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
    
    if (self.inputToolCurrentStateType == LTZInputToolStateTypeNone || self.inputToolCurrentStateType == LTZInputToolStateTypeText) {
        
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
            CGFloat keyboardY = [self.backgroundView convertRect:keyboardRect fromView:nil].origin.y;
            
            CGRect inputViewFrame = self.inView.frame;
            
            CGFloat inputViewFrameY = keyboardY - self.frame.size.height;
            
            // for ipad modal form presentations
            CGFloat messageViewFrameBottom = self.backgroundView.bounds.size.height - self.frame.size.height;
            
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
    [_moreButton setBackgroundImage:[UIImage imageNamed:(isMoreViewShowing ? LTZInputBarImagePathWithName(@"chat_input_keyboard_button"):LTZInputBarImagePathWithName(@"chat_input_action_button"))] forState:UIControlStateNormal];
    [_moreButton setBackgroundImage:[UIImage imageNamed:(isMoreViewShowing ? LTZInputBarImagePathWithName(@"chat_input_keyboard_buttonHL"):LTZInputBarImagePathWithName(@"chat_input_action_buttonHL"))] forState:UIControlStateHighlighted];
    
}

- (void)setIsExpressionViewShowing:(BOOL)isExpressionViewShowing
{
    _isExpressionViewShowing = isExpressionViewShowing;
    [_expressionButton setBackgroundImage:[UIImage imageNamed:(isExpressionViewShowing ? LTZInputBarImagePathWithName(@"chat_input_keyboard_button"):LTZInputBarImagePathWithName(@"chat_input_emo_button"))] forState:UIControlStateNormal];
    [_expressionButton setBackgroundImage:[UIImage imageNamed:(isExpressionViewShowing ? LTZInputBarImagePathWithName(@"chat_input_keyboard_buttonHL"):LTZInputBarImagePathWithName(@"chat_input_emo_buttonHL"))] forState:UIControlStateHighlighted];
}

- (void)setIsRecordViewShowing:(BOOL)isRecordViewShowing
{
    _isRecordViewShowing = isRecordViewShowing;
    [_voiceButton setBackgroundImage:[UIImage imageNamed:(isRecordViewShowing ? LTZInputBarImagePathWithName(@"chat_input_keyboard_button"):LTZInputBarImagePathWithName(@"chat_input_voice_button"))] forState:UIControlStateNormal];
    [_voiceButton setBackgroundImage:[UIImage imageNamed:(isRecordViewShowing ? LTZInputBarImagePathWithName(@"chat_input_keyboard_buttonHL"):LTZInputBarImagePathWithName(@"chat_input_voice_buttonHL"))] forState:UIControlStateHighlighted];
    
    [_inputTextView setHidden:isRecordViewShowing];
    [_recordButton setHidden:!isRecordViewShowing];
    
    [self bringSubviewToFront:(isRecordViewShowing ? _recordButton:_inputTextView)];
    
}
////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
#pragma mark - LTZGrowingTextViewDelegate methods
////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
- (BOOL)growingTextViewShouldBeginEditing:(IBGrowingTextView *)growingTextView
{

    if (self.privateDelegate && [self.privateDelegate respondsToSelector:@selector(ltzInputToolWillBecomeFirstResponder:)]) {
        [self.privateDelegate ltzInputToolWillBecomeFirstResponder:self];
    }
    
    [self resumeOriginalState];
    self.inputToolCurrentStateType = LTZInputToolStateTypeText;
    
    return YES;
}
- (BOOL)growingTextViewShouldEndEditing:(IBGrowingTextView *)growingTextView
{
    return YES;
}
- (void)growingTextView:(IBGrowingTextView *)growingTextView willChangeHeight:(float)height
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

- (BOOL)growingTextView:(IBGrowingTextView *)growingTextView shouldChangeTextInRange:(NSRange)range replacementText:(NSString *)text
{
    
    if ([text isEqualToString:@"\n"])
    {
        NSString * content = growingTextView.text;
        if (content.length == 0 || [content isEqualToString:@""]){
            NSLog(@"请输入内容");
        }
        else {
            
            if (self.publicDelegate && [self.publicDelegate respondsToSelector:@selector(ltzInputTool:didSentTextContent:)]) {
                [self.publicDelegate ltzInputTool:self didSentTextContent:content];
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
    CGFloat changedHeight = (_inputTextView.frame.size.height + self.spacingBetweenTextViewAndRecordButton) - _recordButton.frame.size.height;
    
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
