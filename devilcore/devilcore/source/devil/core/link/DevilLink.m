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
    if(!url) {
        callback(@{@"r":@FALSE, @"msg":@"url is missing"});
    } else if(!dynamicLinksDomainURIPrefix) {
        callback(@{@"r":@FALSE, @"msg":@"prefix is missing"});
    } else if(!title) {
        callback(@{@"r":@FALSE, @"msg":@"title is missing"});
    } else if(!desc) {
        callback(@{@"r":@FALSE, @"msg":@"desc is missing"});
    } else if(self.delegate) {
        [self.delegate createFirebaseDynamicLink:param callback:^(id  _Nonnull res) {
            callback(res);
        }];
    } else {
        callback(@{@"r":@FALSE, @"msg":@"DevilLink delegate is not set"});
    }
    
    
}

-(void)setReserveUrl:(NSString*)url{
    
}

-(NSString*)getReserveUrl{
    return @"";
}

-(NSString*)popReserveUrl{
    return @"";
}
@end
