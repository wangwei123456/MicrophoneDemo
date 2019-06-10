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
{
    MicroPhoneView * _microView;
}
@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view, typically from a nib.
    [self setupUI];
}
- (void)setupUI{

    UILabel * longPressLab = [[UILabel alloc]initWithFrame:CGRectMake((self.view.bounds.size.width-100)/2, (self.view.bounds.size.height-160), 100, 100)];
    longPressLab.layer.cornerRadius = 50;
    longPressLab.clipsToBounds = TRUE;
    longPressLab.backgroundColor = [UIColor colorWithRed:0.0f green:0.48f blue:1.0f alpha:1.0f];
    longPressLab.text = NSLocalizedString(@"长按对讲", @"");
    longPressLab.textColor = [UIColor whiteColor];
    longPressLab.textAlignment = NSTextAlignmentCenter;
    longPressLab.userInteractionEnabled = TRUE;
    [self.view addSubview:longPressLab];
    
    //add a LongPressGesture
    UILongPressGestureRecognizer * longPress = [[UILongPressGestureRecognizer alloc]initWithTarget:self action:@selector(intercom:)];
    longPress.minimumPressDuration = 0.2;
    [longPressLab addGestureRecognizer:longPress];

}
-(void)intercom:(UILongPressGestureRecognizer*)longPressedRecognizer{
   
    //longpress start
    if(longPressedRecognizer.state == UIGestureRecognizerStateBegan){
        
        [self startMicroAnimation];
        
    }else if(longPressedRecognizer.state == UIGestureRecognizerStateEnded || longPressedRecognizer.state == UIGestureRecognizerStateCancelled){
       
        [self stopMicroAnimation];
    }
}


- (void)startMicroAnimation{
    
    _microView = [[MicroPhoneView alloc]initWithFrame:CGRectMake((self.view.bounds.size.width-150)/2, (self.view.bounds.size.height-150)/2,150, 150)];
    [self.view addSubview:_microView];
    [_microView start];

}

- (void)stopMicroAnimation{
    
    if (_microView) {
        [_microView stop];
        [_microView removeFromSuperview];
    }
}
   

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


@end
