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

@import Firebase;
@import devilcore;
@import devillogin;
@import GoogleSignIn;

@protocol GoogleSigninMyDelegate <NSObject>

-(void)callback:(BOOL)sucess  didSignInForUser:(GIDGoogleUser *)user;

@end

@interface AppDelegate : UIResponder <UIApplicationDelegate,
FIRMessagingDelegate,
UNUserNotificationCenterDelegate,
WildCardConstructorGlobalDelegate,
WildCardConstructorTextConvertDelegate,
WildCardConstructorTextTransDelegate,
GIDSignInDelegate>

@property (strong, nonatomic) UIWindow *window;
@property (strong, nonatomic) UINavigationController *navigationController;
@property (nonatomic, weak, nullable) id <GoogleSigninMyDelegate> googleSigninMyDelegate;


@end

