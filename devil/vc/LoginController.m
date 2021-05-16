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

@interface LoginController ()

@end

@implementation LoginController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.data[@"os"] = @"ios";
    [self hideNavigationBar];
    [self constructBlockUnder:@"1605249371392"];
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
                    [[Devil sharedInstance] login:@"apple" email:identifier passwordOrToken:@"" callback:^(id  _Nonnull res) {
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
    
    //userId    __NSCFString *    @"109663080902224508578"    0x0000600002c93a50
    //token    __NSCFString *    @"eyJhbGciOiJSUzI1NiIsImtpZCI6IjJiZjg0MThiMjk2M2YzNjZmNWZlZmRkMTI3YjJjZWUwN2M4ODdlNjUiLCJ0eXAiOiJKV1QifQ.eyJpc3MiOiJodHRwczovL2FjY291bnRzLmdvb2dsZS5jb20iLCJhenAiOiI2ODc3NzEyNzg0MjktOW5waDJuNmVoNGU3amVoMWFpMWpxaWlmMGk0aXZidGUuYXBwcy5nb29nbGV1c2VyY29udGVudC5jb20iLCJhdWQiOiI2ODc3NzEyNzg0MjktOW5waDJuNmVoNGU3amVoMWFpMWpxaWlmMGk0aXZidGUuYXBwcy5nb29nbGV1c2VyY29udGVudC5jb20iLCJzdWIiOiIxMDk2NjMwODA5MDIyMjQ1MDg1NzgiLCJlbWFpbCI6Im11eW91bmdrb0BnbWFpbC5jb20iLCJlbWFpbF92ZXJpZmllZCI6dHJ1ZSwiYXRfaGFzaCI6IjdicF80VlVNVmx4amFzczJMUVo0SnciLCJpYXQiOjE1NjgyNzY1MzQsImV4cCI6MTU2ODI4MDEzNH0.p7CCPz_QI8PlcfWUEszVe8u3RRU_tPKKvUDPSvcThaLswEB-HlempL8RvX-LPlVS1ZWX_PnByhuWIyOd_5fuzdo42dPAuTHUBtlnJoIF57K0G6y4RHbeJDNW3SR6prrbirmAVoS2QD1PFdepeWXde0ESWEUgd2IfHcjjI2DvJvPg72xEkiSElTiBno3jY0X_c22VM4DRPriPoG1Y16fU06G0VgK7-qwYpmFpE5cruylf0sVezkg5koT8rN74eNz7E3piccHoLQsYm-z5PjEUwqxHeR_GM6ygneYhcDjNjf6i-vpd86TbMWIt0dLTMTttSDTO-FgzjvqQi3zd4_aFUg"    0x00007ff82ac63ce0
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
    [self.navigationController pushViewController:[[MainController alloc] init] animated:YES];
}

@end
