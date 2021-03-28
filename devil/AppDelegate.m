//
//  AppDelegate.m
//  CloudJsonViewer
//
//  Created by Mu Young Ko on 2018. 6. 18..
//  Copyright © 2018년 Mu Young Ko. All rights reserved.
//

#import <UserNotifications/UserNotifications.h>
#define SYSTEM_VERSION_GRATERTHAN_OR_EQUALTO(v)  ([[[UIDevice currentDevice] systemVersion] compare:v options:NSNumericSearch] != NSOrderedAscending)

#import <FBSDKCoreKit/FBSDKCoreKit.h>
#import <KakaoOpenSDK/KakaoOpenSDK.h>
#import <AFNetworking/AFNetworking.h>
#import "UIImageView+AFNetworking.h"
#import "Devil.h"

#import "FirstController.h"
#import "MainController.h"
#import "Lang.h"
#import "JulyUtil.h"
#import "DeepLink.h"

@import Firebase;
@import CoreData;
@import GoogleMobileAds;

#import "AppDelegate.h"
#import "devillogin/devillogin-Swift.h"

@interface AppDelegate ()

@end

@implementation AppDelegate


- (void)application:(UIApplication *)application didRegisterForRemoteNotificationsWithDeviceToken:(NSData *)deviceToken
{
    NSLog(@"pushKey - %@",deviceToken);
    [FIRMessaging messaging].APNSToken = deviceToken;
}


- (void)userNotificationCenter:(UNUserNotificationCenter *)center
       willPresentNotification:(UNNotification *)notification
         withCompletionHandler:(void (^)(UNNotificationPresentationOptions))completionHandler {
    NSDictionary *userInfo = notification.request.content.userInfo;
    
    // With swizzling disabled you must let Messaging know about the message, for Analytics
    [[FIRMessaging messaging] appDidReceiveMessage:userInfo];
    
    // Print message ID.
    if (userInfo[kGCMMessageIDKey]) {
        NSLog(@"Message ID: %@", userInfo[kGCMMessageIDKey]);
    }
    
    // Print full message.
    NSLog(@"%@", userInfo);
    
    // Change this to your preferred presentation option
    completionHandler(UNNotificationPresentationOptionAlert);
}

NSString *const kGCMMessageIDKey = @"gcm.message_id";
//알림을 클릭했을 때
- (void)userNotificationCenter:(UNUserNotificationCenter *)center didReceiveNotificationResponse:(UNNotificationResponse *)response
         withCompletionHandler:(void(^)(void))completionHandler {
    NSDictionary *userInfo = response.notification.request.content.userInfo;
    if (userInfo[kGCMMessageIDKey]) {
        NSLog(@"Message ID: %@", userInfo[kGCMMessageIDKey]);
    }
    
    // Print full message.
    NSLog(@"%@", userInfo);
    
    completionHandler();
}



//- (void)messaging:(FIRMessaging *)messaging didReceiveMessage:(FIRMessagingRemoteMessage *)remoteMessage
//NS_SWIFT_NAME(messaging(_:didReceive:))
//__IOS_AVAILABLE(10.0){
//    NSLog(@"didReceiveMessage");
//}

- (void)messaging:(FIRMessaging *)messaging didReceiveRegistrationToken:(NSString *)fcmToken {
    NSLog(@"FCM registration token: %@", fcmToken);
    // Notify about received token.
    NSDictionary *dataDict = [NSDictionary dictionaryWithObject:fcmToken forKey:@"token"];
    [[NSNotificationCenter defaultCenter] postNotificationName:
     @"FCMToken" object:nil userInfo:dataDict];
    
    [[NSUserDefaults standardUserDefaults] setObject:fcmToken forKey:@"FCM"];
    [[NSUserDefaults standardUserDefaults] synchronize];
    
    [[Devil sharedInstance] sendPush];
}

- (void)registerForRemoteNotifications {
    if(SYSTEM_VERSION_GRATERTHAN_OR_EQUALTO(@"10.0")){
        UNUserNotificationCenter *center = [UNUserNotificationCenter currentNotificationCenter];
        [center requestAuthorizationWithOptions:(UNAuthorizationOptionSound | UNAuthorizationOptionAlert | UNAuthorizationOptionBadge) completionHandler:^(BOOL granted, NSError * _Nullable error){
            if(!error){
                
            }
        }];
    }
    else {
        // Code for old versions
    }
}


- (void) preparePushToken:(UIApplication *)application {
    if ([UNUserNotificationCenter class] != nil) {
      // iOS 10 or later
      // For iOS 10 display notification (sent via APNS)
      [UNUserNotificationCenter currentNotificationCenter].delegate = self;
      UNAuthorizationOptions authOptions = UNAuthorizationOptionAlert |
          UNAuthorizationOptionSound | UNAuthorizationOptionBadge;
      [[UNUserNotificationCenter currentNotificationCenter]
          requestAuthorizationWithOptions:authOptions
          completionHandler:^(BOOL granted, NSError * _Nullable error) {
            // ...
          }];
    } else {
      // iOS 10 notifications aren't available; fall back to iOS 8-9 notifications.
      UIUserNotificationType allNotificationTypes =
      (UIUserNotificationTypeSound | UIUserNotificationTypeAlert | UIUserNotificationTypeBadge);
      UIUserNotificationSettings *settings =
      [UIUserNotificationSettings settingsForTypes:allNotificationTypes categories:nil];
      [application registerUserNotificationSettings:settings];
    }
    
    [application registerForRemoteNotifications];
    [FIRMessaging messaging].delegate = self;
}


- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions {
    [FIRApp configure];
    
    [[DevilSdk sharedInstance] addCustomJevil:[JevilLogin class]];
    
    [KakaoWrapper initKakaoAppKey];
    
    if(launchOptions == nil){
        [self preparePushToken:application];
    }
    
    [[NSUserDefaults standardUserDefaults] setObject:[[[UIDevice currentDevice] identifierForVendor] UUIDString] forKey:@"UDID"];
    [[NSUserDefaults standardUserDefaults] setObject:@"iphone" forKey:@"MODEL"];
    [[NSUserDefaults standardUserDefaults] setObject:@"iOS" forKey:@"OS"];
    [[NSUserDefaults standardUserDefaults] setObject:[[UIDevice currentDevice] systemVersion] forKey:@"OS_VERSION"];
    [[NSUserDefaults standardUserDefaults] setObject:[[NSBundle mainBundle] objectForInfoDictionaryKey:@"CFBundleShortVersionString"] forKey:@"APP_VERSION"];
    [[NSUserDefaults standardUserDefaults] synchronize];
    
    [[GADMobileAds sharedInstance] startWithCompletionHandler:nil];
    
    [GIDSignIn sharedInstance].clientID = [FIRApp defaultApp].options.clientID;
    //@"687771278429-9nph2n6eh4e7jeh1ai1jqiif0i4ivbte.apps.googleusercontent.com";
    [GIDSignIn sharedInstance].delegate = self;
    
    [UIApplication sharedApplication].applicationIconBadgeNumber=0;
    
    [[FBSDKApplicationDelegate sharedInstance] application:application didFinishLaunchingWithOptions:launchOptions];
    
    [WildCardConstructor sharedInstance:@"1605234988599"];
    [WildCardConstructor sharedInstance].delegate = self;
    [WildCardConstructor sharedInstance].textConvertDelegate = self;
    [WildCardConstructor sharedInstance].textTransDelegate = self;
    [WildCardConstructor sharedInstance].xButtonImageName = @"xbutton";
    
    self.window = [[UIWindow alloc] initWithFrame:UIScreen.mainScreen.bounds];
    UIViewController* vc = [[FirstController alloc] initWithNibName:@"FirstController" bundle:nil];
    self.navigationController = [[UINavigationController alloc] initWithRootViewController:vc];
    
    self.window.rootViewController = self.navigationController;
    [self.window makeKeyAndVisible];
        
    return YES;
}

- (void)applicationDidEnterBackground:(UIApplication *)application {
     NSLog(@"app will enter foreground");
}

- (void)applicationWillTerminate:(UIApplication *)application {
    
}
- (void)applicationWillEnterForeground:(UIApplication *)application{
    NSLog(@"applicationWillEnterForeground");
}

- (void)applicationDidBecomeActive:(UIApplication *)application{
     NSLog(@"app did become active");
}



