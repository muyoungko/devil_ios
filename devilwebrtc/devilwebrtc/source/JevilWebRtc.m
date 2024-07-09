//
//  JevilWebRtc.m
//  devilwebrtc
//
//  Created by Mu Young Ko on 2023/09/16.
//

#import "JevilWebRtc.h"
#import <devilwebrtc/devilwebrtc-Swift.h>
@import devilcore;

@implementation JevilWebRtc

+ (void)start:(id)param :(JSValue *)callback {
    DevilWebRtcInstance* d = [[DevilWebRtcInstance alloc] init];
    d.regionName = param[@"region"];
    d.channelName = @"test1";
    d.channelARN = param[@"arn"];
    d.accessKey = param[@"accessKeyId"];
    d.secretKey = param[@"secretAccessKey"];
    d.isMaster = [param[@"isMaster"] boolValue];
    d.currentVc = [JevilInstance currentInstance].vc;
    d.channelInfo = param[@"channelInfo"];
    d.wssSignedUrl = param[@"channelInfo"][@"endpointsByProtocol"][@"WSSSignedUrl"];
    d.clientID = param[@"channelInfo"][@"endpointsByProtocol"][@"clientID"];
    d.sendVideo = [param[@"isVideoSent"] boolValue];
    d.sendAudio = [param[@"isAudioSent"] boolValue];
    d.parentView = nil;
    
    
    dispatch_async(dispatch_get_global_queue( DISPATCH_QUEUE_PRIORITY_HIGH, 0), ^(void){
        [d connectAsRole];
    });
    
    [JevilInstance currentInstance].forRetain[@"webrtc"] = d;
}

+ (void)startView:(NSString*)nodeName :(id)param :(JSValue *)callback {
    DevilWebRtcInstance* d = [[DevilWebRtcInstance alloc] init];
    d.regionName = param[@"region"];
    d.channelName = @"test1";
    d.channelARN = param[@"arn"];
    d.accessKey = param[@"accessKeyId"];
    d.secretKey = param[@"secretAccessKey"];
    d.isMaster = [param[@"isMaster"] boolValue];
    d.currentVc = [JevilInstance currentInstance].vc;
    d.channelInfo = param[@"channelInfo"];
    d.wssSignedUrl = param[@"channelInfo"][@"endpointsByProtocol"][@"WSSSignedUrl"];
    d.clientID = param[@"channelInfo"][@"endpointsByProtocol"][@"clientID"];
    d.sendVideo = [param[@"isVideoSent"] boolValue];
    d.sendAudio = [param[@"isAudioSent"] boolValue];
    
    DevilController* dc = (DevilController*)[JevilInstance currentInstance].vc;
    WildCardUIView* view = [dc findView:nodeName];
    
    d.parentView = view;
    dispatch_async(dispatch_get_global_queue( DISPATCH_QUEUE_PRIORITY_HIGH, 0), ^(void){
        [d connectAsRole];
    });
    
    [JevilInstance currentInstance].forRetain[@"webrtc"] = d;
}

+ (void)callback:(JSValue *)callback{
    [[JevilFunctionUtil sharedInstance] registFunction:callback];
    __block DevilWebRtcInstance* d = (DevilWebRtcInstance*)[JevilInstance currentInstance].forRetain[@"webrtc"];
    if(d) {
        d.callback = ^ (id _Nonnull res) {
            dispatch_async(dispatch_get_main_queue(), ^{
                [[JevilFunctionUtil sharedInstance] callFunction:callback params:@[res]];
            });
        };
    }
}
@end
