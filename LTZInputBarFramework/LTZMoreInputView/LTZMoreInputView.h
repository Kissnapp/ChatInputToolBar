//
//  LTZMoreInputView.h
//  ChatInputToolBar
//
//  Created by Peter Lee on 15/2/2.
//  Copyright (c) 2015年 Peter Lee. All rights reserved.
//

#import <UIKit/UIKit.h>

@class LTZMoreInputItem;
@class LTZMoreInputItemView;

@protocol LTZMoreInputViewPublicDelegate;
@protocol LTZMoreInputViewPrivateDelegate;
@protocol LTZMoreInputViewDataSource;

@interface LTZMoreInputView : UIImageView

@property (weak, nonatomic) id <LTZMoreInputViewPublicDelegate> publicDelegate;
@property (weak, nonatomic) id <LTZMoreInputViewPrivateDelegate> privateDelegate;
@property (weak, nonatomic) id <LTZMoreInputViewDataSource> dataSource;

//@property (strong, nonatomic) NSArray *ltzMoreInputViewItems;

- (instancetype)initWithFrame:(CGRect)frame
               publicDelegate:(id <LTZMoreInputViewPublicDelegate>)publicDelegate
              privateDelegate:(id <LTZMoreInputViewPrivateDelegate>)privateDelegate
                   dataSource:(id <LTZMoreInputViewDataSource>) dataSource;

- (void)reloadData;

@end


@protocol LTZMoreInputViewPublicDelegate <NSObject>

@optional

- (void)ltzMoreInputView:(LTZMoreInputView *)ltzMoreInputView didSelecteMoreInputViewItemAtIndex:(NSInteger)index;

@end

@protocol LTZMoreInputViewPrivateDelegate <NSObject>

@optional

@end

@protocol LTZMoreInputViewDataSource <NSObject>

@required

- (NSUInteger)numberOfItemsShowInLTZMoreInputView:(LTZMoreInputView *)ltzMoreInputView;

@optional

- (LTZMoreInputItem *)ltzMoreInputView:(LTZMoreInputView *)ltzMoreInputView moreInputViewItemShowAtIndex:(NSUInteger)index;
- (NSString *)ltzMoreInputView:(LTZMoreInputView *)ltzMoreInputView imageNameShowAtIndex:(NSUInteger)index;
- (NSString *)ltzMoreInputView:(LTZMoreInputView *)ltzMoreInputView highlightedImageNameShowAtIndex:(NSUInteger)index;
- (NSString *)ltzMoreInputView:(LTZMoreInputView *)ltzMoreInputView titleShowAtIndex:(NSUInteger)index;

@end

