//
//  DevilSound.m
//  devilcore
//
//  Created by Mu Young Ko on 2021/05/21.
//

#import "DevilSound.h"
#import "DevilUtil.h"
#import <CoreHaptics/CoreHaptics.h>

@import UIKit;
@import MediaPlayer;

@interface DevilSound () <AVAudioPlayerDelegate>
@property (nonatomic,retain) AVPlayer *player;
@property (nonatomic,retain) id observer;
@property void (^callback)(int sec, int totalSec);
@property void (^callbackSound)(id res);
@property void (^callbackControl)(NSString* command);
@property (nonatomic,retain) id lockScreenInfo;
@property BOOL music;
@property float speed;
@property NSTimeInterval lastMoveTime;
@property (nonatomic,retain) AVPlayer *recentAvPlayerCompleteCalled;
@property (nonatomic, strong) CHHapticEngine *hapticEngine;

@end


@implementation DevilSound

+ (DevilSound*)sharedInstance {
    static DevilSound *sharedInstance = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        sharedInstance = [[self alloc] init];
        sharedInstance.speed = 1.0f;
        [[NSNotificationCenter defaultCenter] addObserver:sharedInstance selector:@selector(audioPlayerDidFinishPlaying:) name:AVPlayerItemDidPlayToEndTimeNotification object:sharedInstance.player.currentItem];
    });
    return sharedInstance;
}

- (void)sound:(id)param{
    self.currentInfo = param;
    self.currentInfo[@"playing"] = @"Y";
    
    if(self.player != nil) {
        [self.player pause];
        [self.player removeTimeObserver:self.observer];
        self.player = nil;
        self.observer = nil;
    }
    NSString* url = param[@"url"];
    int start = [param[@"start"] intValue];
    if([url hasPrefix:@"http"])
        self.player = [AVPlayer playerWithURL:[NSURL URLWithString:url]];
    else {
        url = [DevilUtil replaceUdidPrefixDir:url];
        self.player = [AVPlayer playerWithURL:[NSURL fileURLWithPath:url]];
    }
    
    [self.player play];
    self.player.rate = self.speed;
    if(start > 0)
        [self.player seekToTime:CMTimeMake(start, 1)];
    
    BOOL exsits = [[NSFileManager defaultManager] fileExistsAtPath:url];
    self.music = param[@"music"] ? [param[@"music"] boolValue] : true;
    if(self.music) {
        NSError *sessionError = nil;
        [[AVAudioSession sharedInstance] setCategory:AVAudioSessionCategoryPlayback error:&sessionError];
        [[AVAudioSession sharedInstance] setActive:YES error:nil];
        [[AVAudioSession sharedInstance] setMode:AVAudioSessionModeMoviePlayback error:nil];
        [[UIApplication sharedApplication] beginReceivingRemoteControlEvents];
        
        [self setUpRemoteCommandCenter:param];
    }
}


-(void)audioPlayerDidFinishPlaying:(id)notification{
    if(self.recentAvPlayerCompleteCalled != self.player) {
        self.recentAvPlayerCompleteCalled = self.player;
        id r = [@{} mutableCopy];
        r[@"command"] = @"complete";
        
        if(self.callbackSound)
            self.callbackSound(r);
        
        if(self.callbackControl)
            self.callbackControl(@"complete");
    }
}

