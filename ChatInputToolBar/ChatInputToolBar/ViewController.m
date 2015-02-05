//
//  ViewController.m
//  ChatInputToolBar
//
//  Created by Peter Lee on 15/1/16.
//  Copyright (c) 2015年 Peter Lee. All rights reserved.
//

#import "ViewController.h"
#import "LTZInputToolBar.h"

@interface ViewController ()<UITableViewDelegate, UITableViewDataSource>
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
    [self.view addGestureRecognizer:_panGestureRecognizer];
}

- (void)test
{
    [self.view setBackgroundColor:[UIColor lightGrayColor]];
    chatBar = [[LTZInputToolBar alloc] initWithFrame:CGRectMake(0, self.view.frame.size.height-[LTZInputToolBar LTZInputToolDefaultHeight], self.view.frame.size.width, [LTZInputToolBar LTZInputToolBarDefaultHeight])
                                                           scrollView:self.tableView
                                                               inView:self.view
                                                    gestureRecognizer:self.tableView.panGestureRecognizer
                                                             delegate:self];
    chatBar.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleTopMargin;
    //textView.placeHolder = @"这是测试！";
    //textView.font = [UIFont systemFontOfSize:28];
    [self.view addSubview:chatBar];
}

- (void)dismissKeyboard
{
    //[chatBar resignFirstResponder];
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

@end
