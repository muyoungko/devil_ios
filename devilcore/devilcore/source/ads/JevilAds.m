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
        if([[[NSBundle mainBundle] bundleIdentifier] isEqualToString:@"kr.co.july.CloudJsonViewer"]){
            NSString* type = param[@"type"];
            if([type isEqualToString:@"interstitial"]) {
                mparam[@"adUnitId"] = @"ca-app-pub-5134106554966339/9537903111";
            }
        }
        
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
        if([[[NSBundle mainBundle] bundleIdentifier] isEqualToString:@"kr.co.july.CloudJsonViewer"]){
            NSString* type = param[@"type"];
            if([type isEqualToString:@"interstitial"]) {
                mparam[@"adUnitId"] = @"ca-app-pub-5134106554966339/9537903111";
            }
        }
        [[DevilSdk sharedInstance].devilSdkGoogleAdsDelegate showAds:param complete:^(id res) {
            [[JevilFunctionUtil sharedInstance] callFunction:callback params:@[res]];
        }];
    } else {
        [[JevilFunctionUtil sharedInstance] callFunction:callback params:@[@{@"r":@FALSE , @"msg":@"no devilSdkGoogleAdsDelegate"}]];
    }
}

@end
