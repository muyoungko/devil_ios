//
//  DevilImagePickerController.m
//  devilcore
//
//  Created by Mu Young Ko on 2022/09/21.
//

#import "DevilImagePickerController.h"
@import AVFoundation;

@interface DevilImagePickerController ()

@property (nonatomic) BOOL pictureTakening;
@property (nonatomic) float oldVolume;

@end

@implementation DevilImagePickerController

- (void)viewDidLoad {
    [super viewDidLoad];
    
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    [[NSNotificationCenter defaultCenter] addObserver:self
                                      selector:@selector(volumeDown:)
                                      name:@"_UIApplicationVolumeDownButtonDownNotification"
                                      object:nil];
}

- (void)volumeDown:(id)s {
    [self takePicture];
}

- (void)viewWillDisappear:(BOOL)animated {
    [super viewWillDisappear:animated];
    [[NSNotificationCenter defaultCenter] removeObserver:self name:@"_UIApplicationVolumeDownButtonDownNotification" object:nil];
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
