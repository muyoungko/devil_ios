//
//  DevilMqtt.h
//  devilcore
//
//  Created by Mu Young Ko on 2024/10/10.
//

#import <Foundation/Foundation.h>
#import <MQTTClient/MQTTClient.h>
#import <MQTTClient/MQTTSessionManager.h>

NS_ASSUME_NONNULL_BEGIN

@interface DevilMqtt : NSObject<MQTTSessionDelegate>
+ (DevilMqtt*)sharedInstance;
- (void)connect:(id)param callback:(void (^)(id res))callback;
- (void)subscribe:(id)param callback:(void (^)(id res))callback;
- (void)publish:(id)param callback:(void (^)(id res))callback;
- (void)listen:(void (^)(id res))callback;
- (void)close;

@end

NS_ASSUME_NONNULL_END
