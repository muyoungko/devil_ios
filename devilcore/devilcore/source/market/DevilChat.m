//
//  DevilChat.m
//  devilcore
//
//  Created by Mu Young Ko on 2021/07/12.
//

#import "DevilChat.h"
#import "JevilCtx.h"
#import "JevilInstance.h"

@implementation DevilChat

- (void)created {
    [super created];
    NSString* script = self.marketJson[@"created"];
    [self.meta.jevil code:script viewController:[JevilInstance currentInstance].vc data:self.meta.correspondData meta:self.meta];
}

@end
