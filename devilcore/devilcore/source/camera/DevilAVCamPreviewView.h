//
//  DevilAVCamPreviewView.h
//  devilcore
//
//  Created by Mu Young Ko on 2021/04/11.
//

#import <Foundation/Foundation.h>

@import UIKit;
@class AVCaptureSession;

NS_ASSUME_NONNULL_BEGIN

@interface DevilAVCamPreviewView : UIView

@property (nonatomic, readonly) AVCaptureVideoPreviewLayer *videoPreviewLayer;
@property (nonatomic) AVCaptureSession *session;

@end

NS_ASSUME_NONNULL_END
