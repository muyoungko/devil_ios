//
//  DevilLink.m
//  devilcore
//
//  Created by Mu Young Ko on 2021/09/09.
//

#import "DevilLink.h"
#import "WildCardConstructor.h"

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
@end
