//
//  JevilInstance.m
//  devilcore
//
//  Created by Mu Young Ko on 2021/01/14.
//

#import "JevilInstance.h"

@implementation JevilInstance

+(JevilInstance*)globalInstance{
    static JevilInstance *sharedInstance = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        sharedInstance = [[JevilInstance alloc] init];
    });
    return sharedInstance;
}

+(JevilInstance*)screenInstance{
    static JevilInstance *sharedInstance = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        sharedInstance = [[JevilInstance alloc] init];
    });
    return sharedInstance;
}

+(JevilInstance*)currentInstance{
    static JevilInstance *sharedInstance = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        sharedInstance = [[JevilInstance alloc] init];
    });
    return sharedInstance;
}


@end
