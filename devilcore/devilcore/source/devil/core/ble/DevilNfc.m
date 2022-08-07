//
//  DevilNfc.m
//  devilcore
//
//  Created by Mu Young Ko on 2022/07/23.
//

#import "DevilNfc.h"
#import "DevilSdk.h"

@interface DevilNfc()

@end
@implementation DevilNfc

+ (DevilNfc*)sharedInstance {
    static DevilNfc *sharedInstance = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        sharedInstance = [[self alloc] init];
    });
    return sharedInstance;
}

- (void)start:(id)param :(void (^)(id res))callback {
    if([DevilSdk sharedInstance].devilSdkNfcDelegate) {
        [[DevilSdk sharedInstance].devilSdkNfcDelegate read:@{} complete:^(id  _Nonnull res) {
            callback(res);
        }];
    } else {
        callback(@{@"r":@FALSE , @"msg":@"no devilSdkGoogleAdsDelegate"});
    }
}

- (void)stop {
    if([DevilSdk sharedInstance].devilSdkNfcDelegate) {
        [[DevilSdk sharedInstance].devilSdkNfcDelegate stop:@{} complete:^(id  _Nonnull res) {
//            callback(res);
        }];
    } else {
//        callback(@{@"r":@FALSE , @"msg":@"no devilSdkGoogleAdsDelegate"});
    }
}

@end
