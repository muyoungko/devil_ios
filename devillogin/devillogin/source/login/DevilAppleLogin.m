//
//  DevilAppleLogin.m
//  devillogin
//
//  Created by Mu Young Ko on 2021/04/24.
//

#import "DevilAppleLogin.h"

@implementation DevilAppleLogin

+ (id)sharedInstance {
    static DevilAppleLogin *sharedInstance = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        sharedInstance = [[self alloc] init];
    });
    return sharedInstance;
}

-(void)loginWithComplete:(UIViewController*)vc callback:(void (^)(id user))callback{
    self.callback = callback;
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
        NSString *token = [[NSString alloc] initWithData:appleIDCredential.identityToken encoding:NSUTF8StringEncoding];
        
        id r = [@{} mutableCopy];
        r[@"identifier"] = identifier;
        r[@"name"] = appleIDCredential.fullName.familyName? appleIDCredential.fullName.familyName:@"apple";
        r[@"profile"] = @"";
        r[@"email"] = appleIDCredential.email? appleIDCredential.email : @"";
        r[@"token"] = token;
        r[@"gender"] = @"";
        r[@"age"] = @"";
        self.callback(r);
        self.callback = nil;
    } else if ([authorization.credential isKindOfClass:[ASPasswordCredential class]]) {
        ASPasswordCredential *passwordCredential = authorization.credential;
        NSString *user = passwordCredential.user;
        NSString *password = passwordCredential.password;
    }
}
- (void)authorizationController:(ASAuthorizationController *)controller didCompleteWithError:(NSError *)error API_AVAILABLE(ios(13.0)){
    self.callback(nil);
    self.callback = nil;
}

//- (nonnull ASPresentationAnchor)presentationAnchorForAuthorizationController:(nonnull ASAuthorizationController *)controller  API_AVAILABLE(ios(13.0)){
//    
//}

@end