-(void)setUpRemoteCommandCenter:(id)param {
    NSString* title = param[@"title"];
    // Provides all audio data to be displayed to user in lock screen
    self.lockScreenInfo = [[NSMutableDictionary alloc] initWithObjectsAndKeys:
                           title==nil?@"player":title, MPMediaItemPropertyTitle,
                           [NSNumber numberWithDouble:CMTimeGetSeconds(self.player.currentItem.duration)], MPMediaItemPropertyPlaybackDuration,
                           [NSNumber numberWithDouble:CMTimeGetSeconds(self.player.currentItem.currentTime)], MPNowPlayingInfoPropertyElapsedPlaybackTime,
                           [NSNumber numberWithDouble:1], MPNowPlayingInfoPropertyPlaybackRate,
                           nil];
    
    if(param[@"artist"])
        self.lockScreenInfo[MPMediaItemPropertyArtist] = param[@"artist"];
    
    if(param[@"artwork"]) {
        NSString* url = param[@"artwork"];
        NSURLSessionDataTask* task = [[NSURLSession sharedSession] dataTaskWithRequest:[NSURLRequest requestWithURL:[NSURL URLWithString:url]] completionHandler:^(NSData * _Nullable data, NSURLResponse * _Nullable response, NSError * _Nullable error) {
            if(data) {
                __block UIImage* img = [UIImage imageWithData:data];
                self.lockScreenInfo[MPMediaItemPropertyArtwork] = [[MPMediaItemArtwork alloc] initWithBoundsSize:img.size  requestHandler:^UIImage * _Nonnull(CGSize size) {
                    return img;
                }];
                [[MPNowPlayingInfoCenter defaultCenter] setNowPlayingInfo:self.lockScreenInfo];
            }
        }];
        [task resume];
    }
    
    [[MPNowPlayingInfoCenter defaultCenter] setNowPlayingInfo:self.lockScreenInfo];
    
    // For lock screen & remote audio controls
    MPRemoteCommandCenter *remoteCommandCenter = [MPRemoteCommandCenter sharedCommandCenter];
    
    [remoteCommandCenter.stopCommand setEnabled:YES];
    [remoteCommandCenter.stopCommand addTargetWithHandler:^MPRemoteCommandHandlerStatus(MPRemoteCommandEvent * _Nonnull event) {
        [self pause];
        return MPRemoteCommandHandlerStatusSuccess;
    }];
    
    [remoteCommandCenter.playCommand setEnabled:YES];
    [remoteCommandCenter.playCommand addTargetWithHandler:^MPRemoteCommandHandlerStatus(MPRemoteCommandEvent * _Nonnull event) {
        [self resume];
        return MPRemoteCommandHandlerStatusSuccess;
    }];
    
    [remoteCommandCenter.togglePlayPauseCommand setEnabled:YES];
    [remoteCommandCenter.togglePlayPauseCommand addTargetWithHandler:^MPRemoteCommandHandlerStatus(MPRemoteCommandEvent * _Nonnull event) {
        if([self isPlaying]){
            [self pause];
            if(self.callbackControl)
                self.callbackControl(@"pause");
        }else{
            [self resume];
            if(self.callbackControl)
                self.callbackControl(@"resume");
        }
        return MPRemoteCommandHandlerStatusSuccess;
    }];
    
    [remoteCommandCenter.pauseCommand setEnabled:YES];
    [remoteCommandCenter.pauseCommand addTargetWithHandler:^MPRemoteCommandHandlerStatus(MPRemoteCommandEvent * _Nonnull event) {
        [self pause];
        if(self.callbackControl)
            self.callbackControl(@"pause");
        return MPRemoteCommandHandlerStatusSuccess;
    }];
    
    [remoteCommandCenter.skipBackwardCommand setEnabled:YES];
    [remoteCommandCenter.skipBackwardCommand addTargetWithHandler:^MPRemoteCommandHandlerStatus(MPRemoteCommandEvent * _Nonnull event) {
        [self move:-15];
        if(self.callbackControl)
            self.callbackControl(@"move");
        return MPRemoteCommandHandlerStatusSuccess;
    }];
    remoteCommandCenter.skipBackwardCommand.preferredIntervals = @[@(15)];
    
    [remoteCommandCenter.skipForwardCommand setEnabled:YES];
    [remoteCommandCenter.skipForwardCommand addTargetWithHandler:^MPRemoteCommandHandlerStatus(MPRemoteCommandEvent * _Nonnull event) {
        [self move:15];
        if(self.callbackControl)
            self.callbackControl(@"move");
        return MPRemoteCommandHandlerStatusSuccess;
    }];
    remoteCommandCenter.skipForwardCommand.preferredIntervals = @[@(15)];
    
    // Drag slider to change audio position
    // Check for iOS version here (later than iOS 9.0)
    if (floor(NSFoundationVersionNumber) > NSFoundationVersionNumber_iOS_9_0) {
        [remoteCommandCenter.changePlaybackPositionCommand setEnabled:YES];
        [remoteCommandCenter.changePlaybackPositionCommand addTargetWithHandler:^MPRemoteCommandHandlerStatus(MPRemoteCommandEvent * _Nonnull event) {
            
            [self seek:((MPChangePlaybackPositionCommandEvent*)event).positionTime];
            return MPRemoteCommandHandlerStatusSuccess;
        }];
    }
}


- (void)setSoundCallback:(void (^)(id res))callback{
    self.callbackSound = callback;
}

- (void)setControlCallback:(void (^)(NSString* command))callback{
    self.callbackControl = callback;
}

-(void)setTickCallback:(void (^)(int sec, int totalSeconds))callback{
    self.callback = callback;
    if(callback != nil && self.player != nil) {
        if(self.observer != nil) {
            [self.player removeTimeObserver:self.observer];
            self.observer = nil;
        }
        self.observer = [self.player addPeriodicTimeObserverForInterval:CMTimeMake(1, 1)
                                                                  queue:NULL // main queue
                                                             usingBlock:^(CMTime time) {
            
            NSTimeInterval now = [[NSDate date] timeIntervalSince1970];
            //NSLog(@"%f", now);
            if(now - self.lastMoveTime < 1)
                return;
            
            CMTime currentPosition = self.player.currentItem.currentTime;
            int currentPositionSec = (int)(currentPosition.value / currentPosition.timescale);
            
            CMTime duration = self.player.currentItem.duration;
            int durationSec = (int)(duration.value / duration.timescale);
            
            self.currentInfo[@"currentPosition"] = [NSNumber numberWithInt:currentPositionSec];
            self.currentInfo[@"duration"] = [NSNumber numberWithInt:durationSec];
            
            float totalSeconds = (Float64)(time.value) / (Float64)(time.timescale);
            CMTime du = self.player.currentItem.duration;
            if(self.callback != nil)
                self.callback((int)totalSeconds, (int)(du.value / du.timescale));
            
            self.lockScreenInfo[MPNowPlayingInfoPropertyElapsedPlaybackTime] = [NSNumber numberWithDouble:CMTimeGetSeconds(self.player.currentItem.currentTime)];
            self.lockScreenInfo[MPMediaItemPropertyPlaybackDuration] = [NSNumber numberWithDouble:CMTimeGetSeconds(self.player.currentItem.duration)];
            [[MPNowPlayingInfoCenter defaultCenter] setNowPlayingInfo:self.lockScreenInfo];
        }];
    }
}

