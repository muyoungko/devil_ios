//
//  DevilQrCameraController.h
//  devilcore
//
//  Created by Mu Young Ko on 2021/08/21.
//

#import <UIKit/UIKit.h>
#import <ZXingObjC/ZXingObjC.h>

NS_ASSUME_NONNULL_BEGIN

@protocol DevilQrCameraControllerDelegate <NSObject>

- (void)captureResult:(id)result;

@end

@interface DevilQrCameraController : UIViewController<ZXCaptureDelegate>
{
    CGAffineTransform _captureSizeTransform;
    Boolean callbacked;
}

@property (retain, nonatomic) id<DevilQrCameraControllerDelegate> delegate;
@property (retain, nonatomic) NSString* blockName;
- (void)construct;

@end

NS_ASSUME_NONNULL_END
