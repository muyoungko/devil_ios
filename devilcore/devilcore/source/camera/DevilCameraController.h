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

@class DevilCameraController;

@protocol DevilCameraControllerDelegate <NSObject>
@optional
- (void)completeCapture:(DevilCameraController *)controller result:(id)result;
@end

@interface DevilCameraController : UIViewController<AVCaptureVideoDataOutputSampleBufferDelegate, UINavigationControllerDelegate,UIImagePickerControllerDelegate>

@property (nonatomic, retain) id param;
@property (nonatomic, retain) id<DevilCameraControllerDelegate> delegate;

@end

NS_ASSUME_NONNULL_END
