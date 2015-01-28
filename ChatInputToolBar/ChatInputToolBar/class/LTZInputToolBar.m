//
//  LTZInputToolBar.m
//  LTZInputToolBar
//
//  Created by Peter Lee on 15/1/16.
//  Copyright (c) 2015年 Peter Lee. All rights reserved.
//

#import "LTZInputToolBar.h"
#import "HPGrowingTextView.h"

#define DEFAULT_MAGIN_WIDTH 8.0f
#define DEFAULT_MAGIN_HEIGHT DEFAULT_MAGIN_WIDTH

#define DEFAULT_BUTTON_HEIGHT 25.0f
#define DEFAULT_BUTTON_WITDH DEFAULT_BUTTON_HEIGHT

#define DEFAULT_TEXT_VIEW_WIDTH (self.frame.size.width - 5*DEFAULT_MAGIN_WIDTH - 3*DEFAULT_MAGIN_WIDTH)
#define DEFAULT_TEXT_VIEW_HEIGHT (self.frame.size.height - 2*DEFAULT_MAGIN_HEIGHT)

#define DEFAULT_TALK_BUTTON_WIDTH 80.0f
#define DEFAULT_TALK_BUTTON_HEIGHT DEFAULT_TALK_BUTTON_WIDTH

@interface LTZInputToolBar ()<UITextViewDelegate, HPGrowingTextViewDelegate>
{
    UIButton                *_voiceSwitchBtn;
    UIButton                *_expressionSwitchBtn;
    UIButton                *_moreSwitchBtn;
    HPGrowingTextView       *_inputTextView;
    
    UIView                  *_contextView;
    UIScrollView            *_scrollView;
    
    BOOL _isObserving;
    
    UIView *_keyboardView;
    
}

@end

@implementation LTZInputToolBar

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

- (void)resignFirstResponder
{
    [_inputTextView resignFirstResponder];
}

- (void)setPanGestureRecognizer:(UIPanGestureRecognizer *)panGestureRecognizer
{
    _panGestureRecognizer = panGestureRecognizer;
    [_panGestureRecognizer addTarget:self action:@selector(resignFirstResponder)];
}

#pragma mark - 监听键盘的显示与隐藏
-(void)inputKeyboardWillShow:(NSNotification *)notification
{
    [self keyboardWillShowHide:notification];
}
-(void)inputKeyboardWillHide:(NSNotification *)notification
{
    [self keyboardWillShowHide:notification];
}

- (void)keyboardWillShowHide:(NSNotification *)notification
{
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
        [self setScrollViewInsetsWithBottomValue:(self.contextView.frame.size.height - self.frame.origin.y - self.frame.size.height)];
    }
    
    // end animation action
    [UIView commitAnimations];
}

#pragma mark - private methods
- (void)dealloc
{
    _scrollView = nil;
    _contextView = nil;
    _panGestureRecognizer = nil;
    _delegate = nil;
    [self endListeningForKeyboard];
    [_panGestureRecognizer removeTarget:self action:@selector(dismissKeyboard:)];
}

- (void)_setupViews
{
    self.userInteractionEnabled = YES;
    self.backgroundColor = [UIColor redColor];
    
    _inputTextView = ({
        HPGrowingTextView *textView = [[HPGrowingTextView alloc] initWithFrame:CGRectMake(6, 4, 240, 36)];
        textView.isScrollable = NO;
        textView.contentInset = UIEdgeInsetsMake(0, 5, 0, 5);
        
        textView.minNumberOfLines = 1;
        textView.maxNumberOfLines = 5;
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
        
        textView;
    });;
    
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
    float diff = (growingTextView.frame.size.height - height);
    
    CGRect r = self.frame;
    r.size.height -= diff;
    r.origin.y += diff;
    self.frame = r;
    
    [self updateScrollViewCurrentInsetsWithValue:diff];
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
