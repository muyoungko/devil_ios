//
//  JevilUtil.m
//  devilcore
//
//  Created by Mu Young Ko on 2021/01/30.
//

#import "JevilUtil.h"
#import "JevilInstance.h"

@implementation JevilUtil

id devInfoCache = nil;


+(id)devInfoTo:(id)header {
    if(devInfoCache == nil) {
        devInfoCache = [@{} mutableCopy];

        id package = [[NSBundle mainBundle] bundleIdentifier];
        if([@"kr.co.july.CloudJsonViewer" isEqualToString:package]) {
            NSString* member_no = [[NSUserDefaults standardUserDefaults] objectForKey:[NSString stringWithFormat:@"MEMBER_NO_1605234988599"]];
            devInfoCache[@"package"] = [[NSBundle mainBundle] bundleIdentifier];
            devInfoCache[@"member_no"] = member_no;
            devInfoCache[@"x-access-token-master"] =  [[NSUserDefaults standardUserDefaults] objectForKey:@"x-access-token_1605234988599"];
        }
    }
    
    if(devInfoCache[@"member_no"])
        header[@"x-member-no"] = devInfoCache[@"member_no"];
    if(devInfoCache[@"package"])
        header[@"x-package"] = @"kr.co.july.cloudjsonviewer";
    if(devInfoCache[@"x-access-token-master"])
        header[@"x-access-token-master"] = devInfoCache[@"x-access-token-master"];
    
    return devInfoCache;
}

@end
