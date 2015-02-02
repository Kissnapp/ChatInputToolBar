//
//  LTZInputToolBar.m
//  LTZInputToolBar
//
//  Created by Peter Lee on 15/1/16.
//  Copyright (c) 2015年 Peter Lee. All rights reserved.
//

#import "LTZInputToolBar.h"
#import "HPGrowingTextView.h"
#import "LTZMoreInputView.h"
#import "LTZExpressionInputView.h"
#import "LTZInputToolBarDelegate.h"

#define DEFAULT_MAGIN_WIDTH 4.0f
#define DEFAULT_MAGIN_HEIGHT DEFAULT_MAGIN_WIDTH

#define DEFAULT_BUTTON_HEIGHT (self.frame.size.height - 2*DEFAULT_MAGIN_HEIGHT)
#define DEFAULT_BUTTON_WITDH DEFAULT_BUTTON_HEIGHT

#define DEFAULT_TEXT_VIEW_WIDTH (self.frame.size.width - 5*DEFAULT_MAGIN_WIDTH - 3*DEFAULT_BUTTON_WITDH)
#define DEFAULT_TEXT_VIEW_HEIGHT (self.frame.size.height - 2*DEFAULT_MAGIN_HEIGHT)

#define DEFAULT_TALK_BUTTON_WIDTH 80.0f
#define DEFAULT_TALK_BUTTON_HEIGHT DEFAULT_TALK_BUTTON_WIDTH

#define DEFAULT_KEYBOARD_HEIGHT 216.0f
#define DEFAULT_ANIMATION_DURATION 0.25
#define DEFAULT_ANIMATION_CURVE 7

@interface LTZInputToolBar ()<UITextViewDelegate, HPGrowingTextViewDelegate>
{
    UIView              *_contextView;
    UIScrollView        *_scrollView;
    HPGrowingTextView   *_inputTextView;
}

@property (strong, nonatomic) UIButton                  *voiceButton;
@property (strong, nonatomic) UIButton                  *expressionButton;
@property (strong, nonatomic) UIButton                  *moreButton;
@property (strong, nonatomic) UIButton                  *recordButton;

@property (strong, nonatomic) LTZExpressionInputView    *expressionInputView;
@property (strong, nonatomic) LTZMoreInputView          *moreInputView;

@property (assign, nonatomic) BOOL                      isKeyboardShowing;
@property (assign, nonatomic) BOOL                      isRecordViewShowing;
@property (assign, nonatomic) BOOL                      isExpressionViewShowing;
@property (assign, nonatomic) BOOL                      isMoreViewShowing;

@property (assign, nonatomic) CGRect                    defaultFrame;
@property (assign, nonatomic) CGRect                    originFrame;

@end

@implementation LTZInputToolBar
@synthesize inputTextView   =   _inputTextView;
@synthesize contextView     =   _contextView;
@synthesize scrollView      =   _scrollView;

#pragma mark - public methods
- (id)initWithFrame:(CGRect)frame
{
    return [self initWithFrame:frame scrollView:nil inView:nil gestureRecognizer:nil delegate:nil];
}

