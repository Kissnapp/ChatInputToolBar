//
//  ViewController.m
//  ChatInputToolBar
//
//  Created by Peter Lee on 15/1/16.
//  Copyright (c) 2015年 Peter Lee. All rights reserved.
//

#import "ViewController.h"
#import "ChatInputTextView.h"

@interface ViewController ()

@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view, typically from a nib.
    [self test];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)test
{
    [self.view setBackgroundColor:[UIColor lightGrayColor]];
    ChatInputTextView *textView = [[ChatInputTextView alloc] initWithFrame:CGRectMake(0, 100, 320, 24)];
    textView.placeHolder = @"这是测试！";
    //textView.font = [UIFont systemFontOfSize:28];
    [self.view addSubview:textView];
}

@end
