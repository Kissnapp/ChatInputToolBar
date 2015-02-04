//
//  LTZInputToolBar.m
//  LTZInputToolBar
//
//  Created by Peter Lee on 15/1/16.
//  Copyright (c) 2015年 Peter Lee. All rights reserved.
//

#import "LTZInputToolBar.h"
#import "LTZInputTool.h"
#import "LTZMoreInputView.h"
#import "LTZExpressionInputView.h"
#import "LTZInputToolBarDelegate.h"
#import "LTZInputToolBarConstraints.h"

static void * LTZInputBarFrameKeyValueObservingContext = &LTZInputBarFrameKeyValueObservingContext;

////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
#pragma mark - LTZInputToolBar
////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////

@interface LTZInputToolBar ()<UITextViewDelegate, LTZInputToolDelegate>
{
    UIView              *_contextView;
    UIScrollView        *_scrollView;
    LTZInputTool        *_inputTool;
}

@property (strong, nonatomic) LTZExpressionInputView    *expressionInputView;
@property (strong, nonatomic) LTZMoreInputView          *moreInputView;

//@property (assign, nonatomic) CGRect                    defaultFrame;
@property (assign, nonatomic) CGRect                    originFrame;
@property (assign, nonatomic) UIEdgeInsets              scrollViewOriginEdgeInsets;

@end

@implementation LTZInputToolBar
@synthesize inputTool       =   _inputTool;
@synthesize contextView     =   _contextView;
@synthesize scrollView      =   _scrollView;

#pragma mark - class methods
+ (CGFloat)LTZInputToolDefaultHeight
{
    return [LTZInputTool LTZInputToolDefaultHeight];
}

+ (CGFloat)LTZInputToolBarDefaultHeight
{
    return LTZInputToolBarDefaultHeight;
}

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
    frame.size.height = LTZInputToolBarDefaultHeight;
    self = [super initWithFrame:frame];
    if (self) {
        _scrollView = scrollView;
        _contextView = contextView;
        _delegate = delegate;
        //_scrollView.keyboardDismissMode = UIScrollViewKeyboardDismissModeInteractive;
        self.panGestureRecognizer = panGestureRecognizer;
        
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
#pragma mark - properties 
- (LTZInputTool *)inputTool
{
    if (!_inputTool) {
        _inputTool = [[LTZInputTool alloc] initWithFrame:CGRectMake(0, 0, self.frame.size.width, [LTZInputTool LTZInputToolDefaultHeight]) inView:self delegate:self];
        [self addSubview:_inputTool];
    }
    
    return _inputTool;
}

- (LTZMoreInputView *)moreInputView
{
    if (!_moreInputView) {
        _moreInputView = ({
            
            LTZMoreInputView *moreInputView = [[LTZMoreInputView alloc] initWithFrame:CGRectMake(0, self.frame.size.height, self.frame.size.width, LTZInputToolBarDefaultKetboardHeight)];
            
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
            LTZExpressionInputView *expressionInputView = [[LTZExpressionInputView alloc] initWithFrame:CGRectMake(0, self.frame.size.height, self.frame.size.width, LTZInputToolBarDefaultKetboardHeight)];
            
            expressionInputView.image = [[UIImage imageNamed:@"chat_more_bg"] resizableImageWithCapInsets:UIEdgeInsetsMake(20.0f, 20.0f, 20.0f, 20.0f)
                                                                                             resizingMode:UIImageResizingModeStretch];
             
            
            expressionInputView.userInteractionEnabled = YES;
            [self addSubview:expressionInputView];
            expressionInputView;
        });
    }
    
    return _expressionInputView;
}
/*
- (CGRect)defaultFrame
{
    return CGRectMake(self.originFrame.origin.x, self.originFrame.origin.y - LTZInputToolBarDefaultKetboardHeight, self.originFrame.size.width, self.originFrame.size.height);
}
*/
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
    self.image = [[UIImage imageNamed:@"chat_more_bg"] resizableImageWithCapInsets:UIEdgeInsetsMake(20.0f, 20.0f, 20.0f, 20.0f)
                                                                      resizingMode:UIImageResizingModeStretch];
    [self addSubview:self.inputTool];
    self.expressionInputView.frame = CGRectMake(0, self.inputTool.frame.size.height, self.frame.size.width, LTZInputToolBarDefaultKetboardHeight);
    self.moreInputView.frame = CGRectMake(0, self.inputTool.frame.size.height, self.frame.size.width, LTZInputToolBarDefaultKetboardHeight);
    
    /*
     NSMutableArray *Constraints = [NSMutableArray array];
     
     [Constraints addObjectsFromArray:[NSLayoutConstraint constraintsWithVisualFormat:@"H:|-MARGIN1-[_inputTextView]-MARGIN1-|" options:0 metrics:@{@"MARGIN1":[NSNumber numberWithFloat:DEFAULT_MAGIN_WIDTH]} views:NSDictionaryOfVariableBindings(_inputTextView)]];
     
     [Constraints addObjectsFromArray:[NSLayoutConstraint constraintsWithVisualFormat:@"V:|-MARGIN1-[_inputTextView]-MARGIN1-|" options:0 metrics:@{@"MARGIN1":[NSNumber numberWithFloat:DEFAULT_MAGIN_HEIGHT]} views:NSDictionaryOfVariableBindings(_inputTextView)]];
     
     [self addConstraints:Constraints];
     */
    
}

- (void)updateScrollViewCurrentInsetsWithValue:(CGFloat)value
{
    UIEdgeInsets insets = self.scrollViewOriginEdgeInsets;
    insets.bottom += value;
    self.scrollView.contentInset = insets;
    self.scrollView.scrollIndicatorInsets = insets;
}

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
            
            self.expressionInputView.frame = CGRectMake(0, self.inputTool.frame.size.height, self.frame.size.width, LTZInputToolBarDefaultKetboardHeight);
            self.moreInputView.frame = CGRectMake(0, self.inputTool.frame.size.height, self.frame.size.width, LTZInputToolBarDefaultKetboardHeight);
            
            [self updateScrollViewCurrentInsetsWithValue:changedHeight];
        }
    }
}


////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
#pragma mark - LTZInputToolDelegate methods
////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
- (void)ltzInputTool:(LTZInputTool *)ltzInputTool didSentTextContent:content
{
    
}

- (void)ltzInputToolDidShowExpressionView:(LTZInputTool *)ltzInputTool
{
    [self bringSubviewToFront:self.expressionInputView];
}
- (void)ltzInputToolDidShowMoreInfoView:(LTZInputTool *)ltzInputTool
{
    [self bringSubviewToFront:self.moreInputView];
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
