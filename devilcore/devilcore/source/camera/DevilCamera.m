//
//  DevilCamera.m
//  devilcore
//
//  Created by Mu Young Ko on 2021/04/11.
//

#import "DevilCamera.h"
#import "DevilCameraController.h"
#import "DevilUtil.h"
#import "DevilQrCameraController.h"

@import AVKit;
@import AVFoundation;
@import Photos;

@interface DevilCamera ()<DevilCameraControllerDelegate>

@property void (^callback)(id res);
@end

@implementation DevilCamera

+(void)changePhAssetToUrlPath:(id)list callback:(void (^)(id res))callback {
    
    PHImageRequestOptions* requestOptions = [[PHImageRequestOptions alloc] init];
    requestOptions.resizeMode   = PHImageRequestOptionsResizeModeExact;
    requestOptions.deliveryMode = PHImageRequestOptionsDeliveryModeHighQualityFormat;
    // this one is key
    requestOptions.synchronous = YES;

    PHImageManager *manager = [PHImageManager defaultManager];


    id r = [@[] mutableCopy];
    for(NSString* url in list) {
        if([url hasPrefix:@"gallery://"]) {
            NSString* phurl = [url stringByReplacingOccurrencesOfString:@"gallery://" withString:@""];
            PHFetchResult *results = [PHAsset fetchAssetsWithLocalIdentifiers:@[phurl] options:nil];
            [results enumerateObjectsUsingBlock:^(PHAsset *asset, NSUInteger idx, BOOL * _Nonnull stop) {
                [manager requestImageDataForAsset:asset
                                          options:requestOptions
                                    resultHandler:^(NSData *data, NSString *dataUTI,
                                                    UIImageOrientation orientation,
                                                    NSDictionary *info) {
                    
                    UIImage* preview = [UIImage imageWithData:data];
                    preview = [DevilUtil resizeImageProperly:preview];
                    NSData *imageData = UIImageJPEGRepresentation(preview, 0.6f);
                    NSString* outputFileName = [NSUUID UUID].UUIDString;
                    NSString* targetPath = [NSTemporaryDirectory() stringByAppendingPathComponent:[outputFileName stringByAppendingPathExtension:@"jpg"]];
                    [imageData writeToFile:targetPath atomically:YES];
                    [r addObject:targetPath];
                }];
                *stop = true;
            }];
        } else {
            [r addObject:url];
        }
    }
    
    callback(r);
}

+ (void)reverse:(NSMutableArray*)array {
    if ([array count] <= 1)
        return;
    NSUInteger i = 0;
    NSUInteger j = [array count] - 1;
    while (i < j) {
        [array exchangeObjectAtIndex:i
                  withObjectAtIndex:j];

        i++;
        j--;
    }
}

+(void)getGelleryList:(UIViewController*)vc param:(id)param callback:(void (^)(id res))callback{
    [DevilCamera requestCameraPermission:^(BOOL granted) {
        if(granted) {
            PHFetchResult *results = [PHAsset fetchAssetsWithMediaType:PHAssetMediaTypeImage options:nil];
            id r = [@[] mutableCopy];
            int end = 1000;
            [results enumerateObjectsUsingBlock:^(PHAsset *obj, NSUInteger idx, BOOL * _Nonnull stop) {
                [r addObject:[@{
                    @"url":[NSString stringWithFormat:@"gallery://%@", obj.localIdentifier]
                } mutableCopy]];
                if(idx < end)
                    *stop = false;
                else
                    *stop = true;
            }];
            
            [self reverse:r];
            
            callback([@{@"r":@TRUE, @"list":r} mutableCopy]);
        } else {
            callback([@{@"r":@FALSE} mutableCopy]);
        }
    }];
}

+(void)camera:(UIViewController*)vc param:(id)param callback:(void (^)(id res))callback{
    
    [DevilCamera requestCameraPermission:^(BOOL granted) {
        if(granted) {
            if([param[@"hasVideo"] boolValue]){
                [[AVAudioSession sharedInstance] requestRecordPermission:^(BOOL recordGranted) {
                    if(recordGranted)
                        [DevilCamera goCamera:vc param:param callback:callback];
                    else
                        callback(nil);
                }];
            } else {
                [DevilCamera goCamera:vc param:param callback:callback];
            }
        } else {
            callback(nil);
        }
    }];
}



+(void)cameraQr:(UIViewController*)vc param:(id)param callback:(void (^)(id res))callback {
    [DevilCamera requestCameraPermission:^(BOOL granted) {
        if(granted) {
            DevilQrCameraController* dc = [[DevilQrCameraController alloc] init];
            
            if(param[@"blockName"]) {
                dc.blockName = param[@"blockName"];
            }
            
            if(param[@"startFront"]) {
                dc.front = [param[@"startFront"] boolValue];
            } else
                dc.front = false;
            
            if(param[@"finish"]) {
                dc.finish = [param[@"finish"] boolValue];
            } else
                dc.finish = YES;
            
            [dc construct];
            DevilCamera *c = [[DevilCamera alloc] init];
            c.callback = callback;
            dc.delegate = c;
            [vc.navigationController presentViewController:dc animated:YES completion:^{

            }];
        } else {
            callback(nil);
        }
    }];
}

- (void)captureResult:(id)result{
    if(self.callback) {
        self.callback(result);
    }
}

+ (void)goCamera:(UIViewController*)vc param:(id)param callback:(void (^)(id res))callback {
    dispatch_async(dispatch_get_main_queue(), ^{
        DevilCameraController* dc = [[DevilCameraController alloc] init];
        DevilCamera *c = [[DevilCamera alloc] init];
        dc.param = param;
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