- (id)initWithFrame:(CGRect)frame
         scrollView:(UIScrollView *)scrollView
             inView:(UIView *)contextView
  gestureRecognizer:(UIPanGestureRecognizer *)panGestureRecognizer
           delegate:(id<LTZInputToolBarDelegate>)delegate
{
    self = [super initWithFrame:frame];
    if (self) {
        _scrollView = scrollView;
        _contextView = contextView;
        _delegate = delegate;
        
        self.panGestureRecognizer = panGestureRecognizer;
        
        // Initialization code
        [self _initData];
        [self _setupViews];
        [self beginListeningForKeyboard];
    }
    return self;
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

- (BOOL)becomeFirstResponder
{
    return [_inputTextView becomeFirstResponder];
}

- (BOOL)isFirstResponder
{
    return [_inputTextView isFirstResponder];
}

- (BOOL)resignFirstResponder
{
    if ([self isFirstResponder]) {
        return [_inputTextView resignFirstResponder];
    }else{
        [self hideMoreViewOrExpressionView];
    }
    
    return YES;
}

- (void)setPanGestureRecognizer:(UIPanGestureRecognizer *)panGestureRecognizer
{
    _panGestureRecognizer = panGestureRecognizer;
    [_panGestureRecognizer addTarget:self action:@selector(resignFirstResponder)];
}
#pragma mark - properties 

- (LTZMoreInputView *)moreInputView
{
    if (!_moreInputView) {
        _moreInputView = ({
            
            LTZMoreInputView *moreInputView = [[LTZMoreInputView alloc] initWithFrame:CGRectMake(0, self.frame.size.height, self.frame.size.width, DEFAULT_KEYBOARD_HEIGHT)];
            
            moreInputView.image = [[UIImage imageNamed:@"chat_more_bg"] resizableImageWithCapInsets:UIEdgeInsetsMake(20.0f, 20.0f, 20.0f, 20.0f)
                                                                                        resizingMode:UIImageResizingModeStretch];
             
            moreInputView.userInteractionEnabled = YES;
            [self addSubview:moreInputView];
            moreInputView;
        });
    }
    
    return _moreInputView;
}

- (LTZExpressionInputView *)expressionInputView
{
    if (!_expressionInputView) {
        _expressionInputView = ({
            LTZExpressionInputView *expressionInputView = [[LTZExpressionInputView alloc] initWithFrame:CGRectMake(0, self.frame.size.height, self.frame.size.width, DEFAULT_KEYBOARD_HEIGHT)];
            
            expressionInputView.image = [[UIImage imageNamed:@"chat_more_bg"] resizableImageWithCapInsets:UIEdgeInsetsMake(20.0f, 20.0f, 20.0f, 20.0f)
                                                                                             resizingMode:UIImageResizingModeStretch];
             
            
            expressionInputView.userInteractionEnabled = YES;
            [self addSubview:expressionInputView];
            expressionInputView;
        });
    }
    
    return _expressionInputView;
}

- (CGRect)defaultFrame
{
    return CGRectMake(self.originFrame.origin.x, self.originFrame.origin.y - DEFAULT_KEYBOARD_HEIGHT, self.originFrame.size.width, self.originFrame.size.height);
}

- (void)setIsMoreViewShowing:(BOOL)isMoreViewShowing
{
    _isMoreViewShowing = isMoreViewShowing;
    [_moreButton setBackgroundImage:[UIImage imageNamed:(isMoreViewShowing ? @"chat_input_keyboard_button":@"chat_input_action_button")] forState:UIControlStateNormal];
    
    if (isMoreViewShowing) {
        [self bringSubviewToFront:self.moreInputView];
    }
}

- (void)setIsExpressionViewShowing:(BOOL)isExpressionViewShowing
{
    _isExpressionViewShowing = isExpressionViewShowing;
    [_expressionButton setBackgroundImage:[UIImage imageNamed:(isExpressionViewShowing ? @"chat_input_keyboard_button":@"chat_input_emo_button")] forState:UIControlStateNormal];
    
    if (isExpressionViewShowing) {
        [self bringSubviewToFront:self.expressionInputView];
    }
}

- (void)setIsRecordViewShowing:(BOOL)isRecordViewShowing
{
    _isRecordViewShowing = isRecordViewShowing;
    [_voiceButton setBackgroundImage:[UIImage imageNamed:(isRecordViewShowing ? @"chat_input_keyboard_button":@"chat_input_voice_button")] forState:UIControlStateNormal];
    
    [_inputTextView setHidden:isRecordViewShowing];
    [_recordButton setHidden:!isRecordViewShowing];
    
    
    if (isRecordViewShowing && [self isFirstResponder]) {
        [self resignFirstResponder];
    }
}

- (void)prepareToRecord
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
    [UIView setAnimationDuration:DEFAULT_ANIMATION_DURATION];
    [UIView setAnimationCurve:(UIViewAnimationCurve)DEFAULT_ANIMATION_CURVE];
    
    
    
    //    // for ipad modal form presentations
    //    CGFloat messageViewFrameBottom = self.contextView.frame.size.height - self.frame.size.height;
    //
    //    if(inputViewFrameY > messageViewFrameBottom) inputViewFrameY = messageViewFrameBottom;
    
    self.frame = self.defaultFrame;
    
    // end animation action
    [UIView commitAnimations];
}

