//
//  DevilRecord.h
//  devilcore
//
//  Created by Mu Young Ko on 2022/02/01.
//

#import <Foundation/Foundation.h>
@import AVKit;

NS_ASSUME_NONNULL_BEGIN

@interface DevilRecord : NSObject<AVAudioRecorderDelegate>

@property (nonatomic, retain) NSString* status;

@property void (^cancelCallback)();
@property void (^tickCallback)(int sec);

+ (DevilRecord*)sharedInstance;
- (void)startRecord:(id)param complete:(void (^)(id res))callback;
- (void)stopRecord:(void (^)(id res))callback;
- (void)cancel;
- (void)tick;

@end

NS_ASSUME_NONNULL_END
