//
//  DevilMqtt.m
//  devilcore
//
//  Created by Mu Young Ko on 2024/10/10.
//

#import "DevilMqtt.h"

@interface DevilMqtt ()
@property void (^callbackConnect)(id res);
@property void (^callbackEvent)(id res);
@property (nonatomic, retain) MQTTSession *session;
@property NSString* reservedTopicToSubscribe;
@end

@implementation DevilMqtt

+ (DevilMqtt*)sharedInstance {
    static DevilMqtt *sharedInstance = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        sharedInstance = [[self alloc] init];
    });
    return sharedInstance;
}

- (void)connect:(id)param callback:(void (^)(id res))callback {
    if(self.session) {
        self.callbackEvent = nil;
        self.callbackConnect = nil;
        [self.session disconnect];
        self.session = nil;
    }
    NSString* mqtt_uri = param[@"url"];
    NSURL* uri = [NSURL URLWithString:mqtt_uri];
    self.callbackConnect = callback;
    self.reservedTopicToSubscribe = param[@"topic"];
    MQTTSession *session = [[MQTTSession alloc] init];
    self.session = session;
    session.keepAliveInterval = 1;
    session.delegate = self;
    
    {
        MQTTCFSocketTransport *transport = [[MQTTCFSocketTransport alloc] init];
        if([uri.scheme isEqualToString:@"mqtt+ssl"])
            transport.tls = YES;
        transport.host = uri.host;
        transport.port = [uri.port intValue];
        session.transport = transport;
    }
    
    if(param[@"username"] && param[@"password"]) {
        session.userName = param[@"username"];
        session.password = param[@"password"];
    }
    self.connected = false;
    [session connectAndWaitTimeout:3];
    
    dispatch_async(dispatch_get_global_queue( DISPATCH_QUEUE_PRIORITY_HIGH, 0), ^(void){
        [session connect];
    });
}

- (void)subscribe:(id)param callback:(void (^)(id res))callback{
    [self.session subscribeToTopic:self.reservedTopicToSubscribe atLevel:MQTTQosLevelExactlyOnce subscribeHandler:^(NSError *error, NSArray<NSNumber *> *gQoss) {
        if(!error) {
            [self callOnMainThread:callback res:@{
                @"r":@TRUE,
            }];
        } else {
            [self callOnMainThread:callback res:@{
                @"r":@FALSE,
            }];
        }
    }];
}

- (void)publish:(id)param callback:(void (^)(id res))callback {
    NSString* topic = param[@"topic"];
    NSString* message = param[@"message"];
    [self.session publishData:[message dataUsingEncoding:NSUTF8StringEncoding] onTopic:topic retain:NO qos:MQTTQosLevelExactlyOnce publishHandler:^(NSError *error) {
        if(!error) {
            [self callOnMainThread:callback res:@{
                @"r":@TRUE,
            }];
        } else {
            [self callOnMainThread:callback res:@{
                @"r":@FALSE,
            }];
        }
    }];
}

- (void)listen:(void (^)(id res))callback {
    self.callbackEvent = callback;
}

- (void)close{
    self.callbackConnect = nil;
    self.callbackEvent = nil;
    [self.session disconnect];
}

//mqtt delegate
- (void)handleEvent:(MQTTSession *)session event:(MQTTSessionEvent)eventCode error:(NSError *)error{
    if(eventCode == MQTTSessionEventConnected) {
        self.connected = true;
        if(self.reservedTopicToSubscribe) {
            [self.session subscribeToTopic:self.reservedTopicToSubscribe atLevel:MQTTQosLevelExactlyOnce subscribeHandler:^(NSError *error, NSArray<NSNumber *> *gQoss) {
                if(!error) {
                    [self callOnMainThread:self.callbackConnect res:@{
                        @"r":@TRUE,
                    }];
                    self.callbackConnect = nil;
                } else {
                    [self callOnMainThread:self.callbackConnect res:@{
                        @"r":@FALSE,
                    }];
                    self.callbackConnect = nil;
                }
            }];
            self.reservedTopicToSubscribe = nil;
        } else {
            [self callOnMainThread:self.callbackConnect res:@{
                @"r":@TRUE,
            }];
            self.callbackConnect = nil;
        }
    } else if(eventCode == MQTTSessionEventConnectionError 
              || eventCode == MQTTSessionEventConnectionClosed
              || eventCode == MQTTSessionEventConnectionClosedByBroker
              || eventCode == MQTTSessionEventConnectionRefused
              || eventCode == MQTTSessionEventProtocolError){
        self.connected = false;
        [self callOnMainThread:self.callbackConnect res:@{
            @"r":@FALSE,
        }];
        self.callbackConnect = nil;
    }
}

- (void)messageDelivered:(MQTTSession *)session msgID:(UInt16)msgID{
    
}

- (void)newMessage:(MQTTSession *)session
              data:(NSData *)data
           onTopic:(NSString *)topic
               qos:(MQTTQosLevel)qos
          retained:(BOOL)retained
               mid:(unsigned int)mid {
    
    NSString* message = [[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding];
    if(self.callbackEvent) {
        [self callOnMainThread:self.callbackEvent res:@{
            @"type":@"message",
            @"topic":topic,
            @"message":message
        }];
    }
}

- (void)connectionClosed:(MQTTSession *)session {
    if(self.callbackEvent) {
        [self callOnMainThread:self.callbackEvent res:@{
            @"type":@"disconnect"
        }];
    }
}

-(void)callOnMainThread:(void (^)(id res))callback res:(id)res {
    if(callback)
        dispatch_async(dispatch_get_main_queue(), ^{
            callback(res);
        });
}
@end