- (void)hideMoreViewOrExpressionView
{
    if (self.isMoreViewShowing || self.isExpressionViewShowing){
        
        [UIView beginAnimations:nil context:NULL];
        [UIView setAnimationDuration:DEFAULT_ANIMATION_DURATION];
        [UIView setAnimationCurve:(UIViewAnimationCurve)DEFAULT_ANIMATION_CURVE];
        
        
        
        //    // for ipad modal form presentations
        //    CGFloat messageViewFrameBottom = self.contextView.frame.size.height - self.frame.size.height;
        //
        //    if(inputViewFrameY > messageViewFrameBottom) inputViewFrameY = messageViewFrameBottom;
        
        self.frame = self.originFrame;
        
        if (self.isMoreViewShowing) {
            self.isMoreViewShowing = NO;
        }
        
        if (self.isExpressionViewShowing) {
            self.isExpressionViewShowing = NO;
        }
        
        
        // end animation action
        [UIView commitAnimations];
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
            CGFloat keyboardY = [self.contextView convertRect:keyboardRect fromView:nil].origin.y;
            
            CGRect inputViewFrame = self.frame;
            CGFloat inputViewFrameY = keyboardY - inputViewFrame.size.height;
            
            // for ipad modal form presentations
            CGFloat messageViewFrameBottom = self.contextView.frame.size.height - self.frame.size.height;
            
            if(inputViewFrameY > messageViewFrameBottom) inputViewFrameY = messageViewFrameBottom;
            
            self.frame = CGRectMake(inputViewFrame.origin.x,
                                    inputViewFrameY,
                                    inputViewFrame.size.width,
                                    inputViewFrame.size.height);
            if ([notification.name isEqualToString:UIKeyboardWillShowNotification]) {
                [self setScrollViewInsetsWithBottomValue:(self.contextView.frame.size.height - self.frame.origin.y - self.frame.size.height + _inputTextView.bounds.size.height-_recordButton.bounds.size.height)];
            }else if ([notification.name isEqualToString:UIKeyboardWillHideNotification] && self.isRecordViewShowing){
                [self setScrollViewInsetsWithBottomValue:(self.contextView.frame.size.height - self.frame.origin.y - self.frame.size.height)];
            }else if ([notification.name isEqualToString:UIKeyboardWillHideNotification] && !self.isRecordViewShowing) {
                [self setScrollViewInsetsWithBottomValue:(self.contextView.frame.size.height - self.frame.origin.y - self.frame.size.height + _inputTextView.bounds.size.height-_recordButton.bounds.size.height)];
            }
        }
        
        // end animation action
        [UIView commitAnimations];
    }/*
    else if ([notification.name isEqualToString:UIKeyboardWillHideNotification]) {
        [self hideMoreViewOrExpressionView];
    }else if ([notification.name isEqualToString:UIKeyboardWillShowNotification]){
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
            CGRect newFrame = self.frame;
            CGFloat newFrameY = self.originFrame.origin.y - keyboardRect.size.height;
            newFrame.origin.y = newFrameY;
            
            self.frame = newFrame;
            /*
            // for ipad modal form presentations
            CGFloat messageViewFrameBottom = self.contextView.frame.size.height - self.frame.size.height;
            
            if(inputViewFrameY > messageViewFrameBottom) inputViewFrameY = messageViewFrameBottom;
            
            self.frame = CGRectMake(inputViewFrame.origin.x,
                                    inputViewFrameY,
                                    inputViewFrame.size.width,
                                    inputViewFrame.size.height);
            if ([notification.name isEqualToString:UIKeyboardWillShowNotification]) {
                [self setScrollViewInsetsWithBottomValue:(self.contextView.frame.size.height - self.frame.origin.y - self.frame.size.height + _inputTextView.bounds.size.height-_recordButton.bounds.size.height)];
            }else if ([notification.name isEqualToString:UIKeyboardWillHideNotification] && self.isRecordViewShowing){
                [self setScrollViewInsetsWithBottomValue:(self.contextView.frame.size.height - self.frame.origin.y - self.frame.size.height)];
            }else if ([notification.name isEqualToString:UIKeyboardWillHideNotification] && !self.isRecordViewShowing) {
                [self setScrollViewInsetsWithBottomValue:(self.contextView.frame.size.height - self.frame.origin.y - self.frame.size.height + _inputTextView.bounds.size.height-_recordButton.bounds.size.height)];
            }
      
        }
        
        // end animation action
        [UIView commitAnimations];
    }*/
}

