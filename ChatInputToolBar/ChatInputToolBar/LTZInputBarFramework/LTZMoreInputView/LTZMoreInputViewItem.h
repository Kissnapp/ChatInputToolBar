//
//  LTZMoreInputViewItem.h
//  ChatInputToolBar
//
//  Created by Peter Lee on 15/2/6.
//  Copyright (c) 2015年 Peter Lee. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface LTZMoreInputViewItem : NSObject

@property (nonatomic, strong, readonly) UIImage *image;

@property (nonatomic, copy, readonly) NSString *title;

- (instancetype)initWithImage:(UIImage *)image title:(NSString *)title;
- (void)updateWithImage:(UIImage *)image title:(NSString *)title;
@end
