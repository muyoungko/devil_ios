//
//  DevilAVCamPhotoCaptureDelegate.h
//  devilcore
//
//  Created by Mu Young Ko on 2021/04/12.
//

#import <Foundation/Foundation.h>
@import AVFoundation;

NS_ASSUME_NONNULL_BEGIN

@interface DevilAVCamPhotoCaptureDelegate : NSObject<AVCapturePhotoCaptureDelegate>

- (instancetype)initWithRequestedPhotoSettings:(AVCapturePhotoSettings *)requestedPhotoSettings willCapturePhotoAnimation:(void (^)(void))willCapturePhotoAnimation livePhotoCaptureHandler:(void (^)( BOOL capturing ))livePhotoCaptureHandler completionHandler:(void (^)( DevilAVCamPhotoCaptureDelegate *photoCaptureDelegate ))completionHandler photoProcessingHandler:(void (^)(BOOL))animate;

@property (nonatomic, readonly) AVCapturePhotoSettings *requestedPhotoSettings;

@end

NS_ASSUME_NONNULL_END
