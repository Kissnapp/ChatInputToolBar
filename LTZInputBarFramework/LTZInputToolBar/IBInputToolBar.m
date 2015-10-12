//
//  LTZInputToolBar.m
//  LTZInputToolBar
//
//  Created by Peter Lee on 15/1/16.
//  Copyright (c) 2015年 Peter Lee. All rights reserved.
//

#import "IBInputToolBar.h"
#import "IBInputTool.h"
#import "IBMoreInputView.h"
#import "IBExpressionInputView.h"
#import "IBInputToolBarDelegate.h"
#import "IBInputToolBarConstraints.h"

#define ANIMATION_SHOW_VIEW 1

static void * LTZInputBarFrameKeyValueObservingContext = &LTZInputBarFrameKeyValueObservingContext;

////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
#pragma mark - LTZInputToolBar
////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////

@interface IBInputToolBar ()<UITextViewDelegate, IBInputToolPrivateDelegate>
{
    UIView          __weak       *_contextView;
    UIScrollView    __weak       *_scrollView;
    IBInputTool                  *_inputTool;
}

@property (strong, nonatomic) IBExpressionInputView    *expressionInputView;
@property (strong, nonatomic) IBMoreInputView          *moreInputView;

@property (strong, nonatomic) NSString                  *placeholder;
@property (assign, nonatomic) CGRect                    originFrame;
@property (assign, nonatomic) UIEdgeInsets              scrollViewOriginEdgeInsets;

@end

@implementation IBInputToolBar
@synthesize inputTool       =   _inputTool;
@synthesize contextView     =   _contextView;
@synthesize scrollView      =   _scrollView;

#pragma mark - class methods
+ (CGFloat)IBInputToolDefaultHeight
{
    return [IBInputTool IBInputToolDefaultHeight];
}

+ (CGFloat)IBInputToolBarDefaultHeight
{
    return LTZInputToolBarDefaultHeight;
}

#pragma mark - public methods
- (id)initWithFrame:(CGRect)frame
{
    return [self initWithFrame:frame scrollView:nil inView:nil gestureRecognizer:nil delegate:nil dataSource:nil];
}

- (id)initWithFrame:(CGRect)frame
         scrollView:(UIScrollView *)scrollView
             inView:(UIView *)contextView
  gestureRecognizer:(UIPanGestureRecognizer *)panGestureRecognizer
           delegate:(id<IBInputToolBarDelegate>)delegate
         dataSource:(id<IBInputToolBarDataSource>)dataSource
{
    frame.size.height = LTZInputToolBarDefaultHeight;
    self = [super initWithFrame:frame];
    if (self) {
        _scrollView = scrollView;
        _contextView = contextView;
        _delegate = delegate;
        _dataSource = dataSource;
        _scrollView.keyboardDismissMode = UIScrollViewKeyboardDismissModeInteractive;
        self.panGestureRecognizer = panGestureRecognizer;
        
        // Initialization code
        [self _initData];
        [self _setupViews];
    }
    return self;
}

- (id)initWithFrame:(CGRect)frame
         scrollView:(UIScrollView *)scrollView
             inView:(UIView *)contextView
        placeholder:(NSString *)placeholder
  gestureRecognizer:(UIPanGestureRecognizer *)panGestureRecognizer
           delegate:(id<IBInputToolBarDelegate>)delegate
         dataSource:(id<IBInputToolBarDataSource>)dataSource
{
    frame.size.height = LTZInputToolBarDefaultHeight;
    self = [super initWithFrame:frame];
    if (self) {
        _scrollView = scrollView;
        _contextView = contextView;
        _delegate = delegate;
        _dataSource = dataSource;
        _placeholder = placeholder;
        _scrollView.keyboardDismissMode = UIScrollViewKeyboardDismissModeInteractive;
        self.panGestureRecognizer = panGestureRecognizer;
        
        // init the input tool
        if (!self.inputTool) {
            _inputTool = [[IBInputTool alloc] initWithFrame:CGRectMake(0, 0, self.frame.size.width, [IBInputTool IBInputToolDefaultHeight])
                                                     inView:self
                                                 scrollView:_scrollView
                                                placeholder:self.placeholder
                                           privatedDelegate:self
                                             publicDelegate:self.delegate];
            [self addSubview:_inputTool];
        }

        
        // Initialization code
        [self _initData];
        [self _setupViews];
    }
    return self;
}