//이미 앱을 설치 했다면
- (BOOL)application:(UIApplication *)application continueUserActivity:(nonnull NSUserActivity *)userActivity restorationHandler:
    #if defined(__IPHONE_12_0) && (__IPHONE_OS_VERSION_MAX_ALLOWED >= __IPHONE_12_0)
        (nonnull void (^)(NSArray<id<UIUserActivityRestoring>> *_Nullable))restorationHandler {
    #else
        (nonnull void (^)(NSArray *_Nullable))restorationHandler {
    #endif  // __IPHONE_12_0
    
    BOOL handled = [[FIRDynamicLinks dynamicLinks] handleUniversalLink:userActivity.webpageURL
                                                                completion:^(FIRDynamicLink * _Nullable dynamicLink,
                                                                             NSError * _Nullable error) {
                                                                    
        NSLog(@"%@", dynamicLink.url);
        
        [[DeepLink sharedInstance] reserveDeepLink:dynamicLink.url.absoluteString];
        [[DeepLink sharedInstance] consumeDeepLink];
        
                                                                }];
    return handled;
}

- (void)signIn:(GIDSignIn *)signIn didSignInForUser:(GIDGoogleUser *)user withError:(NSError *)error {
    if (error == nil) {
      GIDAuthentication *authentication = user.authentication;
      FIRAuthCredential *credential =
      [FIRGoogleAuthProvider credentialWithIDToken:authentication.idToken
                                       accessToken:authentication.accessToken];
      // ...
    } else {
      // ...
    }
    
    if(self.googleSigninMyDelegate != nil)
    [self.googleSigninMyDelegate callback:YES didSignInForUser:user];
}
    
    
- (BOOL)application:(UIApplication *)application
            openURL:(NSURL *)url
            options:(NSDictionary<UIApplicationOpenURLOptionsKey,id> *)options {
       
    if([KakaoWrapper handleOpenUrl:url])
        return true;
     
    //NSURL *    @"kakaob973b140b9138a6cc08b0cb2693ce6c2://kakaolink?param1=ios"    0x0000000280210300
    if([[FBSDKApplicationDelegate sharedInstance] application:application
                                                                  openURL:url
                                                        sourceApplication:options[UIApplicationOpenURLOptionsSourceApplicationKey]
                                                               annotation:options[UIApplicationOpenURLOptionsAnnotationKey]
                    ])
        return true;

    if([[GIDSignIn sharedInstance] handleURL:url])
        return true;
                
    FIRDynamicLink *dynamicLink = [[FIRDynamicLinks dynamicLinks] dynamicLinkFromCustomSchemeURL:url];
    if (dynamicLink) {
        if (dynamicLink.url) {
            // Handle the deep link. For example, show the deep-linked content,
            // apply a promotional offer to the user's account or show customized onboarding view.
            // ...
            [[DeepLink sharedInstance] reserveDeepLink:dynamicLink.url.absoluteString];
            [[DeepLink sharedInstance] consumeDeepLink];
        } else {
            // Dynamic link has empty deep link. This situation will happens if
            // Firebase Dynamic Links iOS SDK tried to retrieve pending dynamic link,
            // but pending link is not available for this device/App combination.
            // At this point you may display default onboarding view.
        }
        return YES;
    }

    //구글 딥링크가 발동했을 했을때
    //url    NSURL *    @"kr.co.trix.sticar://google/link/?deep_link_id=http%3A%2F%2Fwww%2Ecarmile%2Eco%2Ekr%2Finvitation%2Ehtml%3Fcode%3DMTU2Mjg0MTgyNzc5MA&match_type=unique&match_message=Link%20is%20uniquely%20matched%20for%20this%20device%2E"    0x00000002804b0b00
    
    if([[url host] isEqualToString:@"kakaolink"]){
        NSMutableDictionary *params = [[NSMutableDictionary alloc] init];
        for (NSString *param in [[url query] componentsSeparatedByString:@"&"]) {
            NSArray *elts = [param componentsSeparatedByString:@"="];
            if([elts count] < 2) continue;
            [params setObject:[elts lastObject] forKey:[elts firstObject]];
        }
        NSString* type = params[@"type"];
        if([type isEqualToString:@"product"]){
            NSString* sticar_no = params[@"type"];
        }
        else if([type isEqualToString:@"invite"]){
            NSString* code = params[@"code"];
        }
        return true;
    }
       
    return false;
}

-(float)convertTextSize:(int)sketchTextSize
{
    return sketchTextSize+2;
}

- (UIView*)getNetworkImageViewInstnace
{
    UIImageView* r = [[UIImageView alloc] init];
    r.clipsToBounds = YES;
    r.contentMode = UIViewContentModeScaleAspectFill;
    return r;
}

- (void)loadNetworkImageView:(UIView*)networkImageView withUrl:(NSString*)url
{
    [((UIImageView*)networkImageView) setImageWithURL:[NSURL URLWithString:url] placeholderImage:nil];
    WildCardUIView* f = (WildCardUIView*)[networkImageView superview];
    if([f.name isEqualToString:@"profile"])
        networkImageView.layer.cornerRadius = f.frame.size.width/2;
}

- (void)onNetworkRequest:(NSString*)url success:(void (^)(NSMutableDictionary* responseJsonObject))success
{
    [JulyUtil request:url postParam:nil complete:^(id  _Nonnull json) {
        success(json);
    }];
}

- (void)onNetworkRequestToByte:(NSString*)url success:(void (^)(NSData* byte))success
{
    [JulyUtil request:url complete:^(id  _Nonnull byte) {
        success(byte);
    }];
}

- (void)onNetworkRequestGet:(NSString*)url header:(NSDictionary*)header success:(void (^)(NSMutableDictionary* responseJsonObject))success{
    [JulyUtil request:url header:header complete:^(id  _Nonnull json) {
        success(json);
    }];
}

- (void)onNetworkRequestPost:(NSString*)url header:(NSDictionary*)header json:(NSDictionary*)json success:(void (^)(NSMutableDictionary* responseJsonObject))success{
    [JulyUtil request:url header:header postParam:json complete:^(id  _Nonnull json) {
        success(json);
    }];
}

-(UIView*)onCustomExtensionCreate:(WildCardMeta *)meta extensionLayer:(NSDictionary*) extension
{
    return nil;
}

-(void)onCustomExtensionUpdate:(UIView*)view meta:(WildCardMeta *)meta extensionLayer:(NSDictionary*)extension data:(NSMutableDictionary*) data
{
    if([@"ads" isEqualToString:extension[@"select3"]])
    {
        
    }
}

-(void)onCustomAction:(WildCardMeta *)meta function:(NSString*)functionName args:(NSArray*)args view:(WildCardUIView*) node
{
}


-(NSString*)translateLanguage:(NSString*)text{
    return trans(text);
}

@end
