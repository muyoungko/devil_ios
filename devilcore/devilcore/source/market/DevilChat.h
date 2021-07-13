//
//  DevilChat.h
//  devilcore
//
//  Created by Mu Young Ko on 2021/07/12.
//

#import <Foundation/Foundation.h>
#import "MarketComponent.h"
#import <MQTTClient/MQTTClient.h>
#import <MQTTClient/MQTTSessionManager.h>

NS_ASSUME_NONNULL_BEGIN

@interface DevilChat : MarketComponent<MQTTSessionDelegate>

@property (strong, nonatomic) MQTTSessionManager *manager;
@property MQTTSessionManagerState mainMqttClientState;
@property (strong, nonatomic) NSString* chat_room_id;

@end

NS_ASSUME_NONNULL_END
