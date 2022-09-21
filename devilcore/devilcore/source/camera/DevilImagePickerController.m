//
//  DevilImagePickerController.m
//  devilcore
//
//  Created by Mu Young Ko on 2022/09/21.
//

#import "DevilImagePickerController.h"

@interface DevilImagePickerController ()

@end

@implementation DevilImagePickerController

- (void)viewDidLoad {
    [super viewDidLoad];
}

- (BOOL)shouldAutorotate {
    return NO;
}

- (UIInterfaceOrientationMask)supportedInterfaceOrientations{
    
    if(self.landscape){
        NSLog(@"supportedInterfaceOrientations landscape");
        return UIInterfaceOrientationMaskLandscapeLeft | UIInterfaceOrientationMaskLandscapeRight;
    } else {
        NSLog(@"supportedInterfaceOrientations portrait");
        return UIInterfaceOrientationMaskPortrait;
    }
}

- (UIInterfaceOrientation)preferredInterfaceOrientationForPresentation {
    if(self.landscape) {
        NSLog(@"preferredInterfaceOrientationForPresentation landscape");
        return UIInterfaceOrientationLandscapeLeft
        | UIInterfaceOrientationLandscapeRight;
    } else {
        NSLog(@"preferredInterfaceOrientationForPresentation portrait");
        return UIInterfaceOrientationPortrait;
    }
}


@end