- (void)resignFirstResponder
{
    [self.inputTool resignFirstResponder];
}

- (void)setPanGestureRecognizer:(UIPanGestureRecognizer *)panGestureRecognizer
{
    _panGestureRecognizer = panGestureRecognizer;
    [_panGestureRecognizer addTarget:self action:@selector(resignFirstResponder)];
}

- (void)scrollToBottom
{
    if (!self.inputTool) return;
    
    [self.inputTool scrollToBottom];
}


#pragma mark - properties 
- (IBInputTool *)inputTool
{
    return _inputTool;
}

#if ANIMATION_SHOW_VIEW

#else
- (LTZMoreInputView *)moreInputView
{
    if (!_moreInputView) {
        _moreInputView = ({
            
            LTZMoreInputView *moreInputView = [[LTZMoreInputView alloc] initWithFrame:CGRectMake(0, self.frame.size.height, self.frame.size.width, LTZInputToolBarDefaultKetboardHeight) publicDelegate:self.delegate
                                                                      privateDelegate:self
                                                                           dataSource:self.dataSource];
            
            moreInputView.image = [[UIImage imageNamed:LTZInputBarImagePathWithName(@"chat_more_bg")] resizableImageWithCapInsets:UIEdgeInsetsMake(20.0f, 20.0f, 20.0f, 20.0f)
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
            LTZExpressionInputView *expressionInputView = [[LTZExpressionInputView alloc] initWithFrame:CGRectMake(0, self.frame.size.height, self.frame.size.width, LTZInputToolBarDefaultKetboardHeight)];
            
            expressionInputView.image = [[UIImage imageNamed:LTZInputBarImagePathWithName(@"chat_more_bg")] resizableImageWithCapInsets:UIEdgeInsetsMake(20.0f, 20.0f, 20.0f, 20.0f)
                                                                                             resizingMode:UIImageResizingModeStretch];
            
            
            expressionInputView.userInteractionEnabled = YES;
            [self addSubview:expressionInputView];
            expressionInputView;
        });
    }
    
    return _expressionInputView;
}

#endif

#pragma mark - private methods
- (void)_initData
{
    self.originFrame = self.frame;
    self.scrollViewOriginEdgeInsets = self.scrollView.contentInset;
    
    [self addObserver:self
           forKeyPath:NSStringFromSelector(@selector(frame))
              options:(NSKeyValueObservingOptionOld | NSKeyValueObservingOptionNew)
              context:LTZInputBarFrameKeyValueObservingContext];
}

- (void)dealloc
{
    _scrollView = nil;
    _contextView = nil;
    _panGestureRecognizer = nil;
    _inputTool = nil;
    _delegate = nil;
    
    @try {
        [self removeObserver:self
                  forKeyPath:NSStringFromSelector(@selector(frame))
                     context:LTZInputBarFrameKeyValueObservingContext];
    }@catch (NSException * __unused exception) {
    
    }
}

- (void)_setupViews
{
    self.userInteractionEnabled = YES;
    self.image = [[UIImage imageNamed:LTZInputBarImagePathWithName(@"chat_more_bg")] resizableImageWithCapInsets:UIEdgeInsetsMake(20.0f, 20.0f, 20.0f, 20.0f)
                                                                      resizingMode:UIImageResizingModeStretch];
    [self addSubview:self.inputTool];
#if ANIMATION_SHOW_VIEW
    
#else
    self.expressionInputView.frame = CGRectMake(0, self.inputTool.frame.size.height, self.frame.size.width, LTZInputToolBarDefaultKetboardHeight);
    self.moreInputView.frame = CGRectMake(0, self.inputTool.frame.size.height, self.frame.size.width, LTZInputToolBarDefaultKetboardHeight);
#endif
}

- (void)updateScrollViewCurrentInsetsWithValue:(CGFloat)value
{
    UIEdgeInsets insets = self.scrollViewOriginEdgeInsets;
    insets.bottom += value;
    self.scrollView.contentInset = insets;
    self.scrollView.scrollIndicatorInsets = insets;
}

#if ANIMATION_SHOW_VIEW
- (void)showViewAtIndex:(NSUInteger)index
{
    CGRect oldFrame = CGRectMake(0, self.frame.size.height, self.frame.size.width, LTZInputToolBarDefaultKetboardHeight);
    CGRect newFrame = CGRectMake(0, [self.inputTool currentFrameWhenInput].size.height, self.frame.size.width, LTZInputToolBarDefaultKetboardHeight);
    
    void(^animations)() = NULL;
    void(^completion)(BOOL) = NULL;
    
    if (index == 0) {// show the expression view
        
        self.expressionInputView = currentExpressionInputView(self, _expressionInputView);
        self.expressionInputView.frame = oldFrame;
        self.expressionInputView.alpha = 0.0;
        
        [self bringSubviewToFront:self.expressionInputView];
        
        if (self.moreInputView ) {
            self.moreInputView.alpha = 1.0;
        }
        
        animations = ^{
            
            self.expressionInputView.frame = newFrame;
            self.expressionInputView.alpha = 1.0;
            
            if (self.moreInputView && CGRectEqualToRect( self.moreInputView.frame , newFrame)) {
                self.moreInputView.frame = oldFrame;
                self.moreInputView.alpha = 0.0;
            }
            
        };
        
        completion = ^(BOOL finished){
            
        };
        
    }else{//show the more info view
        
        self.moreInputView = currentMoreInputView(self, _moreInputView);
        self.moreInputView.frame = oldFrame;
        self.moreInputView.alpha = 0.0;
        
        [self bringSubviewToFront:self.moreInputView];
        
        if (self.expressionInputView ) {
            self.expressionInputView.hidden = NO;
            self.expressionInputView.alpha = 1.0;
        }
        
        animations = ^{
            
            self.moreInputView.frame = newFrame;
            self.moreInputView.alpha = 1.0;
            
            if (self.expressionInputView && CGRectEqualToRect( self.expressionInputView.frame , newFrame)) {
                self.expressionInputView.frame = oldFrame;
                self.expressionInputView.alpha = 0.0;
            }
            
        };
        
        completion = ^(BOOL finished){
            
        };
        
    }
    
    [UIView animateWithDuration:LTZInputToolBarDefaultAnimationDuration
                          delay:0.0f
                        options:LTZAnimationOptionsForCurve(LTZInputToolBarDefaultAnimationCurve)
                     animations:animations
                     completion:completion];
    
}

#else

#endif

#pragma mark - Key-value observing

- (void)observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary *)change context:(void *)context
{
    if (context == LTZInputBarFrameKeyValueObservingContext) {
        
        if (object == self && [keyPath isEqualToString:NSStringFromSelector(@selector(frame))]) {
            
            CGRect oldKeyboardFrame = [[change objectForKey:NSKeyValueChangeOldKey] CGRectValue];
            CGRect newKeyboardFrame = [[change objectForKey:NSKeyValueChangeNewKey] CGRectValue];
            
            if (CGRectEqualToRect(newKeyboardFrame, oldKeyboardFrame) || CGRectIsNull(newKeyboardFrame)) {
                return;
            }
            
            //  do not convert frame to contextView coordinates here
            //  KVO is triggered during panning (see below)
            //  panning occurs in contextView coordinates already
            CGFloat changedHeight = self.originFrame.origin.y - newKeyboardFrame.origin.y;
#if ANIMATION_SHOW_VIEW
            /*
            if (self.expressionInputView && self.expressionInputView.frame.origin.y != self.frame.size.height) {
                self.expressionInputView.frame = CGRectMake(0, self.inputTool.frame.size.height, self.frame.size.width, LTZInputToolBarDefaultKetboardHeight);
            }
            if (self.moreInputView && self.moreInputView.frame.origin.y != self.frame.size.height) {
                self.moreInputView.frame = CGRectMake(0, self.inputTool.frame.size.height, self.frame.size.width, LTZInputToolBarDefaultKetboardHeight);
            }
            */
#else
            self.expressionInputView.frame = CGRectMake(0, self.inputTool.frame.size.height, self.frame.size.width, LTZInputToolBarDefaultKetboardHeight);
            self.moreInputView.frame = CGRectMake(0, self.inputTool.frame.size.height, self.frame.size.width, LTZInputToolBarDefaultKetboardHeight);
#endif
            [self updateScrollViewCurrentInsetsWithValue:changedHeight];
        }
    }
}


