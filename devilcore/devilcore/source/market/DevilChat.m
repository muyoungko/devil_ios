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
@property BOOL connected;
@end

@implementation DevilChat

- (void)created {
    [super created];
}


- (void)connect {
    
    if(self.session) {
        [self.session disconnect];
        self.session = nil;
    }
    NSString* mqtt_uri = self.marketJson[@"mqtt_uri"];
    NSURL* uri = [NSURL URLWithString:mqtt_uri];
    
    MQTTCFSocketTransport *transport = [[MQTTCFSocketTransport alloc] init];
    transport.host = uri.host;
    transport.port = 1883;
        
    MQTTSession *session = [[MQTTSession alloc] init];
    self.session = session;
    session.keepAliveInterval = 10;
    session.delegate = self;
    session.transport = transport;
    self.connected = false;
    
    [session connect];
}

- (void)handleEvent:(MQTTSession *)session event:(MQTTSessionEvent)eventCode error:(NSError *)error{
    if(eventCode == MQTTSessionEventConnected) {
        self.connected = true;
        self.chat_room_id = self.meta.correspondData[@"chat_room_id"];
        self.chat_room_me = self.meta.correspondData[@"chat_room_me"];
        [self.session subscribeToTopic:self.chat_room_id atLevel:MQTTQosLevelExactlyOnce subscribeHandler:^(NSError *error, NSArray<NSNumber *> *gQoss) {
            
        }];
    } else {
        self.connected = false;
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
    NSLog(@"%@", topic);
    NSString* command = [[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding];
    if([command hasPrefix:@"/chat/read"]) {
        id cc = [command componentsSeparatedByString:@"/"];
        NSString* who = cc[3];
        BOOL itsMe = [who isEqualToString:self.chat_room_me];
        if(!itsMe) {
            NSString* script = self.marketJson[@"read"];
            [self.meta.jevil code:script viewController:[JevilInstance currentInstance].vc data:self.meta.correspondData meta:self.meta];
        }
    } else if([command hasPrefix:@"/chat"]) {
        id cc = [command componentsSeparatedByString:@"/"];
        NSString* who = cc[2];
        BOOL itsMe = [who isEqualToString:self.chat_room_me];
        if(!itsMe) {
            NSString* script = self.marketJson[@"message"];
            [self.meta.jevil code:script viewController:[JevilInstance currentInstance].vc data:self.meta.correspondData meta:self.meta];
        }
    }
    
}

-(NSString*)generateId{
    double timeSince1970 = [[NSDate date] timeIntervalSince1970];
    long a = (long)(timeSince1970*10) % 1000000000L;
    return [NSString stringWithFormat:@"%ld", a];
}



- (void)update:(id)opt {
    [super update:opt];
}

- (void)pause {
    [super pause];
    [self.session disconnect];
}

- (void)resume {
    [super resume];
    if(!self.connected)
       [self connect];
}

- (void)destory {
    [self.session disconnect];
    [super destory];
}

@end
