//
//  Devil.m
//  CloudJsonViewer
//
//  Created by Mu Young Ko on 2020/11/13.
//  Copyright © 2020 Mu Young Ko. All rights reserved.
//

#import "Devil.h"
#import <AFNetworking/AFNetworking.h>
#import "JulyUtil.h"
#import "AppDelegate.h"
#import "DeepLink.h"
#import "MainV2Controller.h"

@import devilcore;
@import devilbill;
@import FirebaseCore;
@import FirebaseDynamicLinks;

@interface Devil ()

@end

@implementation Devil

+(Devil*)sharedInstance{
    static Devil *sharedInstance = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        sharedInstance = [[Devil alloc] init];
        UIDevice *device = [UIDevice currentDevice];
        sharedInstance.udid = [[device identifierForVendor] UUIDString];
    });
    return sharedInstance;
}

-(id)init{
    self = [super init];
    [[NSHTTPCookieStorage sharedHTTPCookieStorage] setCookieAcceptPolicy:NSHTTPCookieAcceptPolicyAlways];
    
    return self;
}

-(NSString*)getName{
    NSString* name = [[NSUserDefaults standardUserDefaults] objectForKey:@"NAME"];
    if(name != nil)
        return name;
    if(self.member != nil)
        return self.member[@"name"];
    return nil;
}

-(void)checkMemeber:(NSString*)type identifier:identifier callback:(void (^)(id res))callback{
    [self request:@"/member/check"
        postParam:@{@"type":type,
                    @"identifier":identifier
                    } complete:^(id  _Nonnull res) {
                        callback(res);
                    }];
}

-(void)login:(NSString*)type email:(NSString*)email passwordOrToken:(NSString*)passwordOrToken callback:(void (^)(id res))callback {
    [self request:@"/member/login"
        postParam:@{@"type":type,
                    @"email":email,
                    @"pass":passwordOrToken,
                    } complete:^(id  _Nonnull res) {
                        if(res != nil && [res[@"r"] boolValue] == YES){
                            self.member = res[@"member"];
                            NSString* token = res[@"token"];
                            [[NSUserDefaults standardUserDefaults] setObject:token forKey:@"x-access-token_1605234988599"];
                            [[NSUserDefaults standardUserDefaults] setObject:token forKey:@"token"];
                            [[NSUserDefaults standardUserDefaults] synchronize];
                        }
                        callback(res);
    }];
}

-(NSString*)getLoginToken {
    NSString* token = [[NSUserDefaults standardUserDefaults] objectForKey:@"x-access-token_1605234988599"];
    return token;
}

-(BOOL)isLogin{
    NSString* token = [[NSUserDefaults standardUserDefaults] objectForKey:@"x-access-token_1605234988599"];
    return token != nil;
}
-(void)isLogin:(void (^)(id res))callback{
    [self request:@"/member/islogin" postParam:nil complete:^(id  _Nonnull res) {
        if(res != nil && [res[@"r"] boolValue] == YES){
            self.member = res[@"member"];
        }
        callback(res);
    }];
}

-(void)request:(NSString*)url postParam:(id _Nullable)params complete:(void (^)(id res))callback{

    url = [NSString stringWithFormat:@"%@%@", HOST_API, url];
    
    AFHTTPSessionManager *manager = [AFHTTPSessionManager manager];
    manager.responseSerializer = [AFHTTPResponseSerializer serializer];
    
    NSString* token = [[NSUserDefaults standardUserDefaults] objectForKey:@"token"];
    id headers = [@{@"Accept": @"application/json"} mutableCopy];
    if(token)
        headers[@"x-access-token"] = token;
    
    if(params == nil){
        [manager GET:url parameters:@{} headers:headers progress:nil success:^(NSURLSessionTask *task, id res)
        {
            NSMutableDictionary* r = [NSJSONSerialization JSONObjectWithData:res options:NSJSONReadingMutableContainers error:nil];
            callback(r);
        }
             failure:^(NSURLSessionTask *operation, NSError *error)
        {
            callback(nil);
        }];
    } else {
        [manager POST:url parameters:params headers:headers progress:nil success:^(NSURLSessionTask *task, id res)
        {
            NSMutableDictionary* r = [NSJSONSerialization JSONObjectWithData:res options:NSJSONReadingMutableContainers error:nil];
            callback(r);
        }
             failure:^(NSURLSessionTask *operation, NSError *error)
        {
            callback(nil);
        }];
    }
}

-(void)requestLearn:(NSString*)url postParam:(id _Nullable)params complete:(void (^)(id res))callback{

    url = [NSString stringWithFormat:@"%@%@", LEARN_API, url];
    
    AFHTTPSessionManager *manager = [AFHTTPSessionManager manager];
    manager.responseSerializer = [AFHTTPResponseSerializer serializer];
    
    NSString* token = [[NSUserDefaults standardUserDefaults] objectForKey:@"token"];
    id headers = [@{@"Accept": @"application/json"} mutableCopy];
    if(token)
        headers[@"x-access-token"] = token;
    
    if(params == nil){
        [manager GET:url parameters:@{} headers:headers progress:nil success:^(NSURLSessionTask *task, id res)
        {
            NSMutableDictionary* r = [NSJSONSerialization JSONObjectWithData:res options:NSJSONReadingMutableContainers error:nil];
            callback(r);
        }
             failure:^(NSURLSessionTask *operation, NSError *error)
        {
            callback(nil);
        }];
    } else {
        [manager POST:url parameters:params headers:headers progress:nil success:^(NSURLSessionTask *task, id res)
        {
            NSMutableDictionary* r = [NSJSONSerialization JSONObjectWithData:res options:NSJSONReadingMutableContainers error:nil];
            callback(r);
        }
             failure:^(NSURLSessionTask *operation, NSError *error)
        {
            callback(nil);
        }];
    }
}

