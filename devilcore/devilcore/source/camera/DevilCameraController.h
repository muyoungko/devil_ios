//
//  DevilCameraController.h
//  devilcore
//
//  Created by Mu Young Ko on 2021/04/11.
//

#import <UIKit/UIKit.h>

@import AVKit;
@import AVFoundation;

NS_ASSUME_NONNULL_BEGIN

@interface DevilCameraController : UIViewController<AVCaptureVideoDataOutputSampleBufferDelegate, UINavigationControllerDelegate,UIImagePickerControllerDelegate>

@property (nonatomic, retain) id param;

@end

NS_ASSUME_NONNULL_END
