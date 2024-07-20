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
//@import devilhealth;
@import devilnfc;
@import devilbill;
@import devilwebrtc;

@import FirebaseDynamicLinks;
@import FirebaseAnalytics;
@import FirebaseAuth;
@import GoogleMobileAds;

#import <AFNetworking/AFNetworking.h>
#import "UIImageView+AFNetworking.h"
#import "Devil.h"

#import "FirstController.h"
#import "JulyUtil.h"
#import "DeepLink.h"
#import "DevilNaverLoginCallback.h"

#import "AppDelegate.h"
#import "MyDevilController.h"
#import "LearningController.h"

#import "JevilLearning.h"

#import "LoginController.h"
#import "MainV2Controller.h"

#import "CapblMainViewController.h"

@interface AppDelegate ()<DevilGoogleLoginDelegate, DevilLinkDelegate, DevilSdkScreenDelegate, DevilSdkGoogleAdsDelegate, DevilSdkGADelegate, GADFullScreenContentDelegate>

@property (nonatomic, retain) DevilGoogleLogin* devilGoogleLogin;
@property (nonatomic, retain) DevilNaverLoginCallback* devilNaverLoginCallback;
@property(nonatomic, strong) GADInterstitialAd *interstitial;
@property (nonatomic, retain) GADRewardedAd* rewardedAd;
@property void (^adsCallback)(id res);

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
    [WildCardConstructor resetIsTablet];
    if([WildCardConstructor isTablet])
        [DevilSdk sharedInstance].autoChangeOrientation = true;
    [[DevilSdk sharedInstance] registScreenController:@"project" class:[MainV2Controller class]];
    [DevilSdk sharedInstance].devilSdkScreenDelegate = self;
    [DevilSdk sharedInstance].devilSdkGoogleAdsDelegate = self;
    [[DevilSdk sharedInstance] addCustomJevil:[JevilLearning class]];
    [[DevilSdk sharedInstance] addCustomJevil:[JevilBill class]];
    [[DevilSdk sharedInstance] addCustomJevil:[JevilAds class]];
    //[[DevilSdk sharedInstance] addCustomJevil:[JevilHealth class]];
    [[DevilSdk sharedInstance] addCustomJevil:[JevilNfc class]];
    [[DevilSdk sharedInstance] addCustomJevil:[JevilToss class]];
    [[DevilSdk sharedInstance] addCustomJevil:[JevilWebRtc class]];
    
    [DevilSdk sharedInstance].devilSdkGADelegate = self;
    [GADMobileAds.sharedInstance startWithCompletionHandler:nil];
    
    if(launchOptions == nil){
        [self preparePushToken:application];
    }
    
    [[GADMobileAds sharedInstance] startWithCompletionHandler:nil];
    
    [WildCardConstructor sharedInstance:@"1605234988599"];
    [WildCardConstructor sharedInstance].delegate = self;
    [WildCardConstructor sharedInstance].textConvertDelegate = self;
    [WildCardConstructor sharedInstance].textTransDelegate = self;
        
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

