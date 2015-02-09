//
//  LTZMoreInputItemView.m
//  ChatInputToolBar
//
//  Created by  李天柱 on 15/2/8.
//  Copyright (c) 2015年 Peter Lee. All rights reserved.
//

#import "LTZMoreInputItemView.h"
#import "LTZMoreInputItem.h"
#import "UIColor+Extension.h"

#define DEFAULT_ITEM_VIEW_WIDTH 60.0f
#define DEFAULT_ITEM_VIEW_HEIGHT 80.0f
#define DEFAULT_BUTTON_HEIGHT DEFAULT_ITEM_VIEW_WIDTH
#define DEFAULT_BUTTON_WIDTH DEFAULT_BUTTON_HEIGHT
#define DEFAULT_TITLE_HEIGHT (DEFAULT_ITEM_VIEW_HEIGHT - DEFAULT_BUTTON_HEIGHT)
#define DEFAULT_TITLE_WIDTH DEFAULT_BUTTON_WIDTH


////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
#pragma mark - LTZMoreInputItemView
////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////


@interface LTZMoreInputItemView ()
{
    LTZMoreInputItem *_ltzMoreInputItem;
}

@property (nonatomic, strong) UIButton  *imagebutton;
@property (nonatomic, strong) UILabel   *titleLabel;

@end

@implementation LTZMoreInputItemView
@synthesize ltzMoreInputItem = _ltzMoreInputItem;

- (instancetype)initWithFrame:(CGRect)frame
             ltzMoreInputItem:(LTZMoreInputItem *)ltzMoreInputItem
{
    return [self initWithFrame:frame
                     imageName:ltzMoreInputItem.imageName
                 highlightName:ltzMoreInputItem.highlightName
                         title:ltzMoreInputItem.title];
}

- (instancetype)initWithFrame:(CGRect)frame
                    imageName:(NSString *)imageName
                highlightName:(NSString *)highlightName
                        title:(NSString *)title
{
    self = [super initWithFrame:frame];
    if (self) {
        LTZMoreInputItem *ltzMoreInputItem = [[LTZMoreInputItem alloc] initWithImageName:imageName
                                                                           highlightName:highlightName
                                                                                   title:title];
        _ltzMoreInputItem = ltzMoreInputItem;
        
        [self setupViewsWithImageName:imageName
                        highlightName:highlightName
                                title:title];
    }
    return self;
}

- (instancetype)initWithOriginX:(CGFloat)originX
                        OriginY:(CGFloat)originY
                      imageName:(NSString *)imageName
                  highlightName:(NSString *)highlightName
                          title:(NSString *)title
{
    CGRect frame = CGRectMake(originX, originY, DEFAULT_ITEM_VIEW_WIDTH, DEFAULT_ITEM_VIEW_HEIGHT);
    self = [super initWithFrame:frame];
    if (self) {
        LTZMoreInputItem *ltzMoreInputItem = [[LTZMoreInputItem alloc] initWithImageName:imageName
                                                                           highlightName:highlightName
                                                                                   title:title];
        _ltzMoreInputItem = ltzMoreInputItem;
        
        [self setupViewsWithImageName:imageName
                        highlightName:highlightName
                                title:title];
    }
    return self;
}

- (instancetype)initWithOriginX:(CGFloat)originX
                        OriginY:(CGFloat)originY
               ltzMoreInputItem:(LTZMoreInputItem *)ltzMoreInputItem
{
    return [self initWithOriginX:originX
                         OriginY:originY
                       imageName:ltzMoreInputItem.imageName
                   highlightName:ltzMoreInputItem.highlightName
                           title:ltzMoreInputItem.title];
}

- (void)setupViewsWithImageName:(NSString *)imageName
                  highlightName:(NSString *)highlightName
                          title:(NSString *)title
{
    self.imagebutton = [self buttonWithImageName:imageName highlightName:highlightName];
    self.titleLabel = [self titleLabelWithTitle:title];
}

- (void)addTag:(NSInteger)tag target:(id)target action:(SEL)action forControlEvents:(UIControlEvents)controlEvents;
{
    if (!self.imagebutton) return;
    [self.imagebutton setTag:tag];
    [self.imagebutton addTarget:target action:action forControlEvents:controlEvents];
}

- (UIButton *)buttonWithImageName:(NSString *)imageName highlightName:(NSString *)highlightName
{
    UIButton *btn = [[UIButton alloc] initWithFrame:CGRectMake(0, 0, DEFAULT_BUTTON_WIDTH, DEFAULT_BUTTON_HEIGHT)];
    [btn setImageEdgeInsets:UIEdgeInsetsMake(10, 10, 10, 10)];
    [btn setImage:[UIImage imageNamed:imageName] forState:UIControlStateNormal];
    [btn setImage:[UIImage imageNamed:highlightName] forState:UIControlStateHighlighted];
    [self addSubview:btn];
    return btn;
}

- (UILabel *)titleLabelWithTitle:(NSString *)title
{
    UILabel *titleLabel = [[UILabel alloc] initWithFrame:CGRectMake(0, DEFAULT_BUTTON_HEIGHT, DEFAULT_TITLE_WIDTH, DEFAULT_TITLE_HEIGHT)];
    titleLabel.backgroundColor = [UIColor clearColor];
    titleLabel.font = [UIFont systemFontOfSize:14];
    titleLabel.textColor = [UIColor colorWithHexString:@"0x666666"];
    titleLabel.textAlignment = NSTextAlignmentCenter;
    titleLabel.text = title;
    
    [self addSubview:titleLabel];
    
    return titleLabel;
}

- (void)dealloc
{
    self.imagebutton = nil;
    self.titleLabel = nil;
    _ltzMoreInputItem = nil;
}

/*
// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect {
    // Drawing code
}
*/

@end
