//
//  DevilGoogleLogin.h
//  devillogin
//
//  Created by Mu Young Ko on 2021/04/23.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>

@import GoogleSignIn;

NS_ASSUME_NONNULL_BEGIN

@interface DevilGoogleLogin : NSObject<GIDSignInDelegate>

+ (id)sharedInstance;
+ (BOOL)application:(UIApplication *)application
            openURL:(NSURL *)url
            options:(NSDictionary<UIApplicationOpenURLOptionsKey,id> *)options;

- (void)loginWithComplete:(UIViewController*)vc callback:(void (^)(id user))callback;


@property void (^callback)(id res);

@end

NS_ASSUME_NONNULL_END
