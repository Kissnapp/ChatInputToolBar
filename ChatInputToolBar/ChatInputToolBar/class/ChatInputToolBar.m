//
//  ChatInputToolBar.m
//  ChatInputToolBar
//
//  Created by Peter Lee on 15/1/16.
//  Copyright (c) 2015年 Peter Lee. All rights reserved.
//

#import "ChatInputToolBar.h"
#import "ChatInputTextView.h"

#define DEFAULT_MAGIN_WIDTH 5.0f
#define DEFAULT_MAGIN_HEIGHT DEFAULT_MAGIN_WIDTH

#define DEFAULT_BUTTON_HEIGHT 25.0f
#define DEFAULT_BUTTON_WITDH DEFAULT_BUTTON_HEIGHT

#define DEFAULT_TEXT_VIEW_WIDTH (self.frame.size.width - 5*DEFAULT_MAGIN_WIDTH - 3*DEFAULT_MAGIN_WIDTH)
#define DEFAULT_TEXT_VIEW_HEIGHT (self.frame.size.height - 2*DEFAULT_MAGIN_HEIGHT)

#define DEFAULT_TALK_BUTTON_WIDTH 80.0f
#define DEFAULT_TALK_BUTTON_HEIGHT DEFAULT_TALK_BUTTON_WIDTH

@interface ChatInputToolBar ()<UITextViewDelegate>
{
    UIButton                *_voiceSwitchBtn;
    UIButton                *_expressionSwitchBtn;
    UIButton                *_moreSwitchBtn;
    ChatInputTextView       *_inputTextView;
    
}

@property (nonatomic, strong) id<ChatInputToolBarDelegate> delegate;

@end

@implementation ChatInputToolBar

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        // Initialization code
        
    }
    return self;
}

- (void)_setupViews
{
    
}
/*
// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect
{
    // Drawing code
}
*/

@end
