//
//  DevilFacebook.h
//  devillogin
//
//  Created by Mu Young Ko on 2021/04/04.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

@interface DevilFacebook : NSObject

+(void)loginWithComplete:(void (^)(id user))callback;
+ (BOOL)application:(UIApplication *)application
            openURL:(NSURL *)url
            options:(NSDictionary<UIApplicationOpenURLOptionsKey,id> *)options;

@end

NS_ASSUME_NONNULL_END
