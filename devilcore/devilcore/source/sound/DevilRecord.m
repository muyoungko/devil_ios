//
//  DevilRecord.m
//  devilcore
//
//  Created by Mu Young Ko on 2022/02/01.
//

#import "DevilRecord.h"

@interface DevilRecord()
@property (nonatomic, retain) NSString* targetPath;
@property (nonatomic, retain) AVAudioRecorder* recorder;
@property (nonatomic, retain) AVAudioPlayer* beepPlayer;
@property int tickIndex;
@end

@implementation DevilRecord

+ (DevilRecord*)sharedInstance {
    static DevilRecord *sharedInstance = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        sharedInstance = [[self alloc] init];
        sharedInstance.status = @"none";
    });
    return sharedInstance;
}


- (void)playBeep{
    NSBundle *bundle = [NSBundle bundleForClass:[self class]];
    NSString *path = [bundle pathForResource:@"devil_camera_record" ofType:@"wav"];
    
    NSError *error;
    self.beepPlayer = [[AVAudioPlayer alloc]initWithContentsOfURL:[NSURL fileURLWithPath:path] error:&error];
    self.beepPlayer.numberOfLoops = 1;
    [self.beepPlayer play];
}

- (void)startRecord:(id)param complete:(void (^)(id res))callback{
    self.tickIndex = 0;
    [[AVAudioSession sharedInstance] requestRecordPermission:^(BOOL granted) {
        if (granted) {
            self.status = @"changing";
            self.targetPath = [NSTemporaryDirectory() stringByAppendingPathComponent:[[NSUUID UUID].UUIDString stringByAppendingPathExtension:@"mp4"]];
            NSLog(@"self.targetPath - %@", self.targetPath);
            __block BOOL audioSuccess = [self startAudioSession];
            if(!audioSuccess) {
                self.status = @"none";
                callback(nil);
                return;
            }
            [self playBeep];
            dispatch_time_t popTime = dispatch_time(DISPATCH_TIME_NOW, 0.5f * NSEC_PER_SEC);
            dispatch_after(popTime, dispatch_get_main_queue(), ^{
                BOOL recordSuccess = [self record];
                
                if(audioSuccess && recordSuccess) {
                    self.status = @"recording";
                    callback([@{} mutableCopy]);
                } else {
                    self.status = @"none";
                    callback(nil);
                }
            });
            
        } else {
            callback(nil);
        }
    }];
    
}

- (void)stopRecord:(void (^)(id res))callback{
    if(self.recorder) {
        [self.recorder stop];
        self.recorder = nil;
    }
    self.status = @"none";
    dispatch_time_t popTime = dispatch_time(DISPATCH_TIME_NOW, 0.5f * NSEC_PER_SEC);
    dispatch_after(popTime, dispatch_get_main_queue(), ^{
        callback([@{@"url":self.targetPath} mutableCopy]);
    });
}

- (void)cancel {
    if(self.recorder) {
        [self.recorder stop];
        self.recorder = nil;
    }
    
    if(self.cancelCallback) {
        self.cancelCallback();
        self.cancelCallback = nil;
    }
}

- (BOOL) record
{
    NSError *error;

    // Recording settings
    NSDictionary *settings = @{AVEncoderAudioQualityKey: @(AVAudioQualityMedium),
                                     AVFormatIDKey: @(kAudioFormatMPEG4AAC),
                                     AVEncoderBitRateKey: @(128000),
                                     AVNumberOfChannelsKey: @(1),
                                     AVSampleRateKey: @(44100)};
    

    NSString *pathToSave = self.targetPath;

    // File URL
    NSURL *url = [NSURL fileURLWithPath:pathToSave];

    // Create recorder
    AVAudioRecorder* recorder = nil;
    self.recorder = recorder = [[AVAudioRecorder alloc] initWithURL:url settings:settings error:&error];
    
    if (!recorder)
    {
        NSLog(@"Error establishing recorder: %@", error.localizedFailureReason);
        return NO;
    }

    // Initialize degate, metering, etc.
    recorder.delegate = self;
    recorder.meteringEnabled = YES;
    //self.title = @"0:00";

    if (![recorder prepareToRecord])
    {
        NSLog(@"Error: Prepare to record failed");
        //[self say:@"Error while preparing recording"];
        return NO;
    }

    if (![recorder record])
    {
        NSLog(@"Error: Record failed");
    //  [self say:@"Error while attempting to record audio"];
        return NO;
    }

    return YES;
}


- (BOOL) startAudioSession
{
    // Prepare the audio session
    NSError *error;
    AVAudioSession *session = [AVAudioSession sharedInstance];

    if (![session setCategory:AVAudioSessionCategoryPlayAndRecord error:&error])
    {
        NSLog(@"Error setting session category: %@", error.localizedFailureReason);
        return NO;
    }


    if (![session setActive:YES error:&error])
    {
        NSLog(@"Error activating audio session: %@", error.localizedFailureReason);
        return NO;
    }

    return session.inputIsAvailable;
}

-(void)tick {
    if(self.tickCallback != nil && ![@"none" isEqualToString:self.status]) {
        self.tickCallback(self.tickIndex);
        self.tickIndex ++;
        [self performSelector:@selector(tick) withObject:nil afterDelay:1.0f];
    }
}


@end
