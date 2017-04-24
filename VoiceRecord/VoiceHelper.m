//
//  VoiceHelper.m
//  VoiceRecord
//
//  Created by leezb101 on 2017/4/22.
//  Copyright © 2017年 leezb101. All rights reserved.
//

#import "VoiceHelper.h"
#import "ViewController.h"
#import <UIKit/UIKit.h>
#import <AVFoundation/AVFoundation.h>
#import <AudioToolbox/AudioToolbox.h>
#import "VoiceConvert.h"

@interface VoiceHelper ()

@property (nonatomic, strong) AVAudioRecorder *recorder;
@property (nonatomic, weak) UIViewController *targetViewController;
@property (nonatomic, strong) NSString *fileRecordName;
@property (nonatomic, strong) NSString *recordPath;

@property (nonatomic, strong) NSString *amrPath;


@end

@implementation VoiceHelper

static VoiceHelper *_helper;

#pragma mark - Helper单例
+ (instancetype)allocWithZone:(struct _NSZone *)zone {
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        _helper = [super allocWithZone:zone];
    });
    return _helper;
}

+ (instancetype)sharedHelper {
    static dispatch_once_t token;
    dispatch_once(&token, ^{
        _helper = [[self alloc] init];
    });
    return _helper;
}

- (id)copyWithZone:(NSZone *)zone {
    return _helper;
}

#pragma mark - 生成文件名
- (NSString *)getCurrentTimeString {
    NSDateFormatter *dateF = [[NSDateFormatter alloc] init];
    [dateF setDateFormat:@"yyyyMMddHHmmss"];
    return [dateF stringFromDate:[NSDate date]];
}
#pragma mark - 获取文件路径
- (NSString *)getPathByFileName:(NSString *)fileName ofType:(NSString *)type {
    NSString *directory = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES).firstObject;
    NSString *fileDirectory = [[[directory stringByAppendingPathComponent:fileName] stringByAppendingPathExtension:type] stringByAddingPercentEncodingWithAllowedCharacters:[NSCharacterSet URLQueryAllowedCharacterSet]];
    return fileDirectory;
}


#pragma mark - 录音设置

- (void)recordBegin {
    //用默认配置初始化一个recorder
    NSString *doc = [NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES) firstObject];
    NSInteger timeStamp = [[NSDate date] timeIntervalSince1970];
    self.recordPath = [doc stringByAppendingPathComponent:[NSString stringWithFormat:@"%@.wav", @(timeStamp)]];
    
    self.recorder = [[AVAudioRecorder alloc] initWithURL:[NSURL fileURLWithPath:self.recordPath] settings:[self defaultSettingForRecord] error:nil];
    if ([self.recorder prepareToRecord]) {
        [[AVAudioSession sharedInstance] setCategory:AVAudioSessionCategoryPlayAndRecord error:nil];
        [[AVAudioSession sharedInstance] setActive:YES error:nil];
        
        if ([self.recorder record]) {
            
            /* TODO: UI操作 */

            
        }else {
            NSLog(@"音频格式出错,Recorder---%@", self.recorder);
        }
    }
    
}

- (void)recordStop {
    if (self.recorder.isRecording) {
        [self.recorder stop];
    }
}


- (void)wavTransToAmrForSave {

    self.fileRecordName = [self getCurrentTimeString];
    self.amrPath = [self getPathByFileName:self.fileRecordName ofType:@"amr"];
    
    if ([VoiceConvert ConvertWavToAmr:[self.recorder.url path] amrSavePath:self.amrPath]) {
        
    }else {
        NSLog(@"wav转amr失败");
    }
}

- (void)amrTransToWavForPlay {
    self.fileRecordName = [self getCurrentTimeString];
    NSString *convertedPath = [self getPathByFileName:[self.fileRecordName stringByAppendingString:@"_AmrToWav"] ofType:@"wav"];
    
    if ([VoiceConvert ConvertAmrToWav:self.amrPath wavSavePath:convertedPath]) {
        
    }else {
        NSLog(@"amr转wav失败");
    }
}

- (NSDictionary *)defaultSettingForRecord {
    NSMutableDictionary *settings = [NSMutableDictionary dictionary];
    [settings setObject:[NSNumber numberWithFloat:8000.0] forKey:AVSampleRateKey];
    [settings setObject:[NSNumber numberWithInt:kAudioFormatLinearPCM] forKey:AVFormatIDKey];
    [settings setObject:[NSNumber numberWithInt:16] forKey:AVLinearPCMBitDepthKey];
    [settings setObject:[NSNumber numberWithInt:1] forKey:AVNumberOfChannelsKey];
    [settings setObject:[NSNumber numberWithBool:NO] forKey:AVLinearPCMIsFloatKey];
    [settings setObject:[NSNumber numberWithInt:AVAudioQualityMedium] forKey:AVEncoderAudioQualityKey];
    
    return settings;
}





@end
