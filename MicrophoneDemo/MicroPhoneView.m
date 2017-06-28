//
//  MicroPhoneView.m
//  ShowMo365
//
//  Created by 王魏 on 2017/6/22.
//  Copyright © 2017年 zjf. All rights reserved.
//

#import "MicroPhoneView.h"
#import <AVFoundation/AVFoundation.h>
#import <AudioToolbox/AudioToolbox.h>


@interface MicroPhoneView ()<AVAudioRecorderDelegate>
{
    AVAudioRecorder * _recorder;
    int _audioStreth;
    NSTimer *_timer;
    CGRect _frame;
}

@end
@implementation MicroPhoneView

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    
    if (self) {
        self.backgroundColor=[UIColor clearColor];
        _audioStreth=1;
        _frame=frame;

    }
    
    return self;
}
- (void)loadUI{
    
 dispatch_async(dispatch_get_main_queue(), ^{
    self.backgroundColor=[[UIColor blackColor]colorWithAlphaComponent:0.5];
    self.layer.cornerRadius=5;
    self.clipsToBounds=YES;
    UIImageView * imageView=[[UIImageView alloc]initWithFrame:CGRectMake(10, 35, _frame.size.width/2, _frame.size.height-70)];
    imageView.image=[UIImage imageNamed:@"micro"];
    [self addSubview:imageView];
    
    //10个label 每个高度为3
    //公差 d=（rect.size.width/2-30 - 5）/(10-1) 用公差乘以每一个label 即为 宽度
    int count=10;
    float labelHeight=3;
    CGFloat interval=(_frame.size.height-(count*labelHeight)-70)/(count-1);
    for (int i=0; i<count; i++) {
        UILabel * label=[[UILabel alloc]initWithFrame:CGRectMake(_frame.size.width/2, 30+interval+(labelHeight+interval)*i, (_frame.size.width/2-30-5)/(count-1)*(count-i), labelHeight)];
        label.backgroundColor=[UIColor whiteColor];
        [self addSubview:label];
        label.hidden=YES;
        label.tag=count-i;
    }
    });
}
// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect {
    // Drawing code
    for (int i=0; i<_audioStreth; i++) {
        UILabel * label=[self viewWithTag:i] ;
        label.hidden=NO;
    }
    for (int i=_audioStreth; i<10; i++) {
        UILabel * label=[self viewWithTag:i] ;
        label.hidden=YES;
    }
}
- (NSString *)fullPathAtCache:(NSString *)fileName{
    NSError *error;
    NSString *path = [NSSearchPathForDirectoriesInDomains(NSCachesDirectory, NSUserDomainMask, YES)objectAtIndex:0];
    NSFileManager *fm = [NSFileManager defaultManager];
    if (YES != [fm fileExistsAtPath:path]) {
        if (YES != [fm createDirectoryAtPath:path withIntermediateDirectories:YES attributes:nil error:&error]) {
            
        }
    }
    return [path stringByAppendingPathComponent:fileName];
}
- (void)start{
    AVAudioSession *audioSession = [AVAudioSession sharedInstance];
    [audioSession requestRecordPermission:^(BOOL available) {
        if (available) {
            [self loadUI];
            NSError *err = nil;
            [audioSession setCategory :AVAudioSessionCategoryPlayAndRecord error:&err];
            if(err){
                NSLog(@"audioSession: %@ %ld %@", [err domain], (long)[err code], [[err userInfo] description]);
                return ;
            }
            err = nil;
            [audioSession setActive:YES error:&err];
            if(err){
                NSLog(@"audioSession: %@ %ld %@", [err domain], (long)[err code], [[err userInfo] description]);
                return ;
            }
            
            NSDictionary * recordSettings = @{AVFormatIDKey : @(kAudioFormatLinearPCM), AVEncoderBitRateKey:@(16),AVEncoderAudioQualityKey : @(AVAudioQualityMax), AVSampleRateKey : @(8000.0), AVNumberOfChannelsKey : @(1)};
            
            NSURL *url = [NSURL fileURLWithPath:[self fullPathAtCache:@"record.wav"]];
            _recorder = [[AVAudioRecorder alloc] initWithURL:url settings:recordSettings error:&err];
            //    [_recorder setDelegate:self];
            [_recorder prepareToRecord];
            [_recorder setMeteringEnabled:YES];
            [_recorder recordForDuration:100000];
            dispatch_async(dispatch_get_main_queue(), ^{
                _timer= [NSTimer scheduledTimerWithTimeInterval:0.05 target:self selector:@selector(updateMeters) userInfo:nil repeats:YES];
            });
            
        }else{
            
            dispatch_async(dispatch_get_main_queue(), ^{
                UIAlertController * alertController=[UIAlertController alertControllerWithTitle:NSLocalizedString(@"No permission to access the microphone",nil) message:NSLocalizedString(@"Please allow access to your microphone in the settings - Privacy - microphone option",nil) preferredStyle:UIAlertControllerStyleAlert];
                
                UIAlertAction * okAction=[UIAlertAction actionWithTitle:NSLocalizedString(@"Go to settings",nil) style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
//                    [pwGlobal gotoLocationSetting];
                }];
                
                UIAlertAction * cancelAction=[UIAlertAction actionWithTitle:NSLocalizedString(@"Cancel", nil) style:UIAlertActionStyleCancel handler:^(UIAlertAction * _Nonnull action) {
                    
                }];
                [alertController addAction:okAction];
                [alertController addAction:cancelAction];
                UIViewController *rootViewController = [[UIApplication sharedApplication].keyWindow rootViewController];
                [rootViewController presentViewController:alertController animated:true completion:nil];
            });
            
        }
    }];
    
    
}
- (void)updateMeters {
    [_recorder updateMeters];
    //    NSLog(@"meter:%5f", [_recorder averagePowerForChannel:0]);
    //把音量转换成1-10之间的数字，越大声音越大
    int level=1;
    float power=[_recorder averagePowerForChannel:0];
    //暂且认为 -50是安静的 -10为最大声音 苹果取值范围  -160 - 0 有可能大于0
    float maxPower=-10;
    float minPower=-50;
    if (power<minPower) {
        level=1;
    }else if (power>maxPower){
        level=10;
    }else{
        float per= (power+maxPower)/(minPower+maxPower);
        level=10-[[NSString stringWithFormat:@"%.f",per*10] intValue];
    }
    _audioStreth=level;
    [self setNeedsDisplay];
}

- (void)stop{
    [_timer invalidate];
    _timer=nil;
    
    [_recorder stop];
    [_recorder deleteRecording];
}
- (void)dealloc{
    [_timer invalidate];
    _timer=nil;
}
@end

