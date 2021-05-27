//
//  DevilNaverLogin.h
//  devillogin
//
//  Created by Mu Young Ko on 2021/05/28.
//

#import <Foundation/Foundation.h>
@import UIKit;

NS_ASSUME_NONNULL_BEGIN

@protocol DevilNaverLoginDelegate <NSObject>
@optional
- (BOOL)handleUrl:(UIApplication *)application
          openURL:(NSURL *)url
          options:(NSDictionary<UIApplicationOpenURLOptionsKey,id> *)options;
- (void)login:(UIViewController*)vc clientId:(NSString*)clientId clientSecret:(NSString *)clientSecret;
@end

@interface DevilNaverLogin : NSObject

+ (DevilNaverLogin*)sharedInstance;
+ (BOOL)application:(UIApplication *)application
            openURL:(NSURL *)url
            options:(NSDictionary<UIApplicationOpenURLOptionsKey,id> *)options;
- (void)loginWithComplete:(UIViewController*)vc callback:(void (^)(id user))callback;
- (void)naverLoginSuccess:(BOOL)success userId:(NSString*)userId name:(NSString*)name profile:(NSString*)profile email:(NSString*)email token:(NSString*)token;

@property void (^callback)(id res);
@property (nonatomic, weak, nullable) id <DevilNaverLoginDelegate> delegate;

@end

NS_ASSUME_NONNULL_END
