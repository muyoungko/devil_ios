//
//  JevilNfc.m
//  devilnfc
//
//  Created by Mu Young Ko on 2022/09/23.
//

#import "JevilNfc.h"
#import "DevilNfc.h"

@import devilcore;

@implementation JevilNfc

+ (void)start:(NSDictionary*)param :(JSValue*)callback {
    [[JevilFunctionUtil sharedInstance] registFunction:callback];
    [[DevilNfc sharedInstance] start:param :^(id  _Nonnull res) {
        [[JevilFunctionUtil sharedInstance] callFunction:callback params:@[res]];
    }];
}

+ (void)stop {
    [[DevilNfc sharedInstance] stop];
}


@end
