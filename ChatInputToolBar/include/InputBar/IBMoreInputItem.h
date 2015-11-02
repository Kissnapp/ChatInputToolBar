//
//  LTZMoreInputViewItem.h
//  ChatInputToolBar
//
//  Created by Peter Lee on 15/2/6.
//  Copyright (c) 2015年 Peter Lee. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface IBMoreInputItem : NSObject

@property (nonatomic, strong, readonly) NSString *imageName;
@property (nonatomic, strong, readonly) NSString *highlightName;
@property (nonatomic, copy, readonly) NSString *title;

- (instancetype)initWithImageName:(NSString *)imageName
                    highlightName:(NSString *)highlightName
                            title:(NSString *)title;

- (void)updateWithImageName:(NSString *)imageName
              highlightName:(NSString *)highlightName
                      title:(NSString *)title;
@end