////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
#pragma mark - LTZInputToolPrivateDelegate methods
////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////

- (void)ltzInputToolDidShowRecordView:(IBInputTool *)ltzInputTool
{
#if ANIMATION_SHOW_VIEW
    
#else
    
#endif
}

- (void)ltzInputToolDidShowExpressionView:(IBInputTool *)ltzInputTool
{
#if ANIMATION_SHOW_VIEW
    
    if (ltzInputTool.isMoreViewShowing || ltzInputTool.isExpressionViewShowing) {
        [self showViewAtIndex:0];
    }else{
        CGRect oldFrame = CGRectMake(0, self.frame.size.height, self.frame.size.width, LTZInputToolBarDefaultKetboardHeight);
        CGRect newFrame = CGRectMake(0, [self.inputTool currentFrameWhenInput].size.height, self.frame.size.width, LTZInputToolBarDefaultKetboardHeight);
        
        if ([ltzInputTool.inputTextView isFirstResponder]) {
            self.expressionInputView = currentExpressionInputView(self, _expressionInputView);
            self.expressionInputView.frame = oldFrame;
            self.expressionInputView.alpha = 0.0;
            
            [self bringSubviewToFront:self.expressionInputView];
            self.moreInputView.alpha = 0.0;
            
            void(^animations)() = ^{
                
                self.expressionInputView.frame = newFrame;
                self.expressionInputView.alpha = 1.0;
                
            };
            void(^completion)(BOOL) =^(BOOL finished){
                
            };
            
            [UIView animateWithDuration:LTZInputToolBarDefaultAnimationDuration
                                  delay:0.0f
                                options:LTZAnimationOptionsForCurve(LTZInputToolBarDefaultAnimationCurve)
                             animations:animations
                             completion:completion];
            
        }else{
            self.expressionInputView = currentExpressionInputView(self, _expressionInputView);
            self.expressionInputView.frame = newFrame;
            [self bringSubviewToFront:self.expressionInputView];
            self.expressionInputView.alpha = 1.0;
            self.moreInputView.alpha = 0.0;
        }
    }
#else
    [self bringSubviewToFront:self.expressionInputView];
#endif
}
- (void)ltzInputToolDidShowMoreInfoView:(IBInputTool *)ltzInputTool
{
#if ANIMATION_SHOW_VIEW
    if (ltzInputTool.isMoreViewShowing || ltzInputTool.isExpressionViewShowing) {
        [self showViewAtIndex:1];
    }else{
        CGRect oldFrame = CGRectMake(0, self.frame.size.height, self.frame.size.width, LTZInputToolBarDefaultKetboardHeight);
        CGRect newFrame = CGRectMake(0, [self.inputTool currentFrameWhenInput].size.height, self.frame.size.width, LTZInputToolBarDefaultKetboardHeight);
        
        if ([ltzInputTool.inputTextView isFirstResponder]) {
            self.moreInputView = currentMoreInputView(self, _moreInputView);
            self.moreInputView.frame = oldFrame;
            [self bringSubviewToFront:self.moreInputView];
            self.moreInputView.alpha = 0.0;
            self.expressionInputView.alpha = 0.0;
            
            void(^animations)() = ^{
                
                self.moreInputView.frame = newFrame;
                self.moreInputView.alpha = 1.0;
                
            };
            void(^completion)(BOOL) =^(BOOL finished){
                
            };
            
            [UIView animateWithDuration:LTZInputToolBarDefaultAnimationDuration
                                  delay:0.0f
                                options:LTZAnimationOptionsForCurve(LTZInputToolBarDefaultAnimationCurve)
                             animations:animations
                             completion:completion];

        }else{
            self.moreInputView = currentMoreInputView(self, _moreInputView);
            self.moreInputView.frame = newFrame;
            [self bringSubviewToFront:self.moreInputView];
            self.expressionInputView.alpha = 0.0;
            self.moreInputView.alpha = 1.0;
        }
    }
    
#else
    [self bringSubviewToFront:self.moreInputView];
#endif
}

