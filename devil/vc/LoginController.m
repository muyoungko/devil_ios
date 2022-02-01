//
//  LoginControllerViewController.m
//  Devil
//
//  Created by 고무영 on 05/04/2019.
//  Copyright © 2019 trix. All rights reserved.
//`

#import "LoginController.h"
#import "MainController.h"
#import "JoinController.h"
#import "Devil.h"
#import "Lang.h"
#import <AFNetworking/AFNetworking.h>
#import "JulyUtil.h"
#import "MainV2Controller.h"

@interface LoginController ()

@end

@implementation LoginController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.data[@"os"] = @"ios";
    [self hideNavigationBar];
    [self constructBlockUnder:@"1605249371392"];
    [JevilInstance currentInstance].vc = self;
}

- (void)bottomClick:(id)sender{
    
}

//- (void)loginButton:(FBSDKLoginButton *)loginButton
//didCompleteWithResult:(FBSDKLoginManagerLoginResult *)result
//              error:(NSError *)error {
//    if (error == nil && !result.isCancelled) {
//
//    } else {
//        NSLog(error.localizedDescription);
//    }
//}

-(BOOL)onInstanceCustomAction:(WildCardMeta *)meta function:(NSString*)functionName args:(NSArray*)args view:(WildCardUIView*) node
{
    if([@"login_email" isEqualToString:functionName]){
        NSString* email = trim(self.data[@"email"]);
        NSString* pass = trim(self.data[@"pass"]);
        
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
        ((AppDelegate*)[UIApplication sharedApplication].delegate).googleSigninMyDelegate = self;
        [GIDSignIn sharedInstance].presentingViewController = self;
        [[GIDSignIn sharedInstance] signIn];
        
        return YES;
    } else if([@"login_apple" isEqualToString:functionName]){
        [self haddleAppleLogin];
        return YES;
    } else if([@"join" isEqualToString:functionName]){
        JoinController* vc = [[JoinController alloc] init];
        vc.type = @"email";
        [self.navigationController pushViewController:vc animated:YES];
        return YES;
    } else if([@"script" isEqualToString:functionName]) {
        NSString* ID = self.data[@"input1"];
        NSString* password = self.data[@"input2"];
        if([@"appledemo" isEqualToString:ID] && [@"apple" isEqualToString:password]) {
            NSString* token = @"eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJtZW1iZXJfbm8iOiIxNjA1OTgwMzc5Mjc4IiwiZW1haWwiOiJibmJob3N0c2VyaW5nQGdtYWlsLmNvbSIsIm5hbWUiOiJCbmIgSG9zdCIsInR5cGUiOiJnb29nbGUiLCJwcm9maWxlIjoiaHR0cHM6Ly9saDMuZ29vZ2xldXNlcmNvbnRlbnQuY29tL2EtL0FPaDE0R2lzaFo4X2E5ZHFHSk9ILWpfbmUyekREVkk5RkR5LVFDNGFFUGpqPXM5Ni1jIiwicGFzc3dvcmQiOiIkMmEkMTAkNmNnMjA0QWpXRjBTL0ZyV2VaMEpLTzBwdDZJcTJJUUpQLnNOQzI0ckVyMlB1TnhmL0UzamkiLCJpYXQiOjE2NDM0NjE0MDUsImV4cCI6MTcyOTg2MTQwNSwiaXNzIjoiLmRlYXZpbC5jb20iLCJzdWIiOiJ1c2VySW5mbyJ9.a5jQP1jPEKrk0FuJP2_2-EGvbMg9A8wLDwrXjfWA0KA";
            [[NSUserDefaults standardUserDefaults] setObject:token forKey:@"token"];
            [[NSUserDefaults standardUserDefaults] synchronize];
            [self finishLogin];
        } else {
            UIAlertController *alertController = [UIAlertController alertControllerWithTitle:@""
                                                                                     message:@"Wrong password or id"
                                                                              preferredStyle:UIAlertControllerStyleAlert];

            [alertController addAction:[UIAlertAction actionWithTitle:@"OK"
                                                              style:UIAlertActionStyleCancel
                                                            handler:^(UIAlertAction *action) {
                                                                
            }]];
            [self presentViewController:alertController animated:YES completion:^{}];
        }
        
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
                    JoinController* vc = [[JoinController alloc] init];
                    vc.type = @"apple";
                    vc.email = appleIDCredential.email? appleIDCredential.email : @"";
                    vc.name = appleIDCredential.fullName.familyName? appleIDCredential.fullName.familyName:@"apple";
                    vc.identifier = identifier;
                    vc.token = @"";
                    vc.sex = @"";
                    vc.age = @"";
                    vc.profile = @"";
                    [self.navigationController pushViewController:vc animated:YES];
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

//구글 로그인 ~~~~~~~~~~~~~~~~~~~~~~~~~
- (void)callback:(BOOL)sucess didSignInForUser:(GIDGoogleUser *)user{
    if(user == nil)
        return;
    NSString *userId = user.userID;                  // For client-side use only!
    __block NSString *token = user.authentication.idToken; // Safe to send to the server
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
                JoinController* vc = [[JoinController alloc] init];
                vc.type = @"google";
                vc.email = email;
                vc.name = name;
                vc.identifier = userId;
                vc.token = token;
                vc.profile = profile;
                vc.sex = @"";
                vc.age = @"";
                [self.navigationController pushViewController:vc animated:YES];
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
