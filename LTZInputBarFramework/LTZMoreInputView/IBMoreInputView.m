//
//  LTZMoreInputView.m
//  ChatInputToolBar
//
//  Created by Peter Lee on 15/2/2.
//  Copyright (c) 2015年 Peter Lee. All rights reserved.
//

#import "IBMoreInputView.h"
#import "IBMoreInputItem.h"
#import "IBMoreInputItemView.h"
#import "IBInputToolBarConstraints.h"

#define DEFAULT_MORE_INPUT_VIEW self.frame.size.width 

#define MARGIN_HEIGHT 10.0f
#define MARGIN_WIDTH MARGIN_HEIGHT
#define MARGIN_WIDTH_BETWEEN_BUTTONS ((DEFAULT_MORE_INPUT_VIEW - 2*MARGIN_HEIGHT - LTZInputToolBarDefaultMutableViewColumns* [IBMoreInputItemView defaultWidth])/(LTZInputToolBarDefaultMutableViewColumns - 1))

#define DEFAULT_PAGE_CONTROL_HEIGHT 15.0f
#define DEFAULT_SCROLL_VIEW_HEIGHT (LTZInputToolBarDefaultKetboardHeight - MARGIN_HEIGHT - DEFAULT_PAGE_CONTROL_HEIGHT)

@interface IBMoreInputView ()<UIScrollViewDelegate>
{
    NSUInteger      _itemCount;
    BOOL            _hasMorePage;
}

@property (nonatomic, strong) UIScrollView    *scrollView;
@property (nonatomic, strong) UIPageControl   *pageControl;

@end

@implementation IBMoreInputView
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
               publicDelegate:(id <IBMoreInputViewPublicDelegate>)publicDelegate
              privateDelegate:(id <IBMoreInputViewPrivateDelegate>)privateDelegate
                   dataSource:(id <IBMoreInputViewDataSource>) dataSource
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
    self.userInteractionEnabled = YES;
    self.image = [[UIImage imageNamed:LTZInputBarImagePathWithName(@"chat_more_bg")] resizableImageWithCapInsets:UIEdgeInsetsMake(20.0f, 20.0f, 20.0f, 20.0f)
                                                                      resizingMode:UIImageResizingModeStretch];
    
    [self reloadData];
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
    //1.If there is a scrollView object ,we should remove all its subviews
    if (self.scrollView) {
        [self.scrollView.subviews makeObjectsPerformSelector:@selector(removeFromSuperview)];
    }
    //2.Then,we should remove all self's subviews
    [self.subviews makeObjectsPerformSelector:@selector(removeFromSuperview)];
    
    //3.Update data source again
    if (self.dataSource && [self.dataSource respondsToSelector:@selector(numberOfItemsShowInLTZMoreInputView:)]) {
        _itemCount = [self.dataSource numberOfItemsShowInLTZMoreInputView:self];
        _hasMorePage = (_itemCount > (LTZInputToolBarDefaultMutableViewRows * LTZInputToolBarDefaultMutableViewColumns)) ? :NO;
    }
    
    [self updateScrollViewAndPageControlWithItemCount:_itemCount];
    
    //Add item views below...
    for (NSInteger index = 0; index < _itemCount; ++index) {
        
        IBMoreInputItem *item = nil;
        //0.This is the view will add on UIScrollView
        IBMoreInputItemView *itemView = nil;
        
        //1.Get the item object form the data source method
        if ([self.dataSource respondsToSelector:@selector(ltzMoreInputView:moreInputViewItemShowAtIndex:)]) {
            
            item = [self.dataSource ltzMoreInputView:self moreInputViewItemShowAtIndex:index];
            
        }else{//2.if we can't get the item object directly, we should make one object form the data source methods
            NSString *imageName = nil;
            NSString *highlightName = nil;
            NSString *title = nil;
            
            //3.Get the value we need to make item object
            if ([self.dataSource respondsToSelector:@selector(ltzMoreInputView:imageNameShowAtIndex:)]) {
                imageName = [self.dataSource ltzMoreInputView:self imageNameShowAtIndex:index];
                highlightName = [self.dataSource ltzMoreInputView:self highlightedImageNameShowAtIndex:index];
                title = [self.dataSource ltzMoreInputView:self titleShowAtIndex:index];
            }
            
            //4.make item object
            item = [[IBMoreInputItem alloc] initWithImageName:imageName highlightName:highlightName title:title];
        }
        
        //5.Init the itemView with the item object we have get
        itemView = [self itemViewWithIndex:index count:_itemCount item:item];
        //6.setting the itemView
        [itemView addTag:index target:self action:@selector(clikedOnButton:) forControlEvents:UIControlEventTouchUpInside];
        
        //7.we will add the itemView on the UIScrollView or self directly
        if (_hasMorePage) {//9.if there is more page views for displaying,we should add this itemView on the UIScrollView
            [_scrollView addSubview:itemView];
        }else{//9.if there is only one page views for displaying,we should add this itemView on self directly
            [self addSubview:itemView];
        }
    }
}

