//
//  LoginControllerViewController.m
//  Devil
//
//  Created by 고무영 on 05/04/2019.
//  Copyright © 2019 trix. All rights reserved.
//`

#import "LoginController.h"
#import "Devil.h"
#import <AFNetworking/AFNetworking.h>
#import "JulyUtil.h"
#import "MainV2Controller.h"
@import devilcore;
@interface LoginController ()

@end

@implementation LoginController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.data[@"os"] = @"ios";
    self.data[@"email"] = @"appledemo";
    self.data[@"pass"] = @"apple";
    [self hideNavigationBar];
    [self constructBlockUnder:@"1605249371392"];
    [JevilInstance currentInstance].vc = self;
}

- (void)bottomClick:(id)sender{
    
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    [self hideNavigationBar];
}

-(BOOL)onInstanceCustomAction:(WildCardMeta *)meta function:(NSString*)functionName args:(NSArray*)args view:(WildCardUIView*) node
{
    if([@"login_email" isEqualToString:functionName]){
        NSString* email = trim([self.data[@"email"] toString]);
        NSString* pass = trim([self.data[@"pass"] toString]);
        
        if(empty(email)){
            [self showAlert:@"이메일을 입력해주세요"];
            return YES;
        }
        
        if(empty(pass)){
            [self showAlert:@"비밀번호를 입력해주세요"];
            return YES;
        }

        [self showIndicator];
        [[Devil sharedInstance] login:@"email" email:email passwordOrToken:pass callback:^(id  _Nonnull res) {
            [self hideIndicator];
            if(res != nil && [res[@"r"] intValue]){
                [self finishLogin];
            } else
                [self showAlert:res[@"msg"]];
        }];
        
        return YES;
    } else if([@"login_fb" isEqualToString:functionName]){
        return YES;
    } else if([@"login_google" isEqualToString:functionName]){
        [GIDSignIn.sharedInstance signInWithPresentingViewController:self completion:^(GIDSignInResult * _Nullable signInResult, NSError * _Nullable error) {
            if (error || signInResult == nil) {
              return;
            }
            
            [self googleLoginCallback:YES didSignInForUser:signInResult.user];
        }];
        
        return YES;
    } else if([@"login_apple" isEqualToString:functionName]){
        [self haddleAppleLogin];
        return YES;
    } else if([@"login_force" isEqualToString:functionName]){
        [self.navigationController popViewControllerAnimated:YES];
        DevilController* v = [[DevilController alloc] init];
        v.screenId = @"56560571";
        [self.navigationController pushViewController:v animated:true];
        return YES;
    }
    return NO;
}


//애플 로그인 --------------------
- (void) haddleAppleLogin {
    ASAuthorizationAppleIDProvider* appleIDProvider = [[ASAuthorizationAppleIDProvider alloc] init];
    // Creates a new Apple ID authorization request.
    ASAuthorizationAppleIDRequest *request = appleIDProvider.createRequest;
    // The contact information to be requested from the user during authentication.
    request.requestedScopes = @[ASAuthorizationScopeFullName, ASAuthorizationScopeEmail];

    // A controller that manages authorization requests created by a provider.
    ASAuthorizationController *controller = [[ASAuthorizationController alloc] initWithAuthorizationRequests:@[request]];

    // A delegate that the authorization controller informs about the success or failure of an authorization attempt.
    controller.delegate = self;

    // A delegate that provides a display context in which the system can present an authorization interface to the user.
    controller.presentationContextProvider = self;

    // starts the authorization flows named during controller initialization.
    [controller performRequests];
}
- (void)authorizationController:(ASAuthorizationController *)controller didCompleteWithAuthorization:(ASAuthorization *)authorization API_AVAILABLE(ios(13.0)){
    if ([authorization.credential isKindOfClass:[ASAuthorizationAppleIDCredential class]]) {
        // ASAuthorizationAppleIDCredential
        ASAuthorizationAppleIDCredential *appleIDCredential = authorization.credential;
        NSString *identifier = appleIDCredential.user;
        NSString *token = [NSString stringWithFormat:@"%@", appleIDCredential.identityToken];
         
        [self showIndicator];
        [[Devil sharedInstance] checkMemeber:@"apple" identifier:identifier callback:^(id  _Nonnull res) {
            if(res){
                [self hideIndicator];
                if([res[@"r"] boolValue]){
                    [self showIndicator];
                    [[Devil sharedInstance] login:@"apple" email:@"" passwordOrToken:identifier callback:^(id  _Nonnull res) {
                        [self hideIndicator];                        
                        if(res && [res[@"r"] boolValue]) {
                            [self finishLogin];
                        } else
                            [self showAlert:res[@"msg"]];
                    }];
                } else {
                    id param = [@{} mutableCopy];
                    param[@"type"] = @"apple";
                    param[@"email"] = appleIDCredential.email? appleIDCredential.email : @"";
                    param[@"name"] = appleIDCredential.fullName.familyName? appleIDCredential.fullName.familyName:@"apple";
                    param[@"identifier"] = identifier;
                    param[@"token"] = identifier;
                    param[@"sex"] = @"";
                    param[@"age"] = @"";
                    param[@"profile"] = @"";
                    [Jevil go:@"join" : param];
                }
            } else
                [self showAlert:NETWORK_MSG];
        }];
        
        
    } else if ([authorization.credential isKindOfClass:[ASPasswordCredential class]]) {
        ASPasswordCredential *passwordCredential = authorization.credential;
        NSString *user = passwordCredential.user;
        NSString *password = passwordCredential.password;
    }
}
- (void)authorizationController:(ASAuthorizationController *)controller didCompleteWithError:(NSError *)error{
    
}

//구글 로그인 후처리
- (void)googleLoginCallback:(BOOL)sucess didSignInForUser:(GIDGoogleUser *)user{
    if(user == nil)
        return;
    NSString *userId = user.userID;                  // For client-side use only!
    __block NSString *token = user.idToken.tokenString; // Safe to send to the server
    __block NSString *name = user.profile.name;
    NSString *email = user.profile.email;
    NSString *profile = nil;
    if([user.profile hasImage])
        profile = [[user.profile imageURLWithDimension:120] absoluteString];
    
    [self showIndicator];
    [[Devil sharedInstance] checkMemeber:@"google" identifier:userId callback:^(id  _Nonnull res) {
        [self hideIndicator];
        if(res){
            if([res[@"r"] boolValue]){
                [self showIndicator];
                
                [[Devil sharedInstance] login:@"google" email:@"noneed" passwordOrToken:token callback:^(id  _Nonnull res) {
                    [self hideIndicator];
                    if(res && [res[@"r"] boolValue])
                        [self finishLogin];
                    else
                        [self showAlert:res[@"msg"]];
                }];
            } else {
                id param = [@{} mutableCopy];
                param[@"type"] = @"google";
                param[@"email"] = email;
                param[@"name"] = name;
                param[@"identifier"] = userId;
                param[@"token"] = token;
                param[@"sex"] = @"";
                param[@"age"] = @"";
                param[@"profile"] = profile;
                [Jevil go:@"join" : param];
            }
        }
        else
            [self showAlert:NETWORK_MSG];
    }];
}

-(void)finishLogin{
    [self.navigationController popViewControllerAnimated:YES];
    MainV2Controller* v = [[MainV2Controller alloc] init];
    v.screenId = @"56553391";
    [self.navigationController setViewControllers:@[v]];
}

@end
