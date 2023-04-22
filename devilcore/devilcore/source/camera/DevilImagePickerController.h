//
//  DevilImagePickerController.h
//  devilcore
//
//  Created by Mu Young Ko on 2022/09/21.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

@interface DevilImagePickerController : UIImagePickerController
@property BOOL landscape; // viewController가 시작할때의 가로세로모드
@property BOOL actualLandscape; // viewController가 실제 기기가 돌아갈때의 가로 세로 모드
@property BOOL showFrame;
@property float rate;
@property void (^callback)(id res);

-(void)construct;
-(void)constructOverlay;


@end

NS_ASSUME_NONNULL_END