- (void)ltzInputToolWillBecomeFirstResponder:(IBInputTool *)ltzInputTool
{
    //do something here...
#if ANIMATION_SHOW_VIEW
    
    CGRect oldFrame = CGRectMake(0, self.frame.size.height, self.frame.size.width, LTZInputToolBarDefaultKetboardHeight);
    CGRect newFrame = CGRectMake(0, [self.inputTool currentFrameWhenInput].size.height, self.frame.size.width, LTZInputToolBarDefaultKetboardHeight);
    
    if (self.inputTool.isMoreViewShowing) {
        
        self.moreInputView = currentMoreInputView(self, _moreInputView);
        self.moreInputView.frame = newFrame;
        [self bringSubviewToFront:self.moreInputView];
        self.moreInputView.alpha = 1.0;
        
        if (self.expressionInputView) {
            self.expressionInputView.alpha = 0.0;
        }
        
        void(^animations)() = ^{
            
            self.moreInputView.frame = oldFrame;
            self.moreInputView.alpha = 0.0;
            
            if (self.expressionInputView && CGRectEqualToRect( self.expressionInputView.frame , newFrame)) {
                self.expressionInputView.frame = oldFrame;
                self.expressionInputView.alpha = 0.0;
            }
            
        };
        void(^completion)(BOOL) =^(BOOL finished){
            
        };
        
        [UIView animateWithDuration:LTZInputToolBarDefaultAnimationDuration
                              delay:0.0f
                            options:LTZAnimationOptionsForCurve(LTZInputToolBarDefaultAnimationCurve)
                         animations:animations
                         completion:completion];
        
    }else if (self.inputTool.isExpressionViewShowing) {
        
        self.expressionInputView = currentExpressionInputView(self, _expressionInputView);
        self.expressionInputView.frame = newFrame;
        [self bringSubviewToFront:self.expressionInputView];
        self.expressionInputView.alpha = 1.0;
        
        if (self.moreInputView) {
            self.moreInputView.alpha = 0.0;
        }
        
        void(^animations)() = ^{
            
            self.expressionInputView.frame = oldFrame;
            self.expressionInputView.alpha = 0.0;
            
            if (self.moreInputView && CGRectEqualToRect( self.moreInputView.frame , newFrame)) {
                self.moreInputView.frame = oldFrame;
                self.moreInputView.alpha = 0.0;
            }
        };
        void(^completion)(BOOL) =^(BOOL finished){
            
        };
        
        [UIView animateWithDuration:LTZInputToolBarDefaultAnimationDuration
                              delay:0.0f
                            options:LTZAnimationOptionsForCurve(LTZInputToolBarDefaultAnimationCurve)
                         animations:animations
                         completion:completion];
    }else{
        if (self.moreInputView) {
            self.moreInputView.frame = oldFrame;
            self.moreInputView.alpha = 0.0;
        }
        
        if (self.expressionInputView) {
            self.expressionInputView.frame = oldFrame;
            self.expressionInputView.alpha = 0.0;
        }
    }
#else
#endif
}
- (void)ltzInputToolWillResignFirstResponder:(IBInputTool *)ltzInputTool
{
    //do something here...
}

