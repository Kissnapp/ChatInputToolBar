//
//  LTZMoreInputItemView.h
//  ChatInputToolBar
//
//  Created by  李天柱 on 15/2/8.
//  Copyright (c) 2015年 Peter Lee. All rights reserved.
//

#import <UIKit/UIKit.h>

@class LTZMoreInputItem;

@interface LTZMoreInputItemView : UIView

@property (nonatomic, strong, readonly) UIButton            *imagebutton;
@property (nonatomic, strong, readonly) UILabel             *titleLabel;
@property (nonatomic, strong, readonly) LTZMoreInputItem    *ltzMoreInputItem;

+ (CGFloat) defaultHeight;
+ (CGFloat) defaultWidth;

- (instancetype)initWithFrame:(CGRect)frame
                    imageName:(NSString *)imageName
                highlightName:(NSString *)highlightName
                        title:(NSString *)title;

- (instancetype)initWithOriginX:(CGFloat)originX
                        OriginY:(CGFloat)originY
                      imageName:(NSString *)imageName
                  highlightName:(NSString *)highlightName
                          title:(NSString *)title;

- (instancetype)initWithFrame:(CGRect)frame ltzMoreInputItem:(LTZMoreInputItem *)ltzMoreInputItem;
- (instancetype)initWithOriginX:(CGFloat)originX
                        OriginY:(CGFloat)originY
               ltzMoreInputItem:(LTZMoreInputItem *)ltzMoreInputItem;

- (void)addTag:(NSInteger)tag target:(id)target action:(SEL)action forControlEvents:(UIControlEvents)controlEvents;

@end
