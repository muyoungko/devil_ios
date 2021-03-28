//
//  JevilLogin.m
//  devillogin
//
//  Created by Mu Young Ko on 2021/03/23.
//

#import "JevilLogin.h"

#import <devillogin/devillogin-Swift.h>

@class KakaoWrapper;

@implementation JevilLogin

+ (void)loginKakao:(JSValue *)callback{
    KakaoWrapper* kakao = [[KakaoWrapper alloc] init];
    [kakao login];
}
+ (void)loginFacebook:(JSValue *)callback{
    
}
+ (void)loginGoogle:(JSValue *)callback{
    
}
@end