////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
#pragma mark - inline methods
////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////

#if ANIMATION_SHOW_VIEW
static inline IBMoreInputView *currentMoreInputView(IBInputToolBar *view,IBMoreInputView *moreInputView)
{
    if (!moreInputView) {
        moreInputView = ({
            
            IBMoreInputView *MoreInputView = [[IBMoreInputView alloc] initWithFrame:CGRectMake(0, view.frame.size.height, view.frame.size.width, LTZInputToolBarDefaultKetboardHeight) publicDelegate:view.delegate
                                                                      privateDelegate:view
                                                                           dataSource:view.dataSource];
            [view addSubview:MoreInputView];
            MoreInputView;
        });
    }
    
    return moreInputView;
}

static inline IBExpressionInputView *currentExpressionInputView(IBInputToolBar *view,IBExpressionInputView *expressionInputView)
{
    if (!expressionInputView) {
        expressionInputView = ({
            
            IBExpressionInputView *ExpressionInputView = [[IBExpressionInputView alloc] initWithFrame:CGRectMake(0, view.frame.size.height, view.frame.size.width, LTZInputToolBarDefaultKetboardHeight)];
            
            ExpressionInputView.image = [[UIImage imageNamed:LTZInputBarImagePathWithName(@"chat_more_bg")] resizableImageWithCapInsets:UIEdgeInsetsMake(20.0f, 20.0f, 20.0f, 20.0f)
                                                                                             resizingMode:UIImageResizingModeStretch];
            
            ExpressionInputView.userInteractionEnabled = YES;
            [view addSubview:ExpressionInputView];
            ExpressionInputView;
        });
    }
    
    return expressionInputView;
}

static inline UIViewAnimationOptions LTZAnimationOptionsForCurve(UIViewAnimationCurve curve) {
    return (curve << 16 | UIViewAnimationOptionBeginFromCurrentState);
}

#else

#endif




/*
// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect
{
    // Drawing code
}
*/

@end
