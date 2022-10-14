//
//  DevilLoginSdk.m
//  devillogin
//
//  Created by Mu Young Ko on 2021/04/04.
//

#import "DevilLoginSdk.h"
#import "DevilFacebook.h"
#import "DevilGoogleLogin.h"
#import "DevilNaverLogin.h"
#import <devillogin/devillogin-Swift.h>
#import "JevilLogin.h"


@import devilcore;
//@import FBSDKLoginKit;

@implementation DevilLoginSdk

+ (void)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions {
    [[DevilSdk sharedInstance] addCustomJevil:[JevilLogin class]];
    NSString* path = [[NSBundle mainBundle] pathForResource:@"devil" ofType:@"plist"];
    id devilConfig = [[NSDictionary alloc] initWithContentsOfFile:path];
    if([devilConfig[@"hasKakaoLogin"] boolValue]){
        [DevilKakaoLogin initKakaoAppKey];
    }
    
//    if([devilConfig[@"hasFacebookLogin"] boolValue]){
//        [[FBSDKApplicationDelegate sharedInstance] application:application didFinishLaunchingWithOptions:launchOptions];
//    }
}

+ (BOOL)application:(UIApplication *)application
            openURL:(NSURL *)url
            options:(NSDictionary<UIApplicationOpenURLOptionsKey,id> *)options{
    
    NSString* path = [[NSBundle mainBundle] pathForResource:@"devil" ofType:@"plist"];
    id devilConfig = [[NSDictionary alloc] initWithContentsOfFile:path];
    
    if([devilConfig[@"hasKakaoLogin"] boolValue] && [DevilKakaoLogin handleOpenUrl:url])
        return true;
    
//    if([devilConfig[@"hasFacebookLogin"] boolValue] &&
//       [[FBSDKApplicationDelegate sharedInstance] application:application
//                                                                  openURL:url
//                                                        sourceApplication:options[UIApplicationOpenURLOptionsSourceApplicationKey]
//                                                               annotation:options[UIApplicationOpenURLOptionsAnnotationKey]])
//        return true;
    
    
    if([devilConfig[@"hasGoogleLogin"] boolValue] &&
       [DevilGoogleLogin application:application openURL:url options:options])
        return true;
    
    if([devilConfig[@"hasNaverLogin"] boolValue] &&
       [DevilNaverLogin application:application openURL:url options:options])
        return true;
    
    return false;
}

@end
