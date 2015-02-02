//
//  LTZExpressionInputView.m
//  ChatInputToolBar
//
//  Created by Peter Lee on 15/2/2.
//  Copyright (c) 2015年 Peter Lee. All rights reserved.
//

#import "LTZExpressionInputView.h"

@implementation LTZExpressionInputView

- (instancetype)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        UILabel *label = [[UILabel alloc] initWithFrame:CGRectMake(20, 20, 100, 40)];
        label.text = @"1.这是表情视图";
        [self addSubview:label];
    }
    return self;
}

@end
