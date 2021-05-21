//
//  DevilSound.h
//  devilcore
//
//  Created by Mu Young Ko on 2021/05/21.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@interface DevilSound : NSObject

+ (DevilSound*)sharedInstance;
- (void)sound:(id)param;
- (void)setTickCallback:(void (^)(int sec, int totalSec))callback;
- (void)stop;
- (void)pause;
- (void)resume;
- (void)move:(int)sec;
- (void)speed:(float)speed;

@end

NS_ASSUME_NONNULL_END
