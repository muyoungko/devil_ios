//
//  AppDelegate.m
//  CloudJsonViewer
//
//  Created by Mu Young Ko on 2018. 6. 18..
//  Copyright © 2018년 Mu Young Ko. All rights reserved.
//

#import <UserNotifications/UserNotifications.h>
#define SYSTEM_VERSION_GRATERTHAN_OR_EQUALTO(v)  ([[[UIDevice currentDevice] systemVersion] compare:v options:NSNumericSearch] != NSOrderedAscending)

@import CoreData;
@import devilcore;
@import devillogin;
@import GoogleMobileAds;

#import <AFNetworking/AFNetworking.h>
#import "UIImageView+AFNetworking.h"
#import "Devil.h"

#import "FirstController.h"
#import "MainController.h"
#import "Lang.h"
#import "JulyUtil.h"
#import "DeepLink.h"
#import "DevilNaverLoginCallback.h"

#import "AppDelegate.h"
#import "MyDevilController.h"
#import "LearningController.h"

#import "JevilLearning.h"

#import "LoginController.h"

@interface AppDelegate ()<DevilGoogleLoginDelegate, DevilLinkDelegate, DevilSdkScreenDelegate>

@property (nonatomic, retain) DevilGoogleLogin* devilGoogleLogin;
@property (nonatomic, retain) DevilNaverLoginCallback* devilNaverLoginCallback;
@property(nonatomic, strong) GADInterstitialAd *interstitial;
@property (nonatomic, retain) GADRewardedAd* rewardedAd;

@end

@implementation AppDelegate


- (void)application:(UIApplication *)application didRegisterForRemoteNotificationsWithDeviceToken:(NSData *)deviceToken
{
    NSLog(@"pushKey - %@",deviceToken);
    [FIRMessaging messaging].APNSToken = deviceToken;
}


/**
 앱이 전면인데 푸시가 왔을때
 */
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
    
    // Change this to your preferred presentation option
    if([[DevilLink sharedInstance] checkNotificationShouldShow:userInfo])
        completionHandler(UNNotificationPresentationOptionAlert);
    else
        completionHandler(UNNotificationPresentationOptionNone);
}

NSString *const kGCMMessageIDKey = @"gcm.message_id";
/**
 앱이 전면인데 푸시를 클릭했을떄
 */
