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
    d.sendVideo = [param[@"isVideoSent"] boolValue];
    d.sendAudio = [param[@"isAudioSent"] boolValue];
    [d connectAsRole];
    
    [JevilInstance currentInstance].forRetain[@"webrtc"] = d;
}

+ (void)startView:(id)param :(JSValue *)callback {
    DevilWebRtcInstance* d = [[DevilWebRtcInstance alloc] init];
    d.regionName = param[@"region"];
    d.channelName = @"test1";
    d.channelARN = param[@"arn"];
    d.accessKey = param[@"accessKeyId"];
    d.secretKey = param[@"secretAccessKey"];
    d.isMaster = [param[@"isMaster"] boolValue];
    d.currentVc = [JevilInstance currentInstance].vc;
    d.channelInfo = param[@"channelInfo"];
    d.sendVideo = [param[@"isVideoSent"] boolValue];
    d.sendAudio = [param[@"isAudioSent"] boolValue];
    [d connectAsRole];
    
    [JevilInstance currentInstance].forRetain[@"webrtc"] = d;
}

@end
