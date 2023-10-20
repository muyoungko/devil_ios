//
//  DevilSwipeBackGesture.m
//  devilcore
//
//  Created by Mu Young Ko on 2023/10/20.
//

#import "DevilSwipeBackGesture.h"

@implementation DevilSwipeBackGesture

+ (DevilSwipeBackGesture*)sharedInstance {
    static DevilSwipeBackGesture *sharedInstance = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        sharedInstance = [[self alloc] init];
    });
    return sharedInstance;
}

- (void)navigationController:(UINavigationController *)navigationController didShowViewController:(UIViewController *)viewController animated:(BOOL)animated {
    self.duringTransition = NO;
}

- (BOOL)gestureRecognizerShouldBegin:(UIGestureRecognizer *)gestureRecognizer {
    if(self.duringTransition)
        return NO;
    return ([self.nav.viewControllers count] > 1);
}


@end
