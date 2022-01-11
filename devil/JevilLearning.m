//
//  JevilLearning.m
//  devil
//
//  Created by Mu Young Ko on 2022/01/10.
//  Copyright © 2022 Mu Young Ko. All rights reserved.
//

#import "JevilLearning.h"
#import "Devil.h"
@import devilcore;

@implementation JevilLearning

+ (void)success{
    NSString* screen_id = ((DevilController*)[JevilInstance currentInstance].vc).screenId;
    NSString* path = [NSString stringWithFormat:@"/api/step/success/%@", screen_id];
    [[Devil sharedInstance] requestLearn:path postParam:nil complete:^(id  _Nonnull res) {
        if(res && [res[@"r"] boolValue])
            [Jevil alertFinish:@"성공하셨습니다"];
        else
            [Jevil alert:@"일시적 오류가 발생하였습니다. 다시 시도해주세요"];
    }];
}


@end
