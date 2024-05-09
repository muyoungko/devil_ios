//
//  JevilAds.m
//  devilads
//
//  Created by Mu Young Ko on 2022/06/25.
//

#import "JevilAds.h"
#import "DevilSdk.h"
#import "JevilFunctionUtil.h"

@implementation JevilAds

+ (void)loadAds:(NSDictionary*)param:(JSValue *)callback{
    NSMutableDictionary* mparam = [param mutableCopy];
    [[JevilFunctionUtil sharedInstance] registFunction:callback];
    if([DevilSdk sharedInstance].devilSdkGoogleAdsDelegate) {
        [[DevilSdk sharedInstance].devilSdkGoogleAdsDelegate loadAds:param complete:^(id res) {
            [[JevilFunctionUtil sharedInstance] callFunction:callback params:@[res]];
        }];
    } else {
        [[JevilFunctionUtil sharedInstance] callFunction:callback params:@[@{@"r":@FALSE , @"msg":@"no devilSdkGoogleAdsDelegate"}]];
    }
}

+ (void)showAds:(NSDictionary*)param:(JSValue *)callback{
    NSMutableDictionary* mparam = [param mutableCopy];
    [[JevilFunctionUtil sharedInstance] registFunction:callback];
    if([DevilSdk sharedInstance].devilSdkGoogleAdsDelegate) {
        [[DevilSdk sharedInstance].devilSdkGoogleAdsDelegate showAds:param complete:^(id res) {
            [[JevilFunctionUtil sharedInstance] callFunction:callback params:@[res]];
        }];
    } else {
        [[JevilFunctionUtil sharedInstance] callFunction:callback params:@[@{@"r":@FALSE , @"msg":@"no devilSdkGoogleAdsDelegate"}]];
    }
}

@end