- (void)stop{
    if(self.player != nil) {
        [self.player pause];
        [self.player removeTimeObserver:self.observer];
        self.observer = nil;
        self.player = nil;
        [[MPNowPlayingInfoCenter defaultCenter] setNowPlayingInfo:nil];
        [[AVAudioSession sharedInstance] setActive:NO error:nil];
    }
    self.currentInfo = nil;
}

- (BOOL)isPlaying{
    if(self.player != nil) {
        return self.player.timeControlStatus == AVPlayerTimeControlStatusPlaying;
    }
    return false;
}

- (void)pause{
    if(self.player != nil) {
        [self.player pause];
        self.currentInfo[@"playing"] = @"N";
    }
}

- (void)resume{
    if(self.player != nil) {
        [self.player play];
        self.player.rate = self.speed;
        self.currentInfo[@"playing"] = @"Y";
    }
}

- (void)move:(int)sec{
    if(self.player != nil){
        CMTime cur = self.player.currentItem.currentTime;
        int curSec = (int)(cur.value / cur.timescale);
        [self.player seekToTime:CMTimeMake(curSec + sec, 1)];
        self.lastMoveTime = [[NSDate date] timeIntervalSince1970];
    }
}

- (void)seek:(int)sec{
    if(self.player != nil){
        [self.player seekToTime:CMTimeMake(sec, 1)];
        self.lastMoveTime = [[NSDate date] timeIntervalSince1970];
    }
}
- (void)speed:(float)speed{
    if(self.player != nil && [self isPlaying])
        self.player.rate = speed;
    self.speed = speed;
}

- (void)stopIfNotMusic{
    if(!self.music) {
        [self pause];
    }
}

- (void)vibrate:(id)param {
    NSError *error = nil;
    if(!self.hapticEngine) {
        self.hapticEngine = [[CHHapticEngine alloc] initAndReturnError:&error];
        if (error) {
            NSLog(@"Haptic Engine Error: %@", error.localizedDescription);
        } else {
            [self.hapticEngine startAndReturnError:&error];
        }
    }
    
    CHHapticEventParameter *intensity = [[CHHapticEventParameter alloc] initWithParameterID:CHHapticEventParameterIDHapticIntensity value:1.0];
    CHHapticEventParameter *sharpness = [[CHHapticEventParameter alloc] initWithParameterID:CHHapticEventParameterIDHapticSharpness value:1.0];
    
    NSMutableArray *events = [NSMutableArray array];
    if(param[@"duration"]) {
        CHHapticEvent *event = [[CHHapticEvent alloc] initWithEventType:CHHapticEventTypeHapticTransient parameters:@[intensity, sharpness] relativeTime:0];
        [events addObject:event];
    } else if(param[@"pattern"]) {

        // 첫 번째 진동 (0초부터 0.1초간 강한 진동)
        CHHapticEvent *event1 = [[CHHapticEvent alloc] initWithEventType:CHHapticEventTypeHapticTransient
                                                              parameters:@[
                                                                  [[CHHapticEventParameter alloc] initWithParameterID:CHHapticEventParameterIDHapticIntensity value:1.0],
                                                                  [[CHHapticEventParameter alloc] initWithParameterID:CHHapticEventParameterIDHapticSharpness value:1.0]
                                                              ]
                                                             relativeTime:0];

        // 두 번째 진동 (0.3초 후 0.2초간 약한 진동)
        CHHapticEvent *event2 = [[CHHapticEvent alloc] initWithEventType:CHHapticEventTypeHapticTransient
                                                              parameters:@[
                                                                  [[CHHapticEventParameter alloc] initWithParameterID:CHHapticEventParameterIDHapticIntensity value:0.5],
                                                                  [[CHHapticEventParameter alloc] initWithParameterID:CHHapticEventParameterIDHapticSharpness value:0.5]
                                                              ]
                                                             relativeTime:0.3];

        [events addObjectsFromArray:@[event1, event2]];
    }
    
    
    CHHapticPattern *pattern = [[CHHapticPattern alloc] initWithEvents:events parameters:@[] error:&error];
    if (error) {
        NSLog(@"Haptic Pattern Error: %@", error.localizedDescription);
        return;
    }
    
    id<CHHapticPatternPlayer> player = [self.hapticEngine createPlayerWithPattern:pattern error:&error];
    if (error) {
        NSLog(@"Haptic Player Error: %@", error.localizedDescription);
        return;
    }
    
    [player startAtTime:0 error:&error];
    if (error) {
        NSLog(@"Haptic Play Error: %@", error.localizedDescription);
    }
}

@end
