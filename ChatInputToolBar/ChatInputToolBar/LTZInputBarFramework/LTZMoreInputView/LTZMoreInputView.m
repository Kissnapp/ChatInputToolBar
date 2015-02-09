//
//  LTZMoreInputView.m
//  ChatInputToolBar
//
//  Created by Peter Lee on 15/2/2.
//  Copyright (c) 2015年 Peter Lee. All rights reserved.
//

#import "LTZMoreInputView.h"
#import "LTZMoreInputItem.h"
#import "LTZMoreInputItemView.h"
#import "LTZInputToolBarConstraints.h"

#define DEFAULT_MORE_INPUT_VIEW self.frame.size.width 

#define MARGIN_HEIGHT 10.0f
#define MARGIN_WIDTH MARGIN_HEIGHT
#define MARGIN_WIDTH_BETWEEN_BUTTONS (DEFAULT_MORE_INPUT_VIEW - 2*MARGIN_HEIGHT - (LTZInputToolBarDefaultMutableViewColumns - 1))

#define DEFAULT_PAGE_CONTROL_HEIGHT 15.0f
#define DEFAULT_SCROLL_VIEW_HEIGHT (LTZInputToolBarDefaultKetboardHeight - 3*MARGIN_HEIGHT - DEFAULT_PAGE_CONTROL_HEIGHT)

@interface LTZMoreInputView ()<UIScrollViewDelegate>
{
    NSUInteger      _itemCount;
    BOOL            _hasMorePage;
}

@property (nonatomic, strong) UIScrollView    *scrollView;
@property (nonatomic, strong) UIPageControl   *pageControl;

@end

@implementation LTZMoreInputView
@synthesize scrollView = _scrollView;
@synthesize pageControl = _pageControl;

- (instancetype)initWithFrame:(CGRect)frame 
{
    return [self initWithFrame:frame
                publicDelegate:nil
               privateDelegate:nil
                    dataSource:nil];
}

- (instancetype)initWithFrame:(CGRect)frame
               publicDelegate:(id <LTZMoreInputViewPublicDelegate>)publicDelegate
              privateDelegate:(id <LTZMoreInputViewPrivateDelegate>)privateDelegate
                   dataSource:(id <LTZMoreInputViewDataSource>) dataSource
{
    self = [super initWithFrame:frame];
    if (self) {
        self.publicDelegate = publicDelegate;
        self.privateDelegate = privateDelegate;
        self.dataSource = dataSource;
        [self initData];
        [self setupViews];
    }
    return self;
}


- (void)initData
{
    _itemCount = 0;
    _hasMorePage = NO;
    
    if (self.dataSource && [self.dataSource respondsToSelector:@selector(numberOfItemsShowInLTZMoreInputView:)]) {
        
        _itemCount = [self.dataSource numberOfItemsShowInLTZMoreInputView:self];
        
        _hasMorePage = (_itemCount > (LTZInputToolBarDefaultMutableViewRows * LTZInputToolBarDefaultMutableViewColumns)) ? :NO;
    }
}

