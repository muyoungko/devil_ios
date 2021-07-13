//
//  DevilChat.m
//  devilcore
//
//  Created by Mu Young Ko on 2021/07/12.
//

#import "DevilChat.h"
#import "JevilCtx.h"
#import "JevilInstance.h"

@interface DevilChat()
@property (nonatomic, retain) MQTTSession *session;
@end

@implementation DevilChat

- (void)created {
    [super created];
    NSString* script = self.marketJson[@"created"];
    [self.meta.jevil code:script viewController:[JevilInstance currentInstance].vc data:self.meta.correspondData meta:self.meta];
    
    NSString* mqtt_uri = self.marketJson[@"mqtt_uri"];
    NSURL* uri = [NSURL URLWithString:mqtt_uri];
    
    MQTTCFSocketTransport *transport = [[MQTTCFSocketTransport alloc] init];
    transport.host = uri.host;
    transport.port = 1883;
        
    MQTTSession *session = [[MQTTSession alloc] init];
    self.session = session;
    session.delegate = self;
    session.transport = transport;
    [session connectAndWaitTimeout:10];
//    [session connectWithConnectHandler:^(NSError *error) {
//        if(error == nil && self.chat_room_id) {
//            [self.session subscribeToTopic:self.chat_room_id atLevel:MQTTQosLevelExactlyOnce subscribeHandler:^(NSError *error, NSArray<NSNumber *> *gQoss) {
//
//            }];
//        }
//    }];
    
    
}

- (void)connect {
    
}

- (void)newMessage:(MQTTSession *)session
              data:(NSData *)data
           onTopic:(NSString *)topic
               qos:(MQTTQosLevel)qos
          retained:(BOOL)retained
               mid:(unsigned int)mid {
    NSLog(@"%@", topic);
    NSString* script = self.marketJson[@"message"];
    [self.meta.jevil code:script viewController:[JevilInstance currentInstance].vc data:self.meta.correspondData meta:self.meta];
}

-(NSString*)generateId{
    double timeSince1970 = [[NSDate date] timeIntervalSince1970];
    long a = (long)(timeSince1970*10) % 1000000000L;
    return [NSString stringWithFormat:@"%ld", a];
}



- (void)update:(id)opt {
    [super update:opt];
    self.chat_room_id = opt[@"chat_room_id"];
    [self.session subscribeToTopic:self.chat_room_id atLevel:MQTTQosLevelExactlyOnce subscribeHandler:^(NSError *error, NSArray<NSNumber *> *gQoss) {
        
    }];
}

- (void)pause {
    [super pause];
    [self.session disconnect];
}

- (void)resume {
    [super resume];
    //[self.session connectAndWaitTimeout:10];
}

- (void)destory {
    [super destory];
}

@end
