//
//  DevilLink.m
//  devilcore
//
//  Created by Mu Young Ko on 2021/09/09.
//

#import "DevilLink.h"
#import "WildCardConstructor.h"
#import "JevilInstance.h"
#import "DevilController.h"
#import "MappingSyntaxInterpreter.h"
#import "Jevil.h"
#import "DevilUtil.h"

@import UserNotifications;

@implementation DevilLink

+ (DevilLink*)sharedInstance {
    static DevilLink *sharedInstance = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        sharedInstance = [[self alloc] init];
    });
    return sharedInstance;
}


-(void)create:(id)param callback:(void (^)(id res))callback {
    
    NSString* url = param[@"url"];
    if([url hasPrefix:@"/"])
        param[@"url"] = url = [NSString stringWithFormat:@"%@%@", [WildCardConstructor sharedInstance].project[@"web_host"], url];
    NSString* dynamicLinksDomainURIPrefix = param[@"prefix"];
    NSString* title = param[@"title"];
    NSString* desc = param[@"desc"];
    NSString* package_android = param[@"package_android"];
    NSString* package_ios = param[@"package_ios"];
    
    if(!url) {
        callback(@{@"r":@FALSE, @"msg":@"url is missing"});
    } else if(!dynamicLinksDomainURIPrefix) {
        callback(@{@"r":@FALSE, @"msg":@"prefix is missing"});
    } else if(!title) {
        callback(@{@"r":@FALSE, @"msg":@"title is missing"});
    } else if(!desc) {
        callback(@{@"r":@FALSE, @"msg":@"desc is missing"});
    } else if(!package_android) {
        callback(@{@"r":@FALSE, @"msg":@"package_android is missing"});
    } else if(!package_ios) {
        callback(@{@"r":@FALSE, @"msg":@"package_ios is missing"});
    } else if(self.delegate) {
        
        NSString *bundle = [[NSBundle mainBundle] bundleIdentifier];
        if([bundle isEqualToString:@"kr.co.july.CloudJsonViewer"]) {
            param[@"package_android"] = @"kr.co.july.cloudjsonviewer";
            param[@"package_ios"] = @"kr.co.july.CloudJsonViewer";
            param[@"prefix"] = @"https://sketchtoapp.page.link";
            param[@"appstore_id"] = @"1540234300";
        }
        
        [self.delegate createFirebaseDynamicLink:param callback:^(id  _Nonnull res) {
            callback(res);
        }];
    } else {
        callback(@{@"r":@FALSE, @"msg":@"DevilLink delegate is not set"});
    }
}

-(void)setReserveUrl:(NSString*)url{
    [[NSUserDefaults standardUserDefaults] setObject:url forKey:@"DEVIL_LINK"];
    [[NSUserDefaults standardUserDefaults] synchronize];
}

-(NSString*)getReserveUrl{
    return [[NSUserDefaults standardUserDefaults] objectForKey:@"DEVIL_LINK"];
}

-(NSString*)popReserveUrl{
    NSString* r = [[NSUserDefaults standardUserDefaults] objectForKey:@"DEVIL_LINK"];
    [[NSUserDefaults standardUserDefaults] removeObjectForKey:@"DEVIL_LINK"];
    return r;
}

-(BOOL)standardUrlProcess:(NSString*)urls{
    BOOL consumed = false;
    NSURL* url = [NSURL URLWithString:urls];
    NSString* path = [url path];
    id pp = [path componentsSeparatedByString:@"/"];
    NSString* command = pp[1];
    if([@"screen" isEqualToString:command]){
        NSString* screenName = pp[2];
        id data = [DevilUtil queryToJson:url];
        [Jevil go:screenName :data];
        consumed = YES;
    } else if([@"replaceScreen" isEqualToString:command]){
        NSString* screenName = pp[2];
        id data = [DevilUtil queryToJson:url];
        [Jevil replaceScreen:screenName :data];
        consumed = YES;
    } else if([@"rootScreen" isEqualToString:command]){
        NSString* screenName = pp[2];
        id data = [DevilUtil queryToJson:url];
        [Jevil rootScreen:screenName :data];
        consumed = YES;
    }
    return consumed;
}

-(BOOL)consumeStandardReserveUrl{
    NSString* urls = [self getReserveUrl];
    BOOL consumed = NO;
    if(urls) {
        consumed = [self standardUrlProcess:urls];
    }
    
    if(consumed)
        [self popReserveUrl];
    
    return consumed;
}

-(BOOL)checkCond:(id)cond {
    BOOL r = true;
    if(cond[@"screen_name"]) {
        if([JevilInstance currentInstance] && [JevilInstance currentInstance].vc) {
            UIViewController* a = [JevilInstance currentInstance].vc;
            if([a isMemberOfClass:[DevilController class]]) {
                NSString* screenName = ((DevilController*) a).screenName;
                if(![screenName isEqualToString:cond[@"screen_name"]])
                    r = false;
            } else
                r = false;
        } else
            r = false;
    }

    if(cond[@"data_condition"]){
        if([JevilInstance currentInstance] && [JevilInstance currentInstance].data) {
            BOOL ifr = [MappingSyntaxInterpreter ifexpression:cond[@"data_condition"] data:[JevilInstance currentInstance].data];
            if(!ifr)
                r = false;
        } else
            r = false;
    }
    return r;
}

-(BOOL)checkNotificationShouldShow:(NSDictionary*)data {
    NSString* show = @"force";
    if(data[@"show"])
        show = data[@"show"];
    id cond = @{};
    if(data[@"cond"]) {
        NSString* condString = data[@"cond"];
        cond = [NSJSONSerialization JSONObjectWithData:[condString dataUsingEncoding:NSUTF8StringEncoding] options:0 error:nil];
    }
    if([show isEqualToString:@"force"])
        return true;
    else if([show isEqualToString:@"hide"]){
        return false;
    } else if([show isEqualToString:@"cond_show"]) {
        return [self checkCond:cond];
    } else if([show isEqualToString:@"cond_hide"]) {
        return ![self checkCond:cond];
    }
    
    return true;
}

-(void)localPush:(id)param{
    NSString* title = param[@"title"];
    NSString* msg = param[@"msg"];
    NSString* url = param[@"url"];
    
    UNMutableNotificationContent* content = [[UNMutableNotificationContent alloc] init];
    content.title = title;
    content.body = msg;
    content.userInfo = [@{@"url":url} mutableCopy];

    UNTimeIntervalNotificationTrigger* trigger = [UNTimeIntervalNotificationTrigger
                triggerWithTimeInterval:1 repeats:NO];
    UNNotificationRequest* request = [UNNotificationRequest requestWithIdentifier:@"FiveSecond"
                content:content trigger:trigger];
     
    // Schedule the notification.
    UNUserNotificationCenter* center = [UNUserNotificationCenter currentNotificationCenter];
    
    [center addNotificationRequest:request withCompletionHandler:^(NSError * _Nullable error) {
       if (error != nil) {
           NSLog(@"%@", error.localizedDescription);
       }
    }];

}

@end
