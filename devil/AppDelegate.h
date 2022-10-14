//
//  AppDelegate.h
//  CloudJsonViewer
//
//  Created by Mu Young Ko on 2018. 6. 18..
//  Copyright © 2018년 Mu Young Ko. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <CoreLocation/CoreLocation.h>
#import <CoreMotion/CoreMotion.h>
#import <CoreBluetooth/CoreBluetooth.h>
#import <UserNotifications/UserNotifications.h>

@import FirebaseCore;
@import FirebaseMessaging;
@import devilcore;
@import devillogin;
@import GoogleSignIn;

@interface AppDelegate : UIResponder <UIApplicationDelegate,
FIRMessagingDelegate,
UNUserNotificationCenterDelegate,
WildCardConstructorGlobalDelegate,
WildCardConstructorTextConvertDelegate,
WildCardConstructorTextTransDelegate>

@property (strong, nonatomic) UIWindow *window;
@property (strong, nonatomic) UINavigationController *navigationController;


@end