- (void)login:(UIViewController*)vc clientId:(NSString*)clientId{
      
    GIDConfiguration* signInConfig = [[GIDConfiguration alloc] initWithClientID:clientId];
    self.devilGoogleLogin = [DevilGoogleLogin sharedInstance];
    [GIDSignIn.sharedInstance signInWithPresentingViewController:self.navigationController.topViewController completion:^(GIDSignInResult * _Nullable signInResult, NSError * _Nullable error) {
        if (error == nil && signInResult != nil) {
        
            
            if(self.devilGoogleLogin) {
                NSString *userId = signInResult.user.userID;
                NSString *token = signInResult.user.idToken.tokenString;
                NSString *name = signInResult.user.profile.name;
                NSString *email = signInResult.user.profile.email;
                NSString *profile = nil;
                if([signInResult.user.profile hasImage])
                    profile = [[signInResult.user.profile imageURLWithDimension:120] absoluteString];
                [[DevilGoogleLogin sharedInstance] googleSignInSuccess:YES userId:userId name:name profile:profile email:email token:token];
                self.devilGoogleLogin = nil;
            }
        } else {
            if(self.devilGoogleLogin) {
                [[DevilGoogleLogin sharedInstance] googleSignInSuccess:NO userId:nil name:nil profile:nil email:nil token:nil];
                self.devilGoogleLogin = nil;
            }
        }
    }];
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
    
- (BOOL)application:(UIApplication *)application
            openURL:(NSURL *)url
            options:(NSDictionary<UIApplicationOpenURLOptionsKey,id> *)options {
                
    return [[Devil sharedInstance] openUrl:url];
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

- (void)cancelNetworkImageView:(UIView*)networkImageView {
    __block UIImageView* nv = ((UIImageView*)networkImageView);
    [nv cancelImageDownloadTask];
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
    
- (void)loadNetworkImageViewWithSize:(UIView*)networkImageView withUrl:(NSString*)url callback:(void (^)(CGSize size))callback
{
    __block UIImageView* nv = ((UIImageView*)networkImageView);
    NSURLRequest* req = [NSURLRequest requestWithURL:[NSURL URLWithString:url]];
    
    [nv setImageWithURLRequest:req placeholderImage:nil success:^(NSURLRequest * _Nonnull request, NSHTTPURLResponse * _Nullable response, UIImage * _Nonnull image) {
        
        callback(image.size);
        
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
        
    } failure:^(NSURLRequest * _Nonnull request, NSHTTPURLResponse * _Nullable response, NSError * _Nonnull error) {
        
    }];
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
    
    if([@"application/x-www-form-urlencoded" isEqualToString:header[@"Content-Type"]])
        [manager.requestSerializer setValue:@"application/x-www-form-urlencoded" forHTTPHeaderField:@"Content-Type"];
    else
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
            } else if([s hasPrefix:@"{"]) {
                id a = [NSJSONSerialization JSONObjectWithData:res options:NSJSONReadingMutableContainers error:nil];
                success(a);
            } else {
                success([@{@"string":s} mutableCopy]);
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

- (void)onMultiPartPost:(NSString*)urlString header:(id)header name:(NSString*)name filename:(NSString*)filename filePath:(NSString*)filePath progress:(void (^)(long sentByte, long totalByte))progress_callback complete:(void (^)(id res))callback {
    AFHTTPSessionManager *manager = [AFHTTPSessionManager manager];
    manager.requestSerializer = [AFJSONRequestSerializer serializer];
    manager.responseSerializer = [AFJSONResponseSerializer serializer];
    [manager POST:urlString parameters:nil headers:header constructingBodyWithBlock:^(id<AFMultipartFormData>  _Nonnull formData) {
        NSURL* fileUri = [NSURL fileURLWithPath:filePath];
        NSError *error;
        [formData appendPartWithFileURL:fileUri name:name fileName:filename mimeType:@"application/octet-stream" error:&error];
        if(error){
            NSLog(@"%@", [error localizedDescription]);
        }
    } progress:^(NSProgress * _Nonnull uploadProgress) {
        progress_callback(uploadProgress.completedUnitCount, uploadProgress.totalUnitCount);
    } success:^(NSURLSessionDataTask * _Nonnull task, id  _Nullable responseObject) {
        NSLog(@"success");
        callback(responseObject);
    } failure:^(NSURLSessionDataTask * _Nullable task, NSError * _Nonnull error) {
        NSLog(@"error %@", [error localizedDescription]);
        callback(@{@"r":@FALSE, @"msg":[error localizedDescription]});
    }];
}
    
-(void)onCustomExtensionUpdate:(UIView*)view meta:(WildCardMeta *)meta extensionLayer:(NSDictionary*)extension data:(NSMutableDictionary*) data
{
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
        [DevilSdk start:learn_project_id screenId:screen_id controller:[LearningController class] viewController:[JevilInstance currentInstance].vc version:nil complete:^(BOOL res) {
            [dc stopLoading];
        }];
    } else if([@"login_success" isEqualToString:functionName]) {
        NSString* token = [Jevil get:@"x-access-token"];
        MainV2Controller* v = [[MainV2Controller alloc] init];
        v.screenId = @"56553391";
        [self.navigationController setViewControllers:@[v]];
    } else if([@"capbl" isEqualToString:functionName]) {
        CapblMainViewController* v = [[CapblMainViewController alloc] init];
        [self.navigationController pushViewController:v animated:YES];
    }
}


-(NSString*)translateLanguage:(NSString*)text{
    return trans(text);
}
-(NSString*)translateLanguage:(NSString*)text :(NSString*)node {
    return trans2(text, node);
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
-(UIView*)createBanner:(id)params {
    GADBannerView* bannerView = [[GADBannerView alloc] initWithAdSize:GADAdSizeBanner];
    bannerView.adUnitID = params[@"adUnitId"];
    bannerView.rootViewController = [self.navigationController topViewController];
    [bannerView loadRequest:[GADRequest request]];
    return bannerView;
}

-(void)loadAds:(id)params complete:(void (^)(id res))callback{
    NSString* adUnitId = params[@"adUnitId"];
    NSString* type = params[@"type"];
    GADRequest *request = [GADRequest request];
    if([@"interstitial" isEqualToString:type]) {
        [GADInterstitialAd loadWithAdUnitID:adUnitId
                                      request:request
                            completionHandler:^(GADInterstitialAd *ad, NSError *error) {
            if (error) {
                callback([@{@"r":@FALSE, @"msg":[error localizedDescription]} mutableCopy]);
            } else {
                self.interstitial = ad;
                self.interstitial.fullScreenContentDelegate = self;
                id r = [@{@"r":@TRUE,} mutableCopy];
                callback(r);
            }
          }];
    } else {
        [GADRewardedAd
             loadWithAdUnitID:adUnitId
                      request:request
            completionHandler:^(GADRewardedAd *ad, NSError *error) {
              if (error) {
                  callback([@{@"r":@FALSE, @"msg":[error localizedDescription]} mutableCopy]);
              } else {
                  self.rewardedAd = ad;
                  id r = [@{@"r":@TRUE,} mutableCopy];
                  r[@"type"] = self.rewardedAd.adReward.type;
                  r[@"reward"] = self.rewardedAd.adReward.amount;
                  callback(r);
              }
            }];
    }
}

-(void)showAds:(id)params complete:(void (^)(id res))callback{
    if(self.interstitial) {
        self.adsCallback = callback;
        [self.interstitial presentFromRootViewController:[JevilInstance currentInstance].vc];
    } else if(self.rewardedAd) {
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
    
- (UIInterfaceOrientationMask)application:(UIApplication *)application supportedInterfaceOrientationsForWindow:(UIWindow *)window{
    UIInterfaceOrientationMask r = [DevilSdk sharedInstance].currentOrientation;
    //NSLog(@"supportedInterfaceOrientationsForWindow %@" , [DevilUtil orientationToString:r]);
    return r;
}

/// Tells the delegate that the ad failed to present full screen content.
- (void)ad:(nonnull id<GADFullScreenPresentingAd>)ad didFailToPresentFullScreenContentWithError:(nonnull NSError *)error {
    if(self.adsCallback) {
        self.adsCallback([@{@"r":@FALSE, @"msg":[error localizedDescription]} mutableCopy]);
        self.adsCallback = nil;
    }
}

/// Tells the delegate that the ad will present full screen content.
- (void)adWillPresentFullScreenContent:(nonnull id<GADFullScreenPresentingAd>)ad {
    NSLog(@"Ad will present full screen content.");
}

/// Tells the delegate that the ad dismissed full screen content.
- (void)adDidDismissFullScreenContent:(nonnull id<GADFullScreenPresentingAd>)ad {
    if(self.adsCallback) {
        self.adsCallback([@{@"r":@TRUE} mutableCopy]);
        self.adsCallback = nil;
    }
}

    
- (void)onScreen:(NSString *)projectId screenId:(NSString *)screenId screenName:(NSString *)screenName {
    if(projectId == nil || screenId == nil || screenName == nil)
        return;
    
    [FIRAnalytics logEventWithName:kFIREventScreenView
                        parameters:@{kFIRParameterScreenClass: screenName,
                                     kFIRParameterScreenName: screenName,
                                     kFIRParameterGroupID : projectId,
                                   }];
}
    
- (void)onEvent:(NSString *)projectId eventType:(NSString *)eventType viewName:(NSString *)viewName {
    if(projectId == nil || eventType == nil || viewName == nil)
        return;
    
    [FIRAnalytics logEventWithName:viewName
                        parameters:@{
                                     kFIRParameterGroupID : projectId,
                                     kFIRParameterItemName: urlencode(viewName),
                                     }];
}
    
- (void)onEventWithGaData:(NSString *)projectId eventType:(NSString *)eventType viewName:(NSString *)viewName gaData:(id)gaData {
    if(projectId == nil || eventType == nil || viewName == nil)
        return;
    id p = [@{
        kFIRParameterGroupID : projectId,
        kFIRParameterItemName:viewName,
    } mutableCopy];
    if(gaData) {
        id ks = [gaData allKeys];
        for(id k in ks) {
            p[k] = gaData[k];
        }
    }
    [FIRAnalytics logEventWithName:viewName
                        parameters:p];
}
    
@end
