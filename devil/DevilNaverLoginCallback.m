//
//  DevilNaverLoginCallback.m
//  devil
//
//  Created by Mu Young Ko on 2021/05/28.
//  Copyright © 2021 Mu Young Ko. All rights reserved.
//

#import "DevilNaverLoginCallback.h"
#import "AppDelegate.h"
#import "JulyUtil.h"
@import NaverThirdPartyLogin;

@implementation DevilNaverLoginCallback

- (BOOL)handleUrl:(UIApplication *)application
          openURL:(NSURL *)url
          options:(NSDictionary<UIApplicationOpenURLOptionsKey,id> *)options {
    
    return [[NaverThirdPartyLoginConnection getSharedInstance] application:application openURL:url options:options];
}
- (void)login:(UIViewController *)vc clientId:(NSString *)clientId clientSecret:(NSString *)clientSecret{
    NaverThirdPartyLoginConnection *tlogin = [NaverThirdPartyLoginConnection getSharedInstance];
    tlogin.delegate = self;
    [tlogin setConsumerKey:clientId];
    [tlogin setConsumerSecret:clientSecret];
    [tlogin setAppName:@"Devil App Builder"];
    [tlogin setIsInAppOauthEnable:YES];
    [tlogin setIsNaverAppOauthEnable:YES];
    [tlogin setServiceUrlScheme:[NSString stringWithFormat:@"naver%@", clientId]];
    
    //[tlogin performSelector:@selector(requestThirdPartyLogin) withObject:nil afterDelay:4];
    [tlogin requestThirdPartyLogin];
    
}

//네이버 로그인 ~~~~~~~~~~~~~~~~~~~~~~~
- (void)oauth20ConnectionDidOpenInAppBrowserForOAuth:(NSURLRequest *)request{
    
    NSLog(@"oauth20ConnectionDidOpenInAppBrowserForOAuth");
}

- (void)oauth20ConnectionDidFinishRequestACTokenWithAuthCode{
    //네이버 로그인 성공 - 신규
    NSLog(@"oauth20ConnectionDidFinishRequestACTokenWithAuthCode");
    [self afterNaverLogin];
}

- (void)oauth20ConnectionDidFinishRequestACTokenWithRefreshToken{
    //네이버 로그인 성공 - 이미 로그인 상태
    NSLog(@"oauth20ConnectionDidFinishRequestACTokenWithRefreshToken");
    [self afterNaverLogin];
}
- (void)oauth20ConnectionDidFinishDeleteToken{
    NSLog(@"oauth20ConnectionDidFinishDeleteToken");
}
- (void)oauth20Connection:(NaverThirdPartyLoginConnection *)oauthConnection didFailWithError:(NSError *)error{
    NSLog(@"oauth20Connection");
}

- (void)afterNaverLogin{
    
    __block NSString* token = [NaverThirdPartyLoginConnection getSharedInstance].accessToken;
    
    id header = @{
        @"Accept":@"application/json",
        @"Authorization": [NSString stringWithFormat:@"Bearer %@",token]
    };
    [JulyUtil request:@"https://openapi.naver.com/v1/nid/me" header:header complete:^(id  _Nonnull json) {
        id r = r[@"response"];
        __block NSString* email = r[@"email"];
        __block NSString* no = r[@"id"];
        __block NSString* name = r[@"name"];
        __block NSString* profile = r[@"profile_image"];
        [[DevilNaverLogin sharedInstance] naverLoginSuccess:YES userId:no name:name profile:profile email:email token:token];
    }];
}
@end
