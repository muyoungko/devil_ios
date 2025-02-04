//
//  LoginController.h
//  CloudJsonViewer
//
//  Created by Mu Young Ko on 2020/11/13.
//  Copyright © 2020 Mu Young Ko. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "SubController.h"
#import "AppDelegate.h"
#import <AuthenticationServices/AuthenticationServices.h>

@import devilcore;
@import devillogin;
@import GoogleSignIn;

NS_ASSUME_NONNULL_BEGIN

@interface LoginController : SubController< WildCardConstructorInstanceDelegate,
ASAuthorizationControllerPresentationContextProviding,
ASAuthorizationControllerDelegate
>

@property void (^callback)(BOOL) ;


@end

NS_ASSUME_NONNULL_END
