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
        UILabel *label = [[UILabel alloc] initWithFrame:CGRectMake(0, 0, self.frame.size.width, 40)];
        label.textAlignment = NSTextAlignmentCenter;
        label.text = NSLocalizedStringFromTable(@"expresssion_test_info_title",@"LTZInputBar", nil);
        [self addSubview:label];
    }
    return self;
}

@end
