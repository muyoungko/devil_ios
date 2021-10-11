//
//  DevilSound.h
//  devilcore
//
//  Created by Mu Young Ko on 2021/05/21.
//

#import <Foundation/Foundation.h>
#import <AudioToolbox/AudioToolbox.h>
#import <AVFoundation/AVFoundation.h>

NS_ASSUME_NONNULL_BEGIN

@interface DevilSound : NSObject

@property (nonatomic,retain) id currentInfo;

+ (DevilSound*)sharedInstance;
- (void)sound:(id)param;
- (id)currentInfo;
- (void)setSoundCallback:(void (^)(id res))callback;
- (void)setControlCallback:(void (^)(NSString* command))callback;
- (void)setTickCallback:(void (^)(int sec, int totalSec))callback;
- (void)stop;
- (BOOL)isPlaying;
- (void)pause;
- (void)resume;
- (void)move:(int)sec;
- (void)seek:(int)sec;
- (void)speed:(float)speed;

@end

NS_ASSUME_NONNULL_END
