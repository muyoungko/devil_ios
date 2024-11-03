//
//  DevilNfc.h
//  devilcore
//
//  Created by Mu Young Ko on 2022/07/23.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@interface DevilNfcInstance : NSObject

+ (DevilNfcInstance*)sharedInstance;
- (void)start:(id)param :(id (^)(id res))callback;
- (void)stop;

@end

NS_ASSUME_NONNULL_END
