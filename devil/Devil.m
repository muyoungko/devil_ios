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
#import "MainController.h"
@import devilcore;

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
                            [[NSUserDefaults standardUserDefaults] setObject:token forKey:@"token"];
                            [[NSUserDefaults standardUserDefaults] synchronize];
                            [self sendPush];
                        }
                        callback(res);
    }];
}

-(BOOL)isLogin{
    NSString* token = [[NSUserDefaults standardUserDefaults] objectForKey:@"token"];
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
    id headers = [@{@"Origin":@"http://m.bnbhostsering.com",
                    @"Accept": @"application/json"
    } mutableCopy];
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
    NSHTTPCookieStorage *cookieStorage = [NSHTTPCookieStorage sharedHTTPCookieStorage];
    for (NSHTTPCookie *each in cookieStorage.cookies)
        [cookieStorage deleteCookie:each];
    
    self.member = nil;
    [[NSUserDefaults standardUserDefaults] removeObjectForKey:@"token"];
    [[NSUserDefaults standardUserDefaults] synchronize];
}

- (void)sendPush{
    NSString* fcm = [[NSUserDefaults standardUserDefaults] objectForKey:@"FCM"];
    if(fcm == nil)
        return;
    NSString* url = [NSString stringWithFormat:@"/push/key?fcm=%@&udid=%@&os=ios", urlencode(fcm), urlencode(self.udid)];
    [[Devil sharedInstance] request:url postParam:nil complete:^(id  _Nonnull res) {
        NSLog(@"%@",res);
    }];
}

- (void)consumeReservedUrl {
    if(self.reservedUrl) {
        AppDelegate* app = (AppDelegate*)[UIApplication sharedApplication].delegate;
        MainController* mainVc = nil;
        for(id vc in app.navigationController.viewControllers ){
            if([vc isKindOfClass:[MainController class]]) {
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
                    NSString* xAccessToken = ss[3];
                    [WildCardConstructor sharedInstance:project_id];
                    [Jevil save:@"x-access-token" : xAccessToken];
                    [app.navigationController popToViewController:mainVc animated:NO];
                    [mainVc startProject:project_id];
                }
            }
        }
    }
}



@end
