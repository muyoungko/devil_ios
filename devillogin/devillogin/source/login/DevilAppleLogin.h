//
//  DevilAppleLogin.h
//  devillogin
//
//  Created by Mu Young Ko on 2021/04/24.
//

#import <Foundation/Foundation.h>
#import <AuthenticationServices/AuthenticationServices.h>
#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

@interface DevilAppleLogin : NSObject<ASAuthorizationControllerPresentationContextProviding,
ASAuthorizationControllerDelegate>

+ (id)sharedInstance;
-(void)loginWithComplete:(UIViewController*)vc callback:(void (^)(id user))callback;
@property void (^callback)(id res);

@end

NS_ASSUME_NONNULL_END
