//
//  JevilHealth.m
//  devilcore
//
//  Created by Mu Young Ko on 2022/09/03.
//

#import "JevilHealth.h"
#import "DevilHealth.h"

@implementation JevilHealth


+ (void)requestPermission:(NSDictionary*)param:(JSValue *)callback {
    [[DevilHealth sharedInstance] requestPermission:param callback:^(id  _Nonnull res) {
        [callback callWithArguments:@[res]];
    }];
}

+ (void)requestHealthData:(NSDictionary*)param :(JSValue *)callback {
    [[DevilHealth sharedInstance] requestHealthData:param callback:^(id  _Nonnull res) {
        [callback callWithArguments:@[res]];
    }];
}


@end
