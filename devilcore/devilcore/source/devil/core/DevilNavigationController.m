//
//  DevilNavigationController.m
//  devilcore
//
//  Created by Mu Young Ko on 2021/07/04.
//

#import "DevilNavigationController.h"

@interface DevilNavigationController ()

@end

@implementation DevilNavigationController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
}


- (UIViewController *)childViewControllerForStatusBarStyle {
    return self.topViewController;
}

@end
