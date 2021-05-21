//
//  DevilSpeech.h
//  devilcore
//
//  Created by Mu Young Ko on 2021/05/21.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@interface DevilSpeech : NSObject

+ (DevilSpeech*)sharedInstance;
- (void)listen:(id)param :(void (^)(id text))callback;

@end

NS_ASSUME_NONNULL_END
