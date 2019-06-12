//
//  MicroPhoneView.m
//  ShowMo365
//
//  Created by 王魏 on 2017/6/22.
//  Copyright © 2017年 wangwei. All rights reserved.
//

#import "MicroPhoneView.h"
#import <AVFoundation/AVFoundation.h>
#import <AudioToolbox/AudioToolbox.h>


@interface MicroPhoneView ()<AVAudioRecorderDelegate>
{
    AVAudioRecorder * _recorder;
    int _audioStreth;//音频信号强度 这里吧分贝音量转换为1到10的信号强度 方便UI展示
    NSTimer *_timer;
}

@end
@implementation MicroPhoneView

- (void)dealloc{
    [_timer invalidate];
    _timer = nil;
}

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    
    if (self) {
        self.backgroundColor=[UIColor clearColor];
        _audioStreth = 1;
    }
    
    return self;
}
- (void)setupUI{
    
    self.backgroundColor = [[UIColor blackColor]colorWithAlphaComponent:0.5];
    self.layer.cornerRadius = 5;
    self.clipsToBounds = YES;
    UIImageView * imageView = [[UIImageView alloc]initWithFrame:CGRectMake(10, 35, self.frame.size.width/2, self.frame.size.height-70)];
    imageView.image = [UIImage imageNamed:@"micro"];
    [self addSubview:imageView];
    
    //10个label 每个高度为3
    //公差 d=（rect.size.width/2-30 - 5）/(10-1) 用公差乘以每一个label 即为 宽度
    int count = 10;
    float labelHeight = 3;
    CGFloat interval = (self.frame.size.height-(count*labelHeight)-70)/(count-1);
    for (int i = 0; i < count; i++) {
        UILabel * label=[[UILabel alloc]initWithFrame:CGRectMake(self.frame.size.width/2, 30+interval+(labelHeight+interval)*i, (self.frame.size.width/2-30-5)/(count-1)*(count-i), labelHeight)];
        label.backgroundColor=[UIColor whiteColor];
        [self addSubview:label];
        label.hidden = YES;
        label.tag = count-i;
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

- (void)configAudio{
    NSError *err = nil;
    [[AVAudioSession sharedInstance] setCategory :AVAudioSessionCategoryPlayAndRecord error:&err];
    if(err){
        NSLog(@"audioSession: %@ %ld %@", [err domain], (long)[err code], [[err userInfo] description]);
        return ;
    }
    [[AVAudioSession sharedInstance] setActive:YES error:&err];
    if(err){
        NSLog(@"audioSession: %@ %ld %@", [err domain], (long)[err code], [[err userInfo] description]);
        return ;
    }
    
    NSDictionary * recordSettings = @{AVFormatIDKey : @(kAudioFormatLinearPCM), AVEncoderBitRateKey:@(16),AVEncoderAudioQualityKey : @(AVAudioQualityMax), AVSampleRateKey : @(8000.0), AVNumberOfChannelsKey : @(1)};
    
    NSURL *url = [NSURL fileURLWithPath:[self fullPathAtCache:@"record.wav"]];
    _recorder = [[AVAudioRecorder alloc] initWithURL:url settings:recordSettings error:&err];
    [_recorder prepareToRecord];
    [_recorder setMeteringEnabled:YES];
    [_recorder recordForDuration:100];//录制音频时长
}
- (void)startUpdateAudioStreth{
    
    _timer = [NSTimer scheduledTimerWithTimeInterval:0.05 target:self selector:@selector(updateMeters) userInfo:nil repeats:YES];
}

- (void)start{
   
    //请求权限 如果用户已经选择了相关权限 会直接走回调
    [[AVAudioSession sharedInstance] requestRecordPermission:^(BOOL available) {
        if (available) {
            
            dispatch_async(dispatch_get_main_queue(), ^{
                [self setupUI];
                [self configAudio];
                [self startUpdateAudioStreth];
            });
            
        }else{
            
            dispatch_async(dispatch_get_main_queue(), ^{
              [self showNoPermissonAlertController];
            });
            
        }
    }];
    
    
}
- (void)showNoPermissonAlertController{
    
    UIAlertController * alertController=[UIAlertController alertControllerWithTitle:NSLocalizedString(@"No permission to access the microphone",nil) message:NSLocalizedString(@"Please allow access to your microphone in the settings - Privacy - microphone option",nil) preferredStyle:UIAlertControllerStyleAlert];
    
    UIAlertAction * okAction=[UIAlertAction actionWithTitle:NSLocalizedString(@"OK",nil) style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
    }];
    [alertController addAction:okAction];
    UIViewController *rootViewController = [[UIApplication sharedApplication].keyWindow rootViewController];
    [rootViewController presentViewController:alertController animated:true completion:nil];
}

- (void)updateMeters {
    [_recorder updateMeters];
    
    //获取0声道的平均分贝值
    float audioDecibels = [_recorder averagePowerForChannel:0];
    
//    The current average power, in decibels, for the sound being recorded. A return value of 0 dB indicates full scale, or maximum power; a return value of -160 dB indicates minimum power (that is, near silence).
//    If the signal provided to the audio recorder exceeds ±full scale, then the return value may exceed 0 (that is, it may enter the positive range).
    
    //苹果的取值范围为 -160 - 0有可能大于0  根据我的测试结果暂且认为 -50是安静的 -10为最大声音
    float maxAudioDecibels = -10;
    float minAudioDecibels = -50;
    if (audioDecibels < minAudioDecibels) {
        _audioStreth = 1;//小于最小分贝 认为是最低档的1
    }else if (audioDecibels > maxAudioDecibels){
        _audioStreth = 10;//大于最高分贝 认为是最高档的10
    }else{
        //计算声音强度值
        float per = (audioDecibels + maxAudioDecibels)/(minAudioDecibels + maxAudioDecibels);
        _audioStreth = 10 - [[NSString stringWithFormat:@"%.f",per*10] intValue];
    }
    //重新绘制
    [self setNeedsDisplay];
}

// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect {
    // Drawing code
    
    //显示和隐藏label
    for (int i=0; i<_audioStreth; i++) {
        UILabel * label = [self viewWithTag:i] ;
        label.hidden = FALSE;
    }
    for (int i=_audioStreth; i<10; i++) {
        UILabel * label = [self viewWithTag:i] ;
        label.hidden = TRUE;
    }
}


- (void)stop{
    [_timer invalidate];
    _timer = nil;
    
    [_recorder stop];
    [_recorder deleteRecording];
}
@end