- (void)setupViews
{
    self.autoresizingMask = UIViewAutoresizingFlexibleWidth;
    self.image = [[UIImage imageNamed:@"chat_more_bg"] resizableImageWithCapInsets:UIEdgeInsetsMake(20.0f, 20.0f, 20.0f, 20.0f)
                                                                      resizingMode:UIImageResizingModeStretch];
    [self updateScrollViewAndPageControlWithItemCount:_itemCount];
    
    //Add item views below...
    
    for (NSInteger index = 0; index < _itemCount; ++index) {
        if (self.dataSource && [self.dataSource respondsToSelector:@selector(ltzMoreInputView:moreInputViewItemShowAtIndex:)]) {
            LTZMoreInputItem *item = [self.dataSource ltzMoreInputView:self moreInputViewItemShowAtIndex:index];
            LTZMoreInputItemView *itemView = [[LTZMoreInputItemView alloc] initWithFrame:<#(CGRect)#> ltzMoreInputItem:item];
            itemView addTag:index target:self action:@selector(<#selector#>) forControlEvents:<#(UIControlEvents)#>
            if (_hasMorePage) {
                
                [_scrollView addSubview:itemView];
            }
        }
    }
    
}

- (void)clikedOnButton:(id)sender
{
    UIButton *btn = (UIButton *)sender;
    
    [self selectedItemAtIndex:btn.tag];
}

- (void)selectedItemAtIndex:(NSUInteger)index
{
    if (self.publicDelegate && [self.publicDelegate respondsToSelector:@selector(ltzMoreInputView:didSelecteMoreInputViewItemAtIndex:)]) {
        [self.publicDelegate ltzMoreInputView:self didSelecteMoreInputViewItemAtIndex:index];
    }
}

- (void)reloadData
{
    if (self.dataSource && [self.dataSource respondsToSelector:@selector(numberOfItemsShowInLTZMoreInputView:)]) {
        _itemCount = [self.dataSource numberOfItemsShowInLTZMoreInputView:self];
        _hasMorePage = (_itemCount > (LTZInputToolBarDefaultMutableViewRows * LTZInputToolBarDefaultMutableViewColumns)) ? :NO;
    }
    
    [self updateScrollViewAndPageControlWithItemCount:_itemCount];
}

- (void)updateScrollViewAndPageControlWithItemCount:(NSUInteger)count
{
    if (count <= (LTZInputToolBarDefaultMutableViewRows * LTZInputToolBarDefaultMutableViewColumns)) {
        
        if (self.scrollView) {
            [self.scrollView.subviews makeObjectsPerformSelector:@selector(removeFromSuperview)];
            [self.scrollView removeFromSuperview];
        }
        
        if (self.pageControl) {
            [self.pageControl removeFromSuperview];
        }
        
        return;
    }else{
        if (!self.scrollView) {
            
            _scrollView = ({
                UIScrollView *scrollView = [[UIScrollView alloc] initWithFrame:CGRectMake(0, MARGIN_HEIGHT, DEFAULT_MORE_INPUT_VIEW, LTZInputToolBarDefaultKetboardHeight - 3*MARGIN_HEIGHT - DEFAULT_PAGE_CONTROL_HEIGHT)];
                scrollView.delegate = self;
                scrollView.canCancelContentTouches = NO;
                scrollView.delaysContentTouches = YES;
                scrollView.backgroundColor = [UIColor clearColor];
                scrollView.showsHorizontalScrollIndicator = NO;
                scrollView.showsVerticalScrollIndicator = NO;
                [scrollView setScrollsToTop:NO];
                scrollView.pagingEnabled = YES;
                
                [self addSubview:scrollView];
                
                scrollView;
            });
        }
        
        if (!self.pageControl) {
            _pageControl = ({
                UIPageControl *pageControl = [[UIPageControl alloc] initWithFrame:CGRectMake(0, MARGIN_HEIGHT + _scrollView.frame.size.height, DEFAULT_MORE_INPUT_VIEW, DEFAULT_PAGE_CONTROL_HEIGHT)];
                pageControl.backgroundColor = [UIColor clearColor];
                pageControl.hidesForSinglePage = YES;
                pageControl.defersCurrentPageDisplay = YES;
                pageControl.currentPageIndicatorTintColor = [UIColor darkGrayColor];
                pageControl.pageIndicatorTintColor = [UIColor lightGrayColor];
                
                [self addSubview:pageControl];
                pageControl;
            });
        }
        //调整contentSize大小
        //调整pageControl的数量
        self.pageControl.numberOfPages = floor(count / (LTZInputToolBarDefaultMutableViewRows * LTZInputToolBarDefaultMutableViewColumns)) + 1;
        [self.scrollView setContentSize:CGSizeMake(DEFAULT_MORE_INPUT_VIEW * self.pageControl.numberOfPages, DEFAULT_SCROLL_VIEW_HEIGHT)];
    }
}

- (void)willMoveToSuperview:(UIView *)newSuperview
{
    if (newSuperview) {
        [self reloadData];
    }
}

- (void)dealloc
{
    _scrollView = nil;
    _pageControl = nil;
}

#pragma mark - UIScrollViewDelegate methods
- (void)scrollViewDidEndDecelerating:(UIScrollView *)scrollView
{
    //the width of one page
    CGFloat pageWidth = DEFAULT_MORE_INPUT_VIEW;
    
    //get the current page number
    NSInteger currentPage = floor((scrollView.contentOffset.x - pageWidth)/pageWidth) + 1;
    [_pageControl setCurrentPage:currentPage];
}


/*
static inline UIView *currentView(UIView *view, UIScrollView *scrollView, BOOL hasMoreItems)
{

}*/
                                                                                                                                                                                     
@end
