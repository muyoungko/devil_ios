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
  
    [[Devil sharedInstance] requestLearn:@"/api/step/success" postParam:nil complete:^(id  _Nonnull res) {
        [Jevil alertFinish:@"성공하셨습니다"];
    }];
}


@end
