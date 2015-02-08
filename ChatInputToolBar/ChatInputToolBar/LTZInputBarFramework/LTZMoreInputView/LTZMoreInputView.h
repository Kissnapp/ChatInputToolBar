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

@property (strong, nonatomic) NSArray *ltzMoreInputViewItems;

- (void)reloadData;

@end


@protocol LTZMoreInputViewPublicDelegate <NSObject>

@optional

- (void)didSelecteMoreInputViewItem:(LTZMoreInputItem *)inputViewItem atIndex:(NSInteger)index;

@end

@protocol LTZMoreInputViewPrivateDelegate <NSObject>

@optional

@end

@protocol LTZMoreInputViewDataSource <NSObject>

@required

- (NSUInteger)numberOfRowsShowInLTZMoreInputView:(LTZMoreInputView *)ltzMoreInputView;
- (NSUInteger)numberOfColumnsShowInLTZMoreInputView:(LTZMoreInputView *)ltzMoreInputView;

@optional

- (CGFloat)widthOfMoreInputViewItemShowInInLTZMoreInputView:(LTZMoreInputView *)ltzMoreInputView;
- (CGFloat)heightOfMoreInputViewItemShowInInLTZMoreInputView:(LTZMoreInputView *)ltzMoreInputView;
- (LTZMoreInputItem *)ltzMoreInputView:(LTZMoreInputView *)ltzMoreInputView moreInputViewItemShowAtIndex:(NSUInteger)index;

@end