- (IBMoreInputItemView *)itemViewWithIndex:(NSUInteger)index count:(NSUInteger)count item:(IBMoreInputItem *)item
{
    IBMoreInputItemView *itemView = nil;
    
    //0.The complete page the views show(one page will contain count of views is LTZInputToolBarDefaultMutableViewRows * LTZInputToolBarDefaultMutableViewColumns)
    NSUInteger completePageNum = floor(index/(LTZInputToolBarDefaultMutableViewRows * LTZInputToolBarDefaultMutableViewColumns));
    //1.Get the row index with index
    NSUInteger rowNum = floor((index - completePageNum*(LTZInputToolBarDefaultMutableViewRows * LTZInputToolBarDefaultMutableViewColumns))/LTZInputToolBarDefaultMutableViewColumns);
    //2.Get the originX for the view that will been showed
    CGFloat originX = MARGIN_WIDTH + completePageNum*DEFAULT_MORE_INPUT_VIEW + (index - completePageNum*(LTZInputToolBarDefaultMutableViewRows * LTZInputToolBarDefaultMutableViewColumns) - rowNum * LTZInputToolBarDefaultMutableViewColumns)*([IBMoreInputItemView defaultWidth] + MARGIN_WIDTH_BETWEEN_BUTTONS);
    
    //3.Get originY for the view that will been showed
    CGFloat originY = rowNum * ([IBMoreInputItemView defaultHeight] + MARGIN_HEIGHT) + MARGIN_HEIGHT;
    
    //4.Init a LTZMoreInputItemView object for showing
    itemView = [[IBMoreInputItemView alloc] initWithOriginX:originX OriginY:originY ltzMoreInputItem:item];
    
    return itemView;
}

- (void)updateScrollViewAndPageControlWithItemCount:(NSUInteger)count
{
    if (count > (LTZInputToolBarDefaultMutableViewRows * LTZInputToolBarDefaultMutableViewColumns)) {
        
        if (!self.scrollView) {
            
            _scrollView = ({
                UIScrollView *scrollView = [[UIScrollView alloc] initWithFrame:CGRectMake(0, 0, DEFAULT_MORE_INPUT_VIEW, DEFAULT_SCROLL_VIEW_HEIGHT)];
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
        }else{
            [self addSubview:self.scrollView];
        }
        
        if (!self.pageControl) {
            _pageControl = ({
                UIPageControl *pageControl = [[UIPageControl alloc] initWithFrame:CGRectMake(0, DEFAULT_SCROLL_VIEW_HEIGHT, DEFAULT_MORE_INPUT_VIEW, DEFAULT_PAGE_CONTROL_HEIGHT)];
                pageControl.backgroundColor = [UIColor clearColor];
                pageControl.hidesForSinglePage = YES;
                pageControl.defersCurrentPageDisplay = YES;
                pageControl.currentPageIndicatorTintColor = [UIColor darkGrayColor];
                pageControl.pageIndicatorTintColor = [UIColor lightGrayColor];
                
                [self addSubview:pageControl];
                pageControl;
            });
        }else{
            [self addSubview:self.pageControl];
        }
        
        //adjust contentSize
        //set pageControl page number
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
