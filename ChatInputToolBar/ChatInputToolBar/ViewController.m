//
//  ViewController.m
//  ChatInputToolBar
//
//  Created by Peter Lee on 15/1/16.
//  Copyright (c) 2015年 Peter Lee. All rights reserved.
//

#import "ViewController.h"
#import "ChatInputToolBar.h"

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
    ChatInputToolBar *chatBar = [[ChatInputToolBar alloc] initWithFrame:CGRectMake(0, 150, 320, 44)];
    chatBar.autoresizingMask = UIViewAutoresizingFlexibleHeight|UIViewAutoresizingFlexibleTopMargin;
    //textView.placeHolder = @"这是测试！";
    //textView.font = [UIFont systemFontOfSize:28];
    [self.view addSubview:chatBar];
}

@end