- (void)voiceButtonCliked:(id)sender
{
    if (!self.isRecordViewShowing) {
        
        if (![self isFirstResponder]) {
            [self hideMoreViewOrExpressionView];
        }
        
        [self prepareToRecord];
        
    }else{
        
        [self prepareToInputText];
    }
    /*
    self.isRecordViewShowing = !self.isRecordViewShowing;
    
    CGFloat height = _inputTextView.bounds.size.height - _recordBtn.bounds.size.height;
    CGRect newFrame = self.frame;
    if (!self.isInputViewShowing) {
        
        newFrame.origin.y += height;
        newFrame.size.height -= height;
        
    }else{
    
        newFrame.origin.y -= height;
        newFrame.size.height += height;
        height = -height;
    }
    
    self.frame = newFrame;
    [self updateScrollViewCurrentInsetsWithValue:height];
     */
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

#pragma mark - private methods
- (void)_initData
{
    self.isKeyboardShowing = NO;
    self.originFrame = self.frame;
    
    self.isRecordViewShowing = NO;
    self.isExpressionViewShowing = NO;
    self.isMoreViewShowing = NO;
}

- (void)dealloc
{
    _scrollView = nil;
    _contextView = nil;
    _panGestureRecognizer = nil;
    _recordButton = nil;
    _voiceButton = nil;
    _expressionButton = nil;
    _moreButton = nil;
    _delegate = nil;
    [self endListeningForKeyboard];
}

- (void)_setupViews
{
    self.userInteractionEnabled = YES;
    self.image = [[UIImage imageNamed:@"chat_input_bg"] resizableImageWithCapInsets:UIEdgeInsetsMake(2.0f, 0.0f, 0.0f, 0.0f)
                                                                        resizingMode:UIImageResizingModeStretch];
    self.expressionInputView.frame = CGRectMake(0, self.frame.size.height, self.frame.size.width, DEFAULT_KEYBOARD_HEIGHT);
    self.moreInputView.frame = CGRectMake(0, self.frame.size.height, self.frame.size.width, DEFAULT_KEYBOARD_HEIGHT);
    
    _voiceButton = ({
        UIButton *button = [UIButton buttonWithType:UIButtonTypeCustom];
        button.frame = CGRectMake(DEFAULT_MAGIN_WIDTH, DEFAULT_MAGIN_HEIGHT, DEFAULT_BUTTON_WITDH, DEFAULT_BUTTON_HEIGHT);
        button.autoresizingMask = UIViewAutoresizingFlexibleTopMargin;
        [button setBackgroundImage:[UIImage imageNamed:@"chat_input_voice_button"] forState:UIControlStateNormal];
        [button addTarget:self action:@selector(voiceButtonCliked:) forControlEvents:UIControlEventTouchUpInside];
        [self addSubview:button];
        button;
    });
    
    _inputTextView = ({
        HPGrowingTextView *textView = [[HPGrowingTextView alloc] initWithFrame:CGRectMake(2*DEFAULT_MAGIN_WIDTH + DEFAULT_BUTTON_WITDH, DEFAULT_MAGIN_HEIGHT, DEFAULT_TEXT_VIEW_WIDTH, DEFAULT_TEXT_VIEW_HEIGHT)];
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
        textView.placeholder = @"send new message...";
        textView.autoresizingMask = UIViewAutoresizingFlexibleWidth;
    
        // textView.text = @"test\n\ntest";
        // textView.animateHeightChange = NO; //turns off animation
        
        CGFloat cornerRadius = 6.0f;
        textView.backgroundColor = [UIColor whiteColor];
        textView.layer.borderWidth = 0.5f;
        textView.layer.borderColor = [UIColor colorWithWhite:0.8f alpha:1.0f].CGColor;
        textView.layer.cornerRadius = cornerRadius;
        
        textView;
    });
    
    _recordButton = ({
        UIButton *button = [UIButton buttonWithType:UIButtonTypeCustom];
        button.frame = CGRectMake(2*DEFAULT_MAGIN_WIDTH + DEFAULT_BUTTON_WITDH, DEFAULT_MAGIN_HEIGHT, DEFAULT_TEXT_VIEW_WIDTH, DEFAULT_TEXT_VIEW_HEIGHT);
        button.autoresizingMask = UIViewAutoresizingFlexibleTopMargin;
        [button setBackgroundImage:[[UIImage imageNamed:@"chat_record_bg"] stretchableImageWithLeftCapWidth:10 topCapHeight:10] forState:UIControlStateNormal];
        [button setBackgroundImage:[[UIImage imageNamed:@"chat_record_selected_bg"] stretchableImageWithLeftCapWidth:10 topCapHeight:10] forState:UIControlStateHighlighted];
        [button setTitle:@"按住\t对讲" forState:UIControlStateNormal];
        [button setTitle:@"松开\t完成" forState:UIControlStateHighlighted];
        [button setTitleColor:[UIColor darkGrayColor] forState:UIControlStateNormal];
        [button setTitleColor:[UIColor whiteColor] forState:UIControlStateHighlighted];
        [self addSubview:button];
        button;
    });
    
    _expressionButton = ({
        UIButton *button = [UIButton buttonWithType:UIButtonTypeCustom];
        button.frame = CGRectMake(3*DEFAULT_MAGIN_WIDTH+DEFAULT_BUTTON_WITDH+DEFAULT_TEXT_VIEW_WIDTH, DEFAULT_MAGIN_HEIGHT, DEFAULT_BUTTON_WITDH, DEFAULT_BUTTON_HEIGHT);
        button.autoresizingMask = UIViewAutoresizingFlexibleTopMargin;
        [button setBackgroundImage:[UIImage imageNamed:@"chat_input_emo_button"] forState:UIControlStateNormal];
        [button addTarget:self action:@selector(expressionButtonCliked:) forControlEvents:UIControlEventTouchUpInside];
        [self addSubview:button];
        button;
    });
    
    _moreButton = ({
        UIButton *button = [UIButton buttonWithType:UIButtonTypeCustom];
        button.frame = CGRectMake(4*DEFAULT_MAGIN_WIDTH+2*DEFAULT_BUTTON_WITDH+DEFAULT_TEXT_VIEW_WIDTH, DEFAULT_MAGIN_HEIGHT, DEFAULT_BUTTON_WITDH, DEFAULT_BUTTON_HEIGHT);
        button.autoresizingMask = UIViewAutoresizingFlexibleTopMargin;
        [button setBackgroundImage:[UIImage imageNamed:@"chat_input_action_button"] forState:UIControlStateNormal];
        [button addTarget:self action:@selector(moreButtonCliked:) forControlEvents:UIControlEventTouchUpInside];
        [self addSubview:button];
        button;
    });
    
    [_recordButton setHidden:YES];
    //[_inputTextView setHidden:YES];
    [self addSubview:_inputTextView];
    /*
     NSMutableArray *Constraints = [NSMutableArray array];
     
     [Constraints addObjectsFromArray:[NSLayoutConstraint constraintsWithVisualFormat:@"H:|-MARGIN1-[_inputTextView]-MARGIN1-|" options:0 metrics:@{@"MARGIN1":[NSNumber numberWithFloat:DEFAULT_MAGIN_WIDTH]} views:NSDictionaryOfVariableBindings(_inputTextView)]];
     
     [Constraints addObjectsFromArray:[NSLayoutConstraint constraintsWithVisualFormat:@"V:|-MARGIN1-[_inputTextView]-MARGIN1-|" options:0 metrics:@{@"MARGIN1":[NSNumber numberWithFloat:DEFAULT_MAGIN_HEIGHT]} views:NSDictionaryOfVariableBindings(_inputTextView)]];
     
     [self addConstraints:Constraints];
     */
    
}

- (void)updateScrollViewCurrentInsetsWithValue:(CGFloat)value
{
    UIEdgeInsets insets = self.scrollView.contentInset;
    insets.bottom -= value;
    self.scrollView.contentInset = insets;
    self.scrollView.scrollIndicatorInsets = insets;
}

- (void)setScrollViewInsetsWithBottomValue:(CGFloat)bottom
{
    UIEdgeInsets insets = [self scrollViewInsetsWithBottomValue:bottom];
    self.scrollView.contentInset = insets;
    self.scrollView.scrollIndicatorInsets = insets;
}

- (UIEdgeInsets)scrollViewInsetsWithBottomValue:(CGFloat)bottom
{
    UIEdgeInsets insets = UIEdgeInsetsZero;
    //根据自己的布局情况确定上边要缩进的值
    if ([self respondsToSelector:@selector(topLayoutGuide)]) {
        insets.top = 64;
    }
    
    insets.bottom = bottom;
    
    return insets;
}

#pragma mark - HPGrowingTextViewDelegate methods
- (void)growingTextView:(HPGrowingTextView *)growingTextView willChangeHeight:(float)height
{
    float changedHeight = (growingTextView.frame.size.height - height);
    
    CGRect newFrame = self.frame;
    newFrame.size.height -= changedHeight;
    newFrame.origin.y += changedHeight;
    self.frame = newFrame;
    self.originFrame = CGRectMake(self.originFrame.origin.x, self.originFrame.origin.y - changedHeight, self.originFrame.size.width, self.originFrame.size.height + changedHeight);
    
    self.expressionInputView.frame = CGRectMake(0, self.frame.size.height, self.frame.size.width, DEFAULT_KEYBOARD_HEIGHT);
    self.moreInputView.frame = CGRectMake(0, self.frame.size.height, self.frame.size.width, DEFAULT_KEYBOARD_HEIGHT);
    
    [self updateScrollViewCurrentInsetsWithValue:changedHeight];
}

- (BOOL)growingTextView:(HPGrowingTextView *)growingTextView shouldChangeTextInRange:(NSRange)range replacementText:(NSString *)text
{
    
    if ([text isEqualToString:@"\n"])
    {
        NSString * content = growingTextView.text;
        if (content.length == 0 || [content isEqualToString:@""]){
            NSLog(@"请输入内容");
        }
        else {
            if (self.delegate && [self.delegate respondsToSelector:@selector(ltzInputToolBar:didSentTextContent:)]) {
                [self.delegate ltzInputToolBar:self didSentTextContent:content];
            }
            
            growingTextView.text = @"";
        }
        return NO;
    }
    return YES;
}


/*
// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect
{
    // Drawing code
}
*/

@end
