//
//  DevilNaverLogin.m
//  devillogin
//
//  Created by Mu Young Ko on 2021/05/28.
//

#import "DevilNaverLogin.h"

@implementation DevilNaverLogin

+ (DevilNaverLogin*)sharedInstance {
    static DevilNaverLogin *sharedInstance = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        sharedInstance = [[self alloc] init];
    });
    return sharedInstance;
}

+ (BOOL)application:(UIApplication *)application
            openURL:(NSURL *)url
            options:(NSDictionary<UIApplicationOpenURLOptionsKey,id> *)options {
    if([DevilNaverLogin sharedInstance].delegate){
        return [[DevilNaverLogin sharedInstance].delegate handleUrl:application openURL:url options:options];
    }
    
    //return [[GIDSignIn sharedInstance] handleURL:url];
    return NO;
}


-(void)loginWithComplete:(UIViewController*)vc callback:(void (^)(id user))callback{

    NSString* path = [[NSBundle mainBundle] pathForResource:@"devil" ofType:@"plist"];
    id devilConfig = [[NSDictionary alloc] initWithContentsOfFile:path];
    self.callback = callback;
    if([DevilNaverLogin sharedInstance].delegate)
        [[DevilNaverLogin sharedInstance].delegate login:vc clientId:devilConfig[@"NaverLoginClientId"] clientSecret:devilConfig[@"NaverLoginClientSecret"]];
    
}

- (void)naverLoginSuccess:(BOOL)success userId:(NSString*)userId name:(NSString*)name profile:(NSString*)profile email:(NSString*)email token:(NSString*)token{
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

@end
