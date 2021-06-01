//
//  DevilGoogleLogin.m
//  devillogin
//
//  Created by Mu Young Ko on 2021/04/23.
//

#import "DevilGoogleLogin.h"

//@import GoogleSignIn;
//
//@interface DevilGoogleLogin()<GIDSignInDelegate>
//@end

@implementation DevilGoogleLogin

+ (DevilGoogleLogin*)sharedInstance {
    static DevilGoogleLogin *sharedInstance = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        sharedInstance = [[self alloc] init];
    });
    return sharedInstance;
} 

-(void)loginWithComplete:(UIViewController*)vc callback:(void (^)(id user))callback{

    NSString* path = [[NSBundle mainBundle] pathForResource:@"devil" ofType:@"plist"];
    id devilConfig = [[NSDictionary alloc] initWithContentsOfFile:path];
    self.callback = callback;
    if([DevilGoogleLogin sharedInstance].delegate)
        [[DevilGoogleLogin sharedInstance].delegate login:vc clientId:devilConfig[@"GoogleLoginClientId"]];
    
    
//    [GIDSignIn sharedInstance].clientID = devilConfig[@"GoogleLoginClientId"];
//    [GIDSignIn sharedInstance].delegate = [DevilGoogleLogin sharedInstance];
//    self.callback = callback;
//    [GIDSignIn sharedInstance].presentingViewController = vc;
//    [[GIDSignIn sharedInstance] signIn];
}

+ (BOOL)application:(UIApplication *)application
            openURL:(NSURL *)url
            options:(NSDictionary<UIApplicationOpenURLOptionsKey,id> *)options {
    if([DevilGoogleLogin sharedInstance].delegate){
        return [[DevilGoogleLogin sharedInstance].delegate handleUrl:url];
    }
    
    //return [[GIDSignIn sharedInstance] handleURL:url];
    return NO;
}

- (void)googleSignInSuccess:(BOOL)success userId:(NSString*)userId name:(NSString*)name profile:(NSString*)profile email:(NSString*)email token:(NSString*)token{
    if(success){
        id r = [@{} mutableCopy];
        r[@"identifier"] = userId;
        r[@"name"] = name;
        r[@"profile"] = profile;
        r[@"email"] = email;
        r[@"token"] = token;
        r[@"gender"] = @"";
        r[@"age"] = @"";
        self.callback(r);
        self.callback = nil;
    } else {
        self.callback(nil);
        self.callback = nil;
    }
}


//- (void)signIn:(GIDSignIn *)signIn didSignInForUser:(GIDGoogleUser *)user withError:(NSError *)error {
//    if(user == nil){
//        self.callback(nil);
//        self.callback = nil;
//    } else {
//        NSString *userId = user.userID;                  // For client-side use only!
//        __block NSString *token = user.authentication.idToken; // Safe to send to the server
//        __block NSString *name = user.profile.name;
//        NSString *email = user.profile.email;
//        NSString *profile = nil;
//        if([user.profile hasImage])
//            profile = [[user.profile imageURLWithDimension:120] absoluteString];
//
//        id r = [@{} mutableCopy];
//        r[@"id"] = userId;
//        r[@"name"] = name;
//        r[@"profile"] = profile;
//        r[@"email"] = email;
//        r[@"token"] = token;
//        r[@"gender"] = @"";
//        r[@"age"] = @"";
//        self.callback(r);
//        self.callback = nil;
//    }
//}

@end
