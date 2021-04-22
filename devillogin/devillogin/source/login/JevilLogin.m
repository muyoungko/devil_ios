//
//  JevilLogin.m
//  devillogin
//
//  Created by Mu Young Ko on 2021/03/23.
//

#import "JevilLogin.h"
#import <devillogin/devillogin-Swift.h>
#import "DevilFacebook.h"
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
            [callback callWithArguments:@[user]];
        } else
            [callback callWithArguments:@[@{@"r":@FALSE}]];
    }];
}
+ (void)loginGoogle:(JSValue *)callback{
    
}
+ (void)loginApple:(JSValue *)callback{
    
}

+ (BOOL)isLogin{
    NSString* x_access_token_key = [NSString stringWithFormat:@"x-access-token-%@", [Jevil get:@"PROJECT_ID"]];
    return [Jevil get:x_access_token_key] != nil;
}

+ (void)logout{
    NSString* x_access_token_key = [NSString stringWithFormat:@"x-access-token-%@", [Jevil get:@"PROJECT_ID"]];
    [Jevil remove:x_access_token_key];
}

@end