-(void)logout{
    self.member = nil;
    NSHTTPCookieStorage *cookieStorage = [NSHTTPCookieStorage sharedHTTPCookieStorage];
    for (NSHTTPCookie *each in cookieStorage.cookies)
        [cookieStorage deleteCookie:each];
    
    [[NSUserDefaults standardUserDefaults] removeObjectForKey:@"x-access-token_1605234988599"];
    [[NSUserDefaults standardUserDefaults] removeObjectForKey:@"token"];
    [[NSUserDefaults standardUserDefaults] synchronize];
}

- (void)consumeReservedUrl {
    if(self.reservedUrl) {
        AppDelegate* app = (AppDelegate*)[UIApplication sharedApplication].delegate;
        MainV2Controller* mainVc = nil;
        for(id vc in app.navigationController.viewControllers ){
            if([vc isKindOfClass:[MainV2Controller class]]) {
                mainVc = vc;
                break;
            }
        }
        if(mainVc) {
            NSURL* url = self.reservedUrl;
            self.reservedUrl = nil;
            if([@"project" isEqualToString:url.host]) {
                id ss = [url.path componentsSeparatedByString:@"/"];
                NSString* command = ss[1];
                if([@"login" isEqualToString:command]) {
                    NSString* project_id = ss[2];
                    NSString* token = ss[3];
                    token = [token stringByReplacingOccurrencesOfString:@"__JUM__" withString:@"."];
                    [WildCardConstructor sharedInstance:project_id];
                    [Jevil save:@"x-access-token" : token];
                    [app.navigationController popToViewController:mainVc animated:NO];
                    [mainVc startProject:project_id];
                } else if([@"start" isEqualToString:command]) {
                    NSString* project_id = ss[2];
                    [app.navigationController popToViewController:mainVc animated:NO];
                    [mainVc startProject:project_id];
                }
            }
        }
    }
}

-(BOOL)openUrl:(NSURL*)url {
    
    if([[FIRDynamicLinks dynamicLinks] handleUniversalLink:url
                                                              completion:^(FIRDynamicLink * _Nullable dynamicLink,
                                                                           NSError * _Nullable error) {
                                                                
        NSLog(@"%@", dynamicLink.url);
        
        [[DeepLink sharedInstance] reserveDeepLink:dynamicLink.url.absoluteString];
        [[DeepLink sharedInstance] consumeDeepLink];
        
        [[DevilLink sharedInstance] setReserveUrl:dynamicLink.url.absoluteString];
    }])
        return YES;

    
    FIRDynamicLink *dynamicLink = [[FIRDynamicLinks dynamicLinks] dynamicLinkFromCustomSchemeURL:url];
    if (dynamicLink && dynamicLink.url) {
        [[DeepLink sharedInstance] reserveDeepLink:dynamicLink.url.absoluteString];
        [[DeepLink sharedInstance] consumeDeepLink];
        
        [[DevilLink sharedInstance] setReserveUrl:[NSString stringWithFormat:@"%@", dynamicLink.url]];
        return YES;
    }
    
    if([url.scheme isEqualToString:@"devil-app-builder"]){
        [Devil sharedInstance].reservedUrl = url;
        [[Devil sharedInstance] consumeReservedUrl];
        return true;
    }
    
    if([DevilLoginSdk application:(UIApplication *)[UIApplication sharedApplication]
                               openURL:(NSURL *)url
                       options:nil])
        return true;
    
    
    if([DevilBillSdk application:(UIApplication *)[UIApplication sharedApplication]
                               openURL:(NSURL *)url
                       options:nil])
        return true;
    
        
    
    if([[GIDSignIn sharedInstance] handleURL:url])
        return true;
    

    //구글 딥링크가 발동했을 했을때
    //url    NSURL *    @"kr.co.trix.sticar://google/link/?deep_link_id=http%3A%2F%2Fwww%2Ecarmile%2Eco%2Ekr%2Finvitation%2Ehtml%3Fcode%3DMTU2Mjg0MTgyNzc5MA&match_type=unique&match_message=Link%20is%20uniquely%20matched%20for%20this%20device%2E"    0x00000002804b0b00
    
    if([[url host] isEqualToString:@"kakaolink"]){
        NSMutableDictionary *params = [[NSMutableDictionary alloc] init];
        for (NSString *param in [[url query] componentsSeparatedByString:@"&"]) {
            NSArray *elts = [param componentsSeparatedByString:@"="];
            if([elts count] < 2) continue;
            [params setObject:[elts lastObject] forKey:[elts firstObject]];
        }
        NSString* type = params[@"type"];
        if([type isEqualToString:@"product"]){
            NSString* sticar_no = params[@"type"];
        }
        else if([type isEqualToString:@"invite"]){
            NSString* code = params[@"code"];
        }
        return true;
    }
                
    return false;
}

@end
