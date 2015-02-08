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

@interface LTZMoreInputView ()
{
    UIScrollView    *_scrollView;
    UIPageControl   *_pageControl;
}

@end

@implementation LTZMoreInputView

- (instancetype)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        UILabel *label = [[UILabel alloc] initWithFrame:CGRectMake(0, 0, self.frame.size.width, 40)];
        label.backgroundColor = [UIColor yellowColor];
        label.text = @"2.这是更多菜单视图";
        [self addSubview:label];
    }
    return self;
}

- (void)reloadData
{

}
                                                                                                                                                                                     
@end
