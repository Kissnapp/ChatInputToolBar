//
//  ChatInputToolBar.m
//  ChatInputToolBar
//
//  Created by Peter Lee on 15/1/16.
//  Copyright (c) 2015年 Peter Lee. All rights reserved.
//

#import "ChatInputToolBar.h"
#import "ChatInputTextView.h"

#define DEFAULT_MAGIN_WIDTH 8.0f
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
        [self _setupViews];
    }
    return self;
}

- (void)_setupViews
{
    self.userInteractionEnabled = YES;
    self.backgroundColor = [UIColor redColor];
    
    _inputTextView = [[ChatInputTextView alloc] initWithFrame:CGRectMake(0, 0, self.frame.size.width-2*DEFAULT_MAGIN_WIDTH, self.frame.size.height)];
    _inputTextView.placeHolder = @"请输入信息";
    _inputTextView.delegate = self;
    _inputTextView.pagingEnabled = NO;
    _inputTextView.translatesAutoresizingMaskIntoConstraints = NO;
    
    [self addSubview:_inputTextView];
    
    NSMutableArray *Constraints = [NSMutableArray array];
    
    [Constraints addObjectsFromArray:[NSLayoutConstraint constraintsWithVisualFormat:@"H:|-MARGIN1-[_inputTextView]-MARGIN1-|" options:0 metrics:@{@"MARGIN1":[NSNumber numberWithFloat:DEFAULT_MAGIN_WIDTH]} views:NSDictionaryOfVariableBindings(_inputTextView)]];
    
    [Constraints addObjectsFromArray:[NSLayoutConstraint constraintsWithVisualFormat:@"V:|-MARGIN1-[_inputTextView]-MARGIN1-|" options:0 metrics:@{@"MARGIN1":[NSNumber numberWithFloat:DEFAULT_MAGIN_HEIGHT]} views:NSDictionaryOfVariableBindings(_inputTextView)]];
    
    [self addConstraints:Constraints];
}

#pragma mark - private methods
static inline CGFloat HeightWith(UITextView *textView)
{
    return textView.contentSize.height + 2 * DEFAULT_MAGIN_HEIGHT;
}

#pragma mark - UITextViewDelegate methods
- (void)textViewDidChange:(UITextView *)textView
{
    CGRect frame = textView.frame;
    frame.size = textView.contentSize;
    [UIView animateWithDuration:0.25 animations:^{
        textView.frame = frame;
        self.frame = CGRectMake(self.frame.origin.x, self.frame.origin.y, self.frame.size.width, HeightWith(textView));
    }];
}

/*
 + (float) heightForTextView: (UITextView *)textView
 {
 
 float fPadding = 16.0; // 8.0px x 2
 CGSize constraint = CGSizeMake(textView.contentSize.width - fPadding, CGFLOAT_MAX);
 //CGSize size = [strText sizeWithFont: textView.font constrainedToSize:constraint lineBreakMode:UILineBreakModeWordWrap];
 NSMutableParagraphStyle *paragraphStyle = [[NSMutableParagraphStyle alloc] init];
 paragraphStyle.lineBreakMode = NSLineBreakByWordWrapping;
 
 NSDictionary *attributes = @{
 NSFontAttributeName:textView.font,
 NSParagraphStyleAttributeName:paragraphStyle.copy
 };
 
 
 CGSize size = [text boundingRectWithSize:constraint
 options:NSStringDrawingUsesLineFragmentOrigin
 attributes:attributes
 context:nil].size;
 
 float fHeight = size.height + 16.0;
 
 return fHeight;
 }
 */


/*
// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect
{
    // Drawing code
}
*/

@end
