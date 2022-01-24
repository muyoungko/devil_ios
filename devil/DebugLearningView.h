//
//  DebugLearningView.h
//  devil
//
//  Created by Mu Young Ko on 2022/01/10.
//  Copyright © 2022 Mu Young Ko. All rights reserved.
//

#import <UIKit/UIKit.h>
@import devilcore;

NS_ASSUME_NONNULL_BEGIN

@interface DebugLearningView : UIView

+ (DebugLearningView*)constructDebugViewIf:(DevilController*)vc;
- (instancetype)initWithVc:(DevilController*)vc;
- (void)check;

@end 

NS_ASSUME_NONNULL_END
