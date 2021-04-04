//
//  JevilLogin.m
//  devillogin
//
//  Created by Mu Young Ko on 2021/03/23.
//

#import "JevilLogin.h"

#import <devillogin/devillogin-Swift.h>
#import "DevilFacebook.h"

@implementation JevilLogin

+ (void)loginKakao:(JSValue *)callback{
    DevilKakaoLogin* kakao = [[DevilKakaoLogin alloc] init];
    [kakao loginWithCompletion:^(id _Nullable user) {
        if(user != nil)
            [callback callWithArguments:@[@{@"user":user, @"r":@TRUE}]];
        else
            [callback callWithArguments:@[@{@"r":@FALSE}]];
    }];
}
+ (void)loginFacebook:(JSValue *)callback{
    [DevilFacebook loginWithComplete:^(id _Nullable user) {
        if(user !=nil)
            [callback callWithArguments:@[@{@"user":user, @"r":@TRUE}]];
        else
            [callback callWithArguments:@[@{@"r":@FALSE}]];
    }];
}
+ (void)loginGoogle:(JSValue *)callback{
    
}
+ (void)loginApple:(JSValue *)callback{
    
}
@end
