//
//  DevilChat.m
//  devilcore
//
//  Created by Mu Young Ko on 2021/07/12.
//

#import "DevilChat.h"
#import "JevilCtx.h"
#import "JevilInstance.h"
#import "WildCardCollectionViewAdapter.h"
#import "WildCardUtil.h"
#import "WildCardUIView.h"

@interface DevilChat()
@property (nonatomic, retain) MQTTSession *session;
@property BOOL connected;
@property float originalY;
@property float originalHeight;
@property BOOL originalYinited;
@property BOOL keypadUp;
@end

@implementation DevilChat

- (void)created {
    [super created];
    self.originalYinited = NO;
    self.keypadUp = NO;
}


- (void)connect {
    
    if(self.session) {
        [self.session disconnect];
        self.session = nil;
    }
    NSString* mqtt_uri = self.marketJson[@"mqtt_uri"];
    NSURL* uri = [NSURL URLWithString:mqtt_uri];
    
    MQTTSession *session = [[MQTTSession alloc] init];
    self.session = session;
    session.keepAliveInterval = 10;
    session.delegate = self;
    
    {
        MQTTCFSocketTransport *transport = [[MQTTCFSocketTransport alloc] init];
        if([uri.scheme isEqualToString:@"mqtt+ssl"])
            transport.tls = YES;
        transport.host = uri.host;
        transport.port = [uri.port intValue];
        session.transport = transport;
    }
    
    if(self.marketJson[@"username"]) {
        session.userName = self.marketJson[@"username"];
        session.password = self.marketJson[@"password"];
    }
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



- (void)update:(JSValue*)opt {
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

- (void)destroy {
    [self.session disconnect];
    [super destroy];
}

-(void)keypad:(BOOL)up :(CGRect)keyboardRect {
    WildCardUIView* v = (WildCardUIView*)[self.meta getView:@"chat_list"];
    UICollectionView* list = [self.meta getList:@"chat_list"];
    WildCardCollectionViewAdapter* adapter = (WildCardCollectionViewAdapter*)list.delegate;
    
    id childs = [list subviews];
    float maxY = 0;
    for (UIView* child in childs) {
        if(![child isKindOfClass:[UICollectionViewCell class]])
            continue;
        CGRect f = [WildCardUtil getGlobalFrame:child];
        float thisY = f.origin.y + f.size.height;
        if(thisY > maxY)
            maxY = thisY;
    }
    
    float sh = [UIScreen mainScreen].bounds.size.height;
    BOOL shouldAdjust = NO;
    if(maxY > sh/2) {
        shouldAdjust = YES;
    }
    
    
    float bottomPadding = 0;
    if (@available(iOS 11.0, *)) {
        UIWindow *window = UIApplication.sharedApplication.windows.firstObject;
        bottomPadding = window.safeAreaInsets.bottom;
    }
    
    if(!self.originalYinited) {
        self.originalY = v.frame.origin.y;
        self.originalHeight = v.frame.size.height;
        self.originalYinited = YES;
    }
    
    if(up && !self.keypadUp && shouldAdjust) {
        self.keypadUp = YES;
        v.frameUpdateAvoid = YES;
        [UIView animateWithDuration:0.15f animations:^{
            v.frame = CGRectMake(v.frame.origin.x, v.frame.origin.y, v.frame.size.width,
                                 self.originalHeight - keyboardRect.size.height + bottomPadding
                                 );
        } completion:^(BOOL finished) {
            [list scrollToItemAtIndexPath:[NSIndexPath indexPathForItem:([adapter getCount]-1) inSection:0] atScrollPosition:UICollectionViewScrollPositionBottom animated:YES];
        }];
    } else if(!up && self.keypadUp) {
        self.keypadUp = NO;
        v.frameUpdateAvoid = NO;
        [UIView animateWithDuration:0.15f animations:^{
            v.frame = CGRectMake(v.frame.origin.x, self.originalY, v.frame.size.width, self.originalHeight);
        }];
    }
}

@end
