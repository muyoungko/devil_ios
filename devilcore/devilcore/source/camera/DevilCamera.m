//
//  DevilCamera.m
//  devilcore
//
//  Created by Mu Young Ko on 2021/04/11.
//

#import "DevilCamera.h"
#import "DevilCameraController.h"

@import AVKit;
@import AVFoundation;

@interface DevilCamera ()<DevilCameraControllerDelegate>

@property void (^callback)(id res);

@end

@implementation DevilCamera

+(void)camera:(UIViewController*)vc param:(id)param callback:(void (^)(id res))callback{
    
    [DevilCamera requestCameraPermission:^(BOOL granted) {
        if(granted) {
            if([param[@"hasVideo"] boolValue]){
                [[AVAudioSession sharedInstance] requestRecordPermission:^(BOOL recordGranted) {
                    if(recordGranted)
                        [DevilCamera goCamera:vc callback:callback];
                    else
                        callback(nil);
                }];
            } else {
                [DevilCamera goCamera:vc callback:callback];
            }
        } else {
            callback(nil);
        }
    }];
}

+ (void)goCamera:(UIViewController*)vc callback:(void (^)(id res))callback {
    dispatch_async(dispatch_get_main_queue(), ^{
        DevilCameraController* dc = [[DevilCameraController alloc] init];
        DevilCamera *c = [[DevilCamera alloc] init];
        c.callback = callback;
        dc.delegate = c;
        
        [vc.navigationController pushViewController:dc animated:YES];
    });
}

- (void)completeCapture:(DevilCameraController *)controller result:(id)result{
    if(result != nil){
        result[@"r"] = @TRUE;
        self.callback(result);
    } else {
        result = [@{} mutableCopy];
        result[@"r"] = @FALSE;
        self.callback(result);
    }
}

+ (void)requestCameraPermission:(void (^)(BOOL granted))callback {
    
    // check camera authorization status
    AVAuthorizationStatus authStatus = [AVCaptureDevice authorizationStatusForMediaType:AVMediaTypeVideo];
    switch (authStatus) {
        case AVAuthorizationStatusAuthorized: { // camera authorized
            callback(true);
        }
            break;
        case AVAuthorizationStatusRestricted:
        case AVAuthorizationStatusDenied:
        case AVAuthorizationStatusNotDetermined: { // request authorization
            
            [AVCaptureDevice requestAccessForMediaType:AVMediaTypeVideo completionHandler:^(BOOL granted) {
                dispatch_async(dispatch_get_main_queue(), ^{
                    callback(granted);
                });
            }];
            }
            break;
        default:
            break;
    }
}

@end
