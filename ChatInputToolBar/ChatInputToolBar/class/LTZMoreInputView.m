//
//  LTZMoreInputView.m
//  ChatInputToolBar
//
//  Created by Peter Lee on 15/2/2.
//  Copyright (c) 2015年 Peter Lee. All rights reserved.
//

#import "LTZMoreInputView.h"

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
                                                                                                                                                                                     
@end
