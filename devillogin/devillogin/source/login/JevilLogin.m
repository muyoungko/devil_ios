//
//  JevilLogin.m
//  devillogin
//
//  Created by Mu Young Ko on 2021/03/23.
//

#import "JevilLogin.h"

//#import "devillogin-Swift.h"
#import <devillogin/devillogin-Swift.h>
//@class KakaoWrapper;

@implementation JevilLogin

+ (void)loginKakao:(JSValue *)callback{
    KakaoWrapper* kakao = [[KakaoWrapper alloc] init];
    [kakao loginWithCompletion:^(id _Nullable user) {
        [callback callWithArguments:
         @[@{@"user":user, @"r":@TRUE}]
         ];
    }];
}
+ (void)loginFacebook:(JSValue *)callback{
    
}
+ (void)loginGoogle:(JSValue *)callback{
    
}
+ (void)loginApple:(JSValue *)callback{
    
}
@end
