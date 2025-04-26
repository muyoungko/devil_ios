//
//  DevilFacebook.m
//  devillogin
//
//  Created by Mu Young Ko on 2021/04/04.
//

#import "DevilFacebook.h"
//@import FBSDKLoginKit;

@implementation DevilFacebook

+(void)loginWithComplete:(void (^)(id user))callback{
//    FBSDKLoginManager* m = [[FBSDKLoginManager alloc] init];
//    //프로필은 FB 검수 받고 받아와야한다.
//    [m logInWithPermissions:@[@"public_profile", @"email"] fromViewController:self handler:^(FBSDKLoginManagerLoginResult * _Nullable result, NSError * _Nullable error) {
//        if(!error){
//            NSString* token = result.token.tokenString;
//            FBSDKGraphRequest* request = [[FBSDKGraphRequest alloc] initWithGraphPath:@"me" parameters:@{@"fields":@"id,name,email"}];
//            [request startWithCompletion:^(id<FBSDKGraphRequestConnecting>  _Nullable connection, id  _Nullable result, NSError * _Nullable error) {
//                if (!error) {
//                    __block NSString* no = result[@"id"];
//                    id r = [@{} mutableCopy];
//                    r[@"identifier"] = result[@"id"];
//                    r[@"name"] = result[@"name"];
//                    r[@"profile"] = [NSString stringWithFormat:@"http://graph.facebook.com/%@/picture?type=square", no];
//                    r[@"email"] = result[@"email"];
//                    //r["age_range"] = user?.kakaoAccount?.ageRange?.rawValue
//                    //r["gender"] = user?.kakaoAccount?.gender?.rawValue
//                    r[@"token"] = token;
//                    callback(r);
//                } else {
//                    callback(nil);
//                }
//            }];
//        }
//    }];
}

+ (BOOL)application:(UIApplication *)application
            openURL:(NSURL *)url
            options:(NSDictionary<UIApplicationOpenURLOptionsKey,id> *)options {
//    return [[FBSDKApplicationDelegate sharedInstance] application:application
//                                                                  openURL:url
//                                                        sourceApplication:options[UIApplicationOpenURLOptionsSourceApplicationKey]
//                                                               annotation:options[UIApplicationOpenURLOptionsAnnotationKey]
//    ];
    return NO;
}

@end
