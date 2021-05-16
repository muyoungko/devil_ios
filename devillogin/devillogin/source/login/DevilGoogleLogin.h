//
//  DevilGoogleLogin.h
//  devillogin
//
//  Created by Mu Young Ko on 2021/04/23.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

@protocol DevilGoogleLoginDelegate <NSObject>
@optional
- (BOOL)handleUrl:(NSURL *)url;
- (void)login:(UIViewController*)vc clientId:(NSString*)clientId;

@end

@interface DevilGoogleLogin : NSObject

+ (DevilGoogleLogin*)sharedInstance;
+ (BOOL)application:(UIApplication *)application
            openURL:(NSURL *)url
            options:(NSDictionary<UIApplicationOpenURLOptionsKey,id> *)options;

- (void)loginWithComplete:(UIViewController*)vc callback:(void (^)(id user))callback;
- (void)googleSignInSuccess:(BOOL)success userId:(NSString*)userId name:(NSString*)name profile:(NSString*)profile email:(NSString*)email token:(NSString*)token;

@property void (^callback)(id res);
@property (nonatomic, weak, nullable) id <DevilGoogleLoginDelegate> delegate;
@property (nonatomic, retain) NSString*test;

@end

NS_ASSUME_NONNULL_END