- (void)userNotificationCenter:(UNUserNotificationCenter *)center didReceiveNotificationResponse:(UNNotificationResponse *)response
         withCompletionHandler:(void(^)(void))completionHandler {
    NSDictionary *userInfo = response.notification.request.content.userInfo;
    if (userInfo[kGCMMessageIDKey]) {
        NSLog(@"Message ID: %@", userInfo[kGCMMessageIDKey]);
    }
    
    // Print full message.
    NSLog(@"%@", userInfo);
    
    [[DevilLink sharedInstance] setReserveUrl:userInfo[@"url"]];
    [[DevilLink sharedInstance] consumeStandardReserveUrl];
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
    [[NSURLCache sharedURLCache] removeAllCachedResponses];
    
    [FIRApp configure];
    
    [DevilLoginSdk application:application didFinishLaunchingWithOptions:launchOptions];
    //[[DevilSdk sharedInstance] registScreenController:@"view" class:[MyDevilController class]];
    [DevilSdk sharedInstance].devilSdkScreenDelegate = self;
    [DevilSdk sharedInstance].devilSdkGoogleAdsDelegate = self;
    [[DevilSdk sharedInstance] addCustomJevil:[JevilLearning class]];
    [[DevilSdk sharedInstance] addCustomJevil:[JevilBill class]];
    [[DevilSdk sharedInstance] addCustomJevil:[JevilAds class]];
    [[DevilSdk sharedInstance] addCustomJevil:[JevilHealth class]];
    
    if(launchOptions == nil){
        [self preparePushToken:application];
    }
    
    [[GADMobileAds sharedInstance] startWithCompletionHandler:nil];

    [GIDSignIn sharedInstance].clientID = [FIRApp defaultApp].options.clientID;
    [GIDSignIn sharedInstance].delegate = self;
    
    [UIApplication sharedApplication].applicationIconBadgeNumber=0;
    
    
    [WildCardConstructor sharedInstance:@"1605234988599"];
    [WildCardConstructor sharedInstance].delegate = self;
    [WildCardConstructor sharedInstance].textConvertDelegate = self;
    [WildCardConstructor sharedInstance].textTransDelegate = self;
    
    self.window = [[UIWindow alloc] initWithFrame:UIScreen.mainScreen.bounds];
    UIViewController* vc = [[FirstController alloc] initWithNibName:@"FirstController" bundle:nil];
    //DevilCameraController* vc = [[DevilCameraController alloc] init];
    self.navigationController = [[DevilNavigationController alloc] initWithRootViewController:vc];
    
    self.window.rootViewController = self.navigationController;
    [self.window makeKeyAndVisible];
        
    [DevilGoogleLogin sharedInstance].delegate = self;
    self.devilNaverLoginCallback = [[DevilNaverLoginCallback alloc] init];
    [DevilNaverLogin sharedInstance].delegate = self.devilNaverLoginCallback;
    
    [DevilLink sharedInstance].delegate = self;
    if(launchOptions[UIApplicationLaunchOptionsRemoteNotificationKey]){
        NSLog(@"launchOptions %@", launchOptions[UIApplicationLaunchOptionsRemoteNotificationKey]);
        [[DevilLink sharedInstance] setReserveUrl:launchOptions[UIApplicationLaunchOptionsRemoteNotificationKey][@"url"]];
        NSString* project_id = launchOptions[UIApplicationLaunchOptionsRemoteNotificationKey][@"project_id"];
        [Devil sharedInstance].reservedUrl = [NSURL URLWithString:[NSString stringWithFormat:@"devil-app-builder://project/start/%@", project_id]];
    }
    
    return YES;
}

/**
 DevilGoogleLogin delegate
 */
- (BOOL)handleUrl:(NSURL *)url{
    return [[GIDSignIn sharedInstance] handleURL:url];
}
/**
 DevilGoogleLogin delegate
 */
- (void)login:(UIViewController*)vc clientId:(NSString*)clientId{
      
    [GIDSignIn sharedInstance].clientID = clientId;
    [GIDSignIn sharedInstance].delegate = self;
    [GIDSignIn sharedInstance].presentingViewController = vc;
    [[GIDSignIn sharedInstance] signIn];
    
    self.devilGoogleLogin = [DevilGoogleLogin sharedInstance];
}

- (void)applicationDidEnterBackground:(UIApplication *)application {
     NSLog(@"applicationDidEnterBackground");
    if([self.navigationController.topViewController isKindOfClass:[DevilController class]]){
        DevilController* vc = (DevilController*)self.navigationController.topViewController;
        [vc onPause];
    }
}

- (void)applicationWillTerminate:(UIApplication *)application {
    
}
- (void)applicationWillEnterForeground:(UIApplication *)application{
    NSLog(@"applicationWillEnterForeground");
    if([self.navigationController.topViewController isMemberOfClass:[DevilController class]]) {
        [((DevilController*)self.navigationController.topViewController) onResume];
    }
}

- (void)applicationWillResignActive:(UIApplication *)application{
    AVAudioSession *session=[AVAudioSession sharedInstance];
    [session setCategory:AVAudioSessionCategoryPlayback  error:nil];
    [session setActive:YES error:nil];
}

