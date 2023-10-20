//
//  DevilSwipeBackGesture.h
//  devilcore
//
//  Created by Mu Young Ko on 2023/10/20.
//

#import <Foundation/Foundation.h>
@import UIKit;

NS_ASSUME_NONNULL_BEGIN

@interface DevilSwipeBackGesture : NSObject<UIGestureRecognizerDelegate, UINavigationControllerDelegate>

+(DevilSwipeBackGesture*)sharedInstance;

@property (nonatomic, retain) UINavigationController* nav;
@property BOOL duringTransition;

@end

NS_ASSUME_NONNULL_END
