//
//  DevilBillSdk.m
//  devilbill
//
//  Created by Mu Young Ko on 2023/08/14.
//

#import "DevilWebRtcSdk.h"

@implementation DevilWebRtcSdk

+ (BOOL)application:(UIApplication *)application
            openURL:(NSURL *)url
            options:(NSDictionary<UIApplicationOpenURLOptionsKey,id> *)options{
    
    NSString* path = [[NSBundle mainBundle] pathForResource:@"devil" ofType:@"plist"];
    id devilConfig = [[NSDictionary alloc] initWithContentsOfFile:path];
    
    return false;
}

@end
