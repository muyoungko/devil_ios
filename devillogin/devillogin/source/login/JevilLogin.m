//
//  JevilLogin.m
//  devillogin
//
//  Created by Mu Young Ko on 2021/03/23.
//

#import "JevilLogin.h"
#import <devillogin/devillogin-Swift.h>
#import "DevilFacebook.h"
#import "DevilGoogleLogin.h"
#import "DevilAppleLogin.h"

@import devilcore;

@implementation JevilLogin

+ (void)loginKakao:(JSValue *)callback{
    DevilKakaoLogin* kakao = [[DevilKakaoLogin alloc] init];
    [kakao loginWithCompletion:^(id _Nullable user) {
        if(user != nil) {
            user[@"r"] = @TRUE;
            user[@"type"] = @"kakao";
            user[@"identifier"] = user[@"id"];
            user[@"age"] = user[@"age_range"];
            [user removeObjectForKey:@"age_ranage"];
            [user removeObjectForKey:@"id"];
            [callback callWithArguments:@[user]];
        } else
            [callback callWithArguments:@[@{@"r":@FALSE}]];
    }];
}
+ (void)loginFacebook:(JSValue *)callback{
    [DevilFacebook loginWithComplete:^(id _Nullable user) {
        if(user !=nil) {
            user[@"r"] = @TRUE;
            user[@"type"] = @"fb";
            user[@"identifier"] = user[@"id"];
            [user removeObjectForKey:@"id"];
            [callback callWithArguments:@[user]];
        } else
            [callback callWithArguments:@[@{@"r":@FALSE}]];
    }];
}

+ (void)loginGoogle:(JSValue *)callback{
    [[DevilGoogleLogin sharedInstance] loginWithComplete:[JevilInstance currentInstance].vc callback:^(id  _Nonnull user) {
        if(user !=nil) {
            user[@"r"] = @TRUE;
            user[@"type"] = @"google";
            user[@"identifier"] = user[@"id"];
            [user removeObjectForKey:@"id"];
            [callback callWithArguments:@[user]];
        } else
            [callback callWithArguments:@[@{@"r":@FALSE}]];
    }];
}

+ (void)loginApple:(JSValue *)callback{
    [[DevilAppleLogin sharedInstance] loginWithComplete:[JevilInstance currentInstance].vc callback:^(id  _Nonnull user) {
        if(user !=nil) {
            user[@"r"] = @TRUE;
            user[@"type"] = @"apple";
            user[@"identifier"] = user[@"id"];
            [user removeObjectForKey:@"id"];
            [callback callWithArguments:@[user]];
        } else
            [callback callWithArguments:@[@{@"r":@FALSE}]];
    }];
}

+ (BOOL)isLogin{
    return [Jevil get:@"x_access_token_key"] != nil;
}

+ (void)logout{
    [Jevil remove:@"x_access_token_key"];
}

@end
