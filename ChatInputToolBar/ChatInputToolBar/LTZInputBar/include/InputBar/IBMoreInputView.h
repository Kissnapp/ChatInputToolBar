//
//  LTZMoreInputView.h
//  ChatInputToolBar
//
//  Created by Peter Lee on 15/2/2.
//  Copyright (c) 2015年 Peter Lee. All rights reserved.
//

#import <UIKit/UIKit.h>

@class IBMoreInputItem;
@class IBMoreInputItemView;

@protocol IBMoreInputViewPublicDelegate;
@protocol IBMoreInputViewPrivateDelegate;
@protocol IBMoreInputViewDataSource;

@interface IBMoreInputView : UIImageView

@property (weak, nonatomic) id <IBMoreInputViewPublicDelegate> publicDelegate;
@property (weak, nonatomic) id <IBMoreInputViewPrivateDelegate> privateDelegate;
@property (weak, nonatomic) id <IBMoreInputViewDataSource> dataSource;

//@property (strong, nonatomic) NSArray *ltzMoreInputViewItems;

- (instancetype)initWithFrame:(CGRect)frame
               publicDelegate:(id <IBMoreInputViewPublicDelegate>)publicDelegate
              privateDelegate:(id <IBMoreInputViewPrivateDelegate>)privateDelegate
                   dataSource:(id <IBMoreInputViewDataSource>) dataSource;

- (void)reloadData;

@end


@protocol IBMoreInputViewPublicDelegate <NSObject>

@optional

- (void)ltzMoreInputView:(IBMoreInputView *)ltzMoreInputView didSelecteMoreInputViewItemAtIndex:(NSInteger)index;

@end

@protocol IBMoreInputViewPrivateDelegate <NSObject>

@optional

@end

@protocol IBMoreInputViewDataSource <NSObject>

@required

- (NSUInteger)numberOfItemsShowInLTZMoreInputView:(IBMoreInputView *)ltzMoreInputView;

@optional

- (IBMoreInputItem *)ltzMoreInputView:(IBMoreInputView *)ltzMoreInputView moreInputViewItemShowAtIndex:(NSUInteger)index;
- (NSString *)ltzMoreInputView:(IBMoreInputView *)ltzMoreInputView imageNameShowAtIndex:(NSUInteger)index;
- (NSString *)ltzMoreInputView:(IBMoreInputView *)ltzMoreInputView highlightedImageNameShowAtIndex:(NSUInteger)index;
- (NSString *)ltzMoreInputView:(IBMoreInputView *)ltzMoreInputView titleShowAtIndex:(NSUInteger)index;

@end