- (void)applicationDidBecomeActive:(UIApplication *)application{
    NSLog(@"app did become active");
    UIViewController* top = [self.navigationController topViewController];
    if([top isKindOfClass:[DevilController class]])
        [((DevilController*)top) onResume];
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
    
        
        if(self.devilGoogleLogin) {
            NSString *userId = user.userID;
            NSString *token = user.authentication.idToken;
            NSString *name = user.profile.name;
            NSString *email = user.profile.email;
            NSString *profile = nil;
            if([user.profile hasImage])
                profile = [[user.profile imageURLWithDimension:120] absoluteString];
            [[DevilGoogleLogin sharedInstance] googleSignInSuccess:YES userId:userId name:name profile:profile email:email token:token];
            self.devilGoogleLogin = nil;
        }
    } else {
        if(self.devilGoogleLogin) {
            [[DevilGoogleLogin sharedInstance] googleSignInSuccess:NO userId:nil name:nil profile:nil email:nil token:nil];
            self.devilGoogleLogin = nil;
        }
    }
    
    if(self.googleSigninMyDelegate != nil){
        [self.googleSigninMyDelegate callback:YES didSignInForUser:user];
        self.googleSigninMyDelegate = nil;
    }
}
    
    
- (BOOL)application:(UIApplication *)application
            openURL:(NSURL *)url
            options:(NSDictionary<UIApplicationOpenURLOptionsKey,id> *)options {
    if([url.scheme isEqualToString:@"devil-app-builder"]){
        [Devil sharedInstance].reservedUrl = url;
        [[Devil sharedInstance] consumeReservedUrl];
        return true;
    }
                
    if([DevilLoginSdk application:(UIApplication *)application
                               openURL:(NSURL *)url
                       options:(NSDictionary<UIApplicationOpenURLOptionsKey,id> *)options])
        return true;
    
                
    if([[GIDSignIn sharedInstance] handleURL:url])
        return true;
                
    FIRDynamicLink *dynamicLink = [[FIRDynamicLinks dynamicLinks] dynamicLinkFromCustomSchemeURL:url];
    if (dynamicLink && dynamicLink.url) {
        [[DeepLink sharedInstance] reserveDeepLink:dynamicLink.url.absoluteString];
        [[DeepLink sharedInstance] consumeDeepLink];
        
        [[DevilLink sharedInstance] setReserveUrl:[NSString stringWithFormat:@"%@", dynamicLink.url]];
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
    __block UIImageView* nv = ((UIImageView*)networkImageView);
    NSURLRequest* req = [NSURLRequest requestWithURL:[NSURL URLWithString:url]];
    [nv setImageWithURLRequest:req placeholderImage:nil success:^(NSURLRequest *request, NSHTTPURLResponse *response, UIImage *image) {

        WildCardUIView* f = (WildCardUIView*)[networkImageView superview];
        if([f isMemberOfClass:[WildCardUIView class]] && [f.name hasPrefix:@"profile"])
            networkImageView.layer.cornerRadius = f.frame.size.width/2;
        networkImageView.layer.cornerRadius = f.layer.cornerRadius;
        f.layer.borderWidth = 0;

        if(nv.image == nil) {
            [nv setImage:image];
            [nv setAlpha:0];
            [UIView animateWithDuration:0.3 animations:^{
                [nv setAlpha:1.0];
            }];
        } else
            [nv setImage:image];
        
    } failure:nil];
}

- (void)onNetworkRequest:(NSString*)url success:(void (^)(NSMutableDictionary* responseJsonObject))success {
    [self onNetworkRequestHttp:@"get" :url :nil :nil :^(NSMutableDictionary *responseJsonObject) {
        success(responseJsonObject);
    }];
}

- (void)onNetworkRequestToByte:(NSString*)url success:(void (^)(NSData* byte))success {
    [JulyUtil request:url complete:^(id  _Nonnull byte) {
        success(byte);
    }];
}

- (void)onNetworkRequestGet:(NSString*)url header:(NSDictionary*)header success:(void (^)(NSMutableDictionary* responseJsonObject))success{
    [self onNetworkRequestHttp:@"get" :url :header :nil :^(NSMutableDictionary *responseJsonObject) {
        success(responseJsonObject);
    }];
}

- (void)onNetworkRequestPost:(NSString*)url header:(NSDictionary*)header json:(NSDictionary*)json success:(void (^)(NSMutableDictionary* responseJsonObject))success{
    [self onNetworkRequestHttp:@"post" :url :header :json :^(NSMutableDictionary *responseJsonObject) {
        success(responseJsonObject);
    }];
}

- (void)onNetworkRequestPut:(NSString*)url header:(NSDictionary*)header json:(NSDictionary*)json success:(void (^)(NSMutableDictionary* responseJsonObject))success{
    [self onNetworkRequestHttp:@"put" :url :header :json :^(NSMutableDictionary *responseJsonObject) {
        success(responseJsonObject);
    }];
}
    
- (void)onNetworkRequestHttp:(NSString*)method :(NSString*)url :(NSDictionary*)header :(NSMutableDictionary*)body :(void (^)(NSMutableDictionary* responseJsonObject))success {
    
    AFHTTPSessionManager *manager = [AFHTTPSessionManager manager];
    manager.requestSerializer = [AFJSONRequestSerializer serializer];
    manager.responseSerializer = [AFHTTPResponseSerializer serializer];
    
    id headers = [@{
        @"Accept": @"application/json, application/*+json",
        @"Content-Type": @"application/json"
                  } mutableCopy];
    for(id k in [header allKeys])
        headers[k] = header[k];
    
    [manager.requestSerializer setTimeoutInterval:10.0];
    method = [method uppercaseString];
    
    if(!body)
        body = [@{} mutableCopy];
    
    NSURLSessionDataTask *dataTask = [manager dataTaskWithHTTPMethod:method
                                                        URLString:url
                                                       parameters:body
                                                          headers:headers
                                                   uploadProgress:nil
                                                 downloadProgress:nil
            success:^(NSURLSessionDataTask *task, id _Nullable res) {
                
        if(res) {
            NSString* s = [[NSString alloc] initWithData:res encoding:NSUTF8StringEncoding];
            if([s hasPrefix:@"["]) {
                id a = [NSJSONSerialization JSONObjectWithData:res options:NSJSONReadingMutableContainers error:nil];
                success([@{@"devil_list":a} mutableCopy]);
            } else {
                id a = [NSJSONSerialization JSONObjectWithData:res options:NSJSONReadingMutableContainers error:nil];
                success(a);
            }
        }
    }
            failure:^(NSURLSessionDataTask * _Nullable task, NSError *error) {
        success(nil);
    }];
    
    [dataTask resume];
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
    if([@"logout" isEqualToString:functionName]) {
        [[Devil sharedInstance] logout];
        [self.navigationController setViewControllers:@[[[LoginController alloc] init]]];
    } else if([@"learn_check" isEqualToString:functionName]) {
        NSString* screen_id = args[0];
        NSString* learn_project_id = args[1];
        AppDelegate* appDelegate = (AppDelegate*)[UIApplication sharedApplication].delegate;
        [WildCardConstructor sharedInstance:learn_project_id].delegate = appDelegate;
        [WildCardConstructor sharedInstance:learn_project_id].textConvertDelegate = appDelegate;
        [WildCardConstructor sharedInstance:learn_project_id].textTransDelegate = appDelegate;
        DevilController* dc = (DevilController*)[JevilInstance currentInstance].vc;
        [dc startLoading];
        [DevilSdk start:learn_project_id screenId:screen_id controller:[LearningController class] viewController:[JevilInstance currentInstance].vc complete:^(BOOL res) {
            [dc stopLoading];
        }];
    }
}


-(NSString*)translateLanguage:(NSString*)text{
    return trans(text);
}

/**
 두손가락 더블탭으로 사운드 멈추거나 재생하기
 */
- (BOOL)accessibilityPerformMagicTap {
    
    if([Jevil soundIsPlaying])
        [Jevil soundPause];
    else
        [Jevil soundResume];
    
    return YES;
}
    
- (void)createFirebaseDynamicLink:(id)param callback:(void (^)(id res))callback {
    NSString* url = param[@"url"];
    NSString* dynamicLinksDomainURIPrefix = param[@"prefix"];
    NSString* package_android = param[@"package_android"];
    NSString* package_ios = param[@"package_ios"];
    NSString* title = param[@"title"];
    NSString* desc = param[@"desc"];
    NSString* imageUrl = param[@"image_url"];
    NSString* appstore_id = param[@"appstore_id"];
    
    NSURL *link = [[NSURL alloc] initWithString:url];
    
    FIRDynamicLinkComponents *linkBuilder = [[FIRDynamicLinkComponents alloc]
                                             initWithLink:link
                                             domainURIPrefix:dynamicLinksDomainURIPrefix];
    linkBuilder.iOSParameters = [[FIRDynamicLinkIOSParameters alloc]
                                 initWithBundleID:package_ios];
    linkBuilder.iOSParameters.appStoreID = appstore_id;
    linkBuilder.androidParameters = [[FIRDynamicLinkAndroidParameters alloc]
                                     initWithPackageName:package_android];
    
    //linkBuilder.analyticsParameters = [[FIRDynamicLinkGoogleAnalyticsParameters alloc] initWithSource:@"invite" medium:@"invite" campaign:@"invite"];
    
    FIRDynamicLinkSocialMetaTagParameters* social = [[FIRDynamicLinkSocialMetaTagParameters alloc] init];
    social.title = title;
    social.descriptionText = desc;
    if(imageUrl)
        social.imageURL = [NSURL URLWithString:imageUrl];
    linkBuilder.socialMetaTagParameters = social;

    [linkBuilder shortenWithCompletion:^(NSURL * _Nullable shortURL,
                                         NSArray<NSString *> * _Nullable warnings,
                                         NSError * _Nullable error) {
        if (error || shortURL == nil) {
            callback(@{@"r":@FALSE, @"msg":[error localizedDescription]});
        } else {
            NSString* url = [shortURL absoluteString];
            callback(@{@"r":@TRUE, @"url":url});
        }
    }];
}
    
-(DevilController*)getScreenViewController:(NSString*)screenName {
    if([@"view" isEqualToString:screenName]) {
        return [[MyDevilController init] alloc];
    }
    else return nil;
}
    
    
//GOOGLE Ads delegate
-(void)loadAds:(id)params complete:(void (^)(id res))callback{
    NSString* adUnitId = params[@"adUnitId"];
    GADRequest *request = [GADRequest request];
      [GADRewardedAd
           loadWithAdUnitID:adUnitId
                    request:request
          completionHandler:^(GADRewardedAd *ad, NSError *error) {
            if (error) {
              NSLog(@"Rewarded ad failed to load with error: %@", [error localizedDescription]);
                callback([@{@"r":@FALSE} mutableCopy]);
            } else {
                self.rewardedAd = ad;
                if(self.rewardedAd) {
                    id r = [@{@"r":@TRUE,} mutableCopy];
                    r[@"type"] = self.rewardedAd.adReward.type;
                    r[@"reward"] = self.rewardedAd.adReward.amount;
                    callback(r);
                } else
                    callback([@{@"r":@FALSE} mutableCopy]);
            }
          }];
}

-(void)showAds:(id)params complete:(void (^)(id res))callback{
    if(self.rewardedAd) {
        [self.rewardedAd presentFromRootViewController:[JevilInstance currentInstance].vc
                                      userDidEarnRewardHandler:^{
                                        GADAdReward *reward = self.rewardedAd.adReward;
                                        id r = [@{@"r":@TRUE,} mutableCopy];
                                        r[@"type"] = self.rewardedAd.adReward.type;
                                        r[@"reward"] = self.rewardedAd.adReward.amount;
                                        callback(r);
                                    }];
    } else {
        id r = [@{@"r":@FALSE,} mutableCopy];
        callback(r);
    }
}
@end
