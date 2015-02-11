//
//  ViewController.m
//  ChatInputToolBar
//
//  Created by Peter Lee on 15/1/16.
//  Copyright (c) 2015年 Peter Lee. All rights reserved.
//

#import "ViewController.h"
#import "LTZInputBar.h"

@interface ViewController ()<UIGestureRecognizerDelegate, UITableViewDelegate, UITableViewDataSource, LTZInputToolBarDataSource>
{
    UITapGestureRecognizer *_panGestureRecognizer;
    LTZInputToolBar *chatBar;
}
@property (nonatomic, strong) UITableView *tableView;

@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view, typically from a nib.
    [self _setupViews];
    [self test];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)_setupViews
{
    self.tableView = ({
        UITableView *tableView = [[UITableView alloc] initWithFrame:CGRectMake(0, 0, self.view.frame.size.width, self.view.frame.size.height - 44.0) style:UITableViewStylePlain];
        UIImageView *imageView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"bg.jpg"]];
        //imageView.frame = CGRectMake(0, 0, tableView.frame.size.width, tableView.frame.size.height);
        [tableView setBackgroundView:imageView];
        tableView.delegate = self;
        tableView.dataSource = self;
        [self.view addSubview:tableView];
        tableView;
    });
    
    _panGestureRecognizer = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(dismissKeyboard)];
    _panGestureRecognizer.delegate = self;
    [self.tableView addGestureRecognizer:_panGestureRecognizer];
}

- (void)test
{
    [self.view setBackgroundColor:[UIColor lightGrayColor]];
    chatBar = [[LTZInputToolBar alloc] initWithFrame:CGRectMake(0, self.view.frame.size.height-[LTZInputToolBar LTZInputToolDefaultHeight], self.view.frame.size.width, [LTZInputToolBar LTZInputToolBarDefaultHeight])
                                                           scrollView:self.tableView
                                                               inView:self.view
                                                    gestureRecognizer:self.tableView.panGestureRecognizer
                                                             delegate:self
                                          dataSource:self];
    chatBar.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleTopMargin;
    //textView.placeHolder = @"这是测试！";
    //textView.font = [UIFont systemFontOfSize:28];
    [self.view addSubview:chatBar];
}

- (void)dismissKeyboard
{
    [chatBar resignFirstResponder];
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return 101;
}

// Row display. Implementers should *always* try to reuse cells by setting each cell's reuseIdentifier and querying for available reusable cells with dequeueReusableCellWithIdentifier:
// Cell gets various attributes set automatically based on table (separators) and data source (accessory views, editing controls)

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"cell"];
    if (!cell) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:@"cell"];
    }
    cell.backgroundColor = [UIColor clearColor];
    cell.textLabel.text = [NSString stringWithFormat:@"这是第%d个UITableViewCell",indexPath.row];
    
    return cell;
}

/**
 *  Called when send a text
 *
 *  @param ltzInputTool The input tool
 */
- (void)ltzInputTool:(LTZInputTool *)ltzInputTool didSentTextContent:content
{
    NSLog(content);
}
/**
 *  when we press the record button
 */
- (void)didStartRecordingWithLTZInputTool:(LTZInputTool *)ltzInputTool
{
    NSLog(@"didStartRecordingWithLTZInputTool");
}
/**
 *  When we cancel a recording action
 */
- (void)didCancelRecordingWithLTZInputTool:(LTZInputTool *)ltzInputTool
{
    NSLog(@"didCancelRecordingWithLTZInputTool");
}
/**
 *  When we finish a recording action
 */
- (void)didFinishRecordingWithLTZInputTool:(LTZInputTool *)ltzInputTool
{
    NSLog(@"didFinishRecordingWithLTZInputTool");
}
/**
 *  This method called when we our finger drag outside the inputTool view during recording action
 */
- (void)didDragOutsideWhenRecordingWithLTZInputTool:(LTZInputTool *)ltzInputTool
{
    NSLog(@"didDragOutsideWhenRecordingWithLTZInputTool");
}

- (void)ltzMoreInputView:(LTZMoreInputView *)ltzMoreInputView didSelecteMoreInputViewItemAtIndex:(NSInteger)index
{
    NSLog(@"you have cliked on:%d",index);
}
/**
 *  This method called when we our finger drag inside the inputTool again view during recording action
 */
- (void)didDragInsideWhenRecordingWithLTZInputTool:(LTZInputTool *)ltzInputTool
{
    NSLog(@"didDragInsideWhenRecordingWithLTZInputTool");
}

#pragma mark - LTZInputBarDataSource methods

- (NSUInteger)numberOfItemsShowInLTZMoreInputView:(LTZMoreInputView *)ltzMoreInputView
{
    return 23;
}
- (NSString *)ltzMoreInputView:(LTZMoreInputView *)ltzMoreInputView imageNameShowAtIndex:(NSUInteger)index
{
    return @"keyboard_add_camera.png";
}
- (NSString *)ltzMoreInputView:(LTZMoreInputView *)ltzMoreInputView highlightedImageNameShowAtIndex:(NSUInteger)index
{
    return @"keyboard_add_photo.png";
}
- (NSString *)ltzMoreInputView:(LTZMoreInputView *)ltzMoreInputView titleShowAtIndex:(NSUInteger)index
{
    return @"testtest";
}

#pragma mark - UIGestureRecognizerDelegate methods
- (BOOL)gestureRecognizer:(UIGestureRecognizer *)gestureRecognizer shouldReceiveTouch:(UITouch *)touch
{
    // Disallow recognition of tap gestures in the segmented control.
    
    if ([touch.view isKindOfClass:[LTZInputTool class]]) {
        return NO;
    }
    
    return YES;
}

@end
