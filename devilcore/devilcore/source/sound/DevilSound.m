//
//  DevilSound.m
//  devilcore
//
//  Created by Mu Young Ko on 2021/05/21.
//

#import "DevilSound.h"
#import <AudioToolbox/AudioToolbox.h>
#import <AVFoundation/AVFoundation.h>
@import UIKit;

@interface DevilSound () <AVAudioPlayerDelegate>
@property (nonatomic,retain) AVPlayer *player;
@property (nonatomic,retain) id observer;
@property void (^callback)(int sec, int totalSec);
@end


@implementation DevilSound

+ (DevilSound*)sharedInstance {
    static DevilSound *sharedInstance = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        sharedInstance = [[self alloc] init];
    });
    return sharedInstance;
}

- (void)sound:(id)param{
    if(self.player != nil) {
        [self.player pause];
        [self.player removeTimeObserver:self.observer];
        self.player = nil;
        self.observer = nil;
    }
    NSString* url = param[@"url"];
    int start = [param[@"start"] intValue];
    self.player = [AVPlayer playerWithURL:[NSURL URLWithString:url]];
    [self.player play];
    if(start > 0)
        [self.player seekToTime:CMTimeMake(start, 1)];
}

-(void)audioPlayerDidFinishPlaying:(AVAudioPlayer *)player successfully:(BOOL)flag{
    NSLog(@"%d",flag);

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

            float totalSeconds = (Float64)(time.value) / (Float64)(time.timescale);
            CMTime du = self.player.currentItem.duration;
            if(self.callback != nil)
                self.callback((int)totalSeconds, (int)(du.value / du.timescale));
        }];
    }
}

- (void)stop{
    if(self.player != nil) {
        [self.player pause];
        [self.player removeTimeObserver:self.observer];
        self.observer = nil;
        self.player = nil;
    }
}
- (void)pause{
    if(self.player != nil) {
        [self.player pause];
    }
}
- (void)resume{
    if(self.player != nil) {
        [self.player play];
    }
}
- (void)move:(int)sec{
    if(self.player != nil){
        CMTime cur = self.player.currentItem.currentTime;
        int curSec = (int)(cur.value / cur.timescale);
        [self.player seekToTime:CMTimeMake(curSec + sec, 1)];
    }
}
- (void)speed:(float)speed{
    if(self.player != nil)
        self.player.rate = speed;
}
@end
