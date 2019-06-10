//
//  ViewController.m
//  MicrophoneDemo
//
//  Created by 王魏 on 2017/6/28.
//  Copyright © 2017年 wangwei. All rights reserved.
//

#import "ViewController.h"
#import "MicroPhoneView.h"
@interface ViewController ()

@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view, typically from a nib.
    MicroPhoneView * mView=[[MicroPhoneView alloc]initWithFrame:CGRectMake((self.view.bounds.size.width-150)/2, (self.view.bounds.size.height-150)/2, 150, 150)];
    [mView start];
    
    [self.view addSubview:mView];
}


- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


@end
