//
//  DevilSdk.m
//  devilcore
//
//  Created by Mu Young Ko on 2020/11/22.
//

#import "DevilSdk.h"

@implementation DevilSdk

+(DevilSdk*)sharedInstance{
    static DevilSdk *sharedInstance = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        sharedInstance = [[DevilSdk alloc] init];
    });
    return sharedInstance;
}

@end
