//
//  WildCardEventTracker.m
//  devilcore
//
//  Created by Mu Young Ko on 2022/10/05.
//

#import "WildCardEventTracker.h"
#import "DevilSdk.h"
#import "WildCardConstructor.h"

@implementation WildCardEventTracker

+(WildCardEventTracker*)sharedInstance{
    static WildCardEventTracker *sharedInstance = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        sharedInstance = [[WildCardEventTracker alloc] init];
    });
    return sharedInstance;
}

-(void)onScreen:(NSString*)projectId screenId:(NSString*)screenId screenName:(NSString*)screenName {
    if([DevilSdk sharedInstance].devilSdkGADelegate) {
        [[DevilSdk sharedInstance].devilSdkGADelegate onScreen:projectId screenId:screenId screenName:screenName];
    }
}

-(void)onClickEvent:(NSString*)viewName data:(id)data{
    if([DevilSdk sharedInstance].devilSdkGADelegate) {
        if([[DevilSdk sharedInstance].devilSdkGADelegate respondsToSelector:@selector(onEventWithGaData:eventType:viewName:gaData:)]) {
            [[DevilSdk sharedInstance].devilSdkGADelegate onEventWithGaData:[WildCardConstructor sharedInstance].project_id eventType:@"click" viewName:viewName gaData:data];
        } else {
            [[DevilSdk sharedInstance].devilSdkGADelegate onEvent:[WildCardConstructor sharedInstance].project_id eventType:@"click" viewName:viewName];
        }
    }
}
@end
