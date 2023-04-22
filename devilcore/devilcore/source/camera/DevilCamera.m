//
//  DevilCamera.m
//  devilcore
//
//  Created by Mu Young Ko on 2021/04/11.
//

#import "DevilCamera.h"
#import "DevilCameraController.h"
#import "DevilGalleryController.h"
#import "DevilUtil.h"
#import "DevilQrCameraController.h"
#import "WildCardUtil.h"
#import "DevilImagePickerController.h""
#import "WildCardConstructor.h"

@import AVKit;
@import AVFoundation;
@import Photos;

@interface DevilCamera ()<DevilCameraControllerDelegate, UIImagePickerControllerDelegate, UINavigationControllerDelegate>

@property void (^callback)(id res);
@property (nonatomic, retain) id param;
@property (nonatomic, retain) UIImagePickerController *picker;
@end

@implementation DevilCamera

+ (DevilCamera*)sharedInstance {
    static DevilCamera *sharedInstance = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        sharedInstance = [[self alloc] init];
    });
    return sharedInstance;
}


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

+(void)galleryList:(UIViewController*)vc param:(id)param callback:(void (^)(id res))callback{
    [DevilCamera requestGalleryPermission:^(BOOL granted) {
        if(granted) {
            
            BOOL hasPicture = param && param[@"hasPicture"] ? [param[@"hasPicture"] boolValue] : YES;
            BOOL hasVideo = param && param[@"hasVideo"] ? [param[@"hasVideo"] boolValue] : NO;
            
            id r = [@[] mutableCopy];
            int end = 100000;
            
            if(hasPicture) {
                PHFetchOptions *options = [PHFetchOptions new];
                options.sortDescriptors = @[ [NSSortDescriptor sortDescriptorWithKey:@"creationDate" ascending:NO] ];
                PHFetchResult *results = [PHAsset fetchAssetsWithMediaType:PHAssetMediaTypeImage options:options];
                [results enumerateObjectsUsingBlock:^(PHAsset *obj, NSUInteger idx, BOOL * _Nonnull stop) {
                    NSDate* cdate = obj.creationDate;
                    long d = (long)([cdate timeIntervalSince1970] * 1000);
                    [r addObject:[@{
                        @"id":[NSNumber numberWithInt:(int)idx],
                        @"url":[NSString stringWithFormat:@"gallery://%@", obj.localIdentifier],
                        @"image":[NSString stringWithFormat:@"gallery://%@", obj.localIdentifier],
                        @"date": [NSNumber numberWithLong:d],
                        @"type":@"image",
                    } mutableCopy]];
                    if(idx < end)
                        *stop = false;
                    else
                        *stop = true;
                }];
            }
            
            if(hasVideo) {
                end = 10000;
                PHFetchOptions *options = [PHFetchOptions new];
                options.sortDescriptors = @[ [NSSortDescriptor sortDescriptorWithKey:@"creationDate" ascending:NO] ];
                PHFetchResult *results = [PHAsset fetchAssetsWithMediaType:PHAssetMediaTypeVideo options:options];
                [results enumerateObjectsUsingBlock:^(PHAsset *obj, NSUInteger idx, BOOL * _Nonnull stop) {
                    NSDate* cdate = obj.creationDate;
                    long d = (long)([cdate timeIntervalSince1970] * 1000);
                    [r addObject:[@{
                        @"id":[NSNumber numberWithInt:(int)idx],
                        @"url":[NSString stringWithFormat:@"gallery://%@", obj.localIdentifier],
                        @"video":[NSString stringWithFormat:@"gallery://%@", obj.localIdentifier],
                        @"date": [NSNumber numberWithLong:d],
                        @"type":@"video",
                        @"duration": [NSNumber numberWithInt:(int)obj.duration],
                    } mutableCopy]];
                    if(idx < end)
                        *stop = false;
                    else
                        *stop = true;
                }];
            }
            
            r = [r sortedArrayUsingComparator:^NSComparisonResult(id a, id b) {
                return [b[@"date"] longValue] - [a[@"date"] longValue];
            }];
            
            callback([@{@"r":@TRUE, @"list":r} mutableCopy]);
        } else {
            callback([@{@"r":@FALSE} mutableCopy]);
        }
    }];
}

-(void)gallerySystem:(UIViewController*)vc param:(id)param callback:(void (^)(id res))callback{
    [DevilCamera requestCameraPermission:^(BOOL granted) {
        if(granted) {
            UIImagePickerController *picker = [[UIImagePickerController alloc] init];
            picker.sourceType = UIImagePickerControllerSourceTypePhotoLibrary;
            picker.delegate = [DevilCamera sharedInstance];
            self.callback = callback;
            [vc presentViewController:picker animated:YES completion:nil];
        } else {
            callback(@{
                @"r" : @FALSE,
                @"code" : @"403",
                @"msg" : @"카메라 권한이 없습니다. 설정에서 카메라 권한을 허용해주세요"
            });
        }
    }];
}


-(void)cameraSystem:(UIViewController*)vc param:(id)param callback:(void (^)(id res))callback{
    [DevilCamera requestCameraPermission:^(BOOL granted) {
        if(granted) {
            
            if([param[@"multi"] boolValue]) {
                self.param = param;
                DevilImagePickerController *picker = [[DevilImagePickerController alloc] init];
                float rate = 1.2f;
                if(param[@"rate"])
                    rate = [param[@"rate"] floatValue];
                BOOL showFrame = false;
                if(param[@"showFrame"])
                    showFrame = [param[@"showFrame"] boolValue];
                
                picker.showFrame = showFrame;
                picker.rate = rate;
                picker.callback = callback;
                self.picker = picker;
                [picker construct];
                
                [vc presentViewController:picker animated:YES completion:^{
                    [picker constructOverlay];
                }];
            } else {
                self.param = param;
                UIImagePickerController *picker = [[UIImagePickerController alloc] init];
                picker.sourceType = UIImagePickerControllerSourceTypeCamera;
                picker.delegate = [DevilCamera sharedInstance];
                self.callback = callback;
                [vc presentViewController:picker animated:YES completion:nil];
            }
            
        } else {
            callback(@{
                @"r" : @FALSE,
                @"code" : @"403",
                @"msg" : @"카메라 권한이 없습니다. 설정에서 카메라 권한을 허용해주세요"
            });
        }
    }];
}

- (NSString*)savePhotoToJpegFile:(UIImage*)photo {
     id aaa = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
     NSString *prefix = aaa[0];
     NSString* outputFileName = [NSUUID UUID].UUIDString;
     NSString* targetPath = [prefix stringByAppendingPathComponent:[outputFileName stringByAppendingPathExtension:@"jpg"]];
     NSData *imageData = UIImageJPEGRepresentation(photo, 0.8f);
     [imageData writeToFile:targetPath atomically:YES];
    return targetPath;
}

- (void)imagePickerController:(UIImagePickerController *)picker didFinishPickingMediaWithInfo:(NSDictionary<UIImagePickerControllerInfoKey, id> *)info{
    
    UIImage* photo = info[UIImagePickerControllerOriginalImage];
    NSString* targetPath = [self savePhotoToJpegFile:photo];
    if([self.param[@"multi"] boolValue]) {
        ;
    } else {
        [picker dismissViewControllerAnimated:YES completion:^{
            if(self.callback) {
                self.callback([@{
                    @"r":@TRUE,
                    @"type":@"image",
                    @"image" :targetPath,
                } mutableCopy]);
                self.callback = nil;
            }
        }];
    }
}


- (void)imagePickerControllerDidCancel:(UIImagePickerController *)picker{
    [picker dismissViewControllerAnimated:YES completion:^{
        if(self.callback) {
            self.callback([@{
                @"r":@FALSE,
            } mutableCopy]);
            self.callback = nil;
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
                        callback(@{
                            @"r" : @FALSE,
                            @"code" : @"403",
                            @"msg" : @"카메라 권한이 없습니다. 설정에서 녹음 권한을 허용해주세요"
                        });
                }];
            } else {
                [DevilCamera goCamera:vc param:param callback:callback];
            }
        } else {
            callback(@{
                @"r" : @FALSE,
                @"code" : @"403",
                @"msg" : @"카메라 권한이 없습니다. 설정에서 카메라 권한을 허용해주세요"
            });
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
            callback(@{
                @"r" : @FALSE,
                @"code" : @"403",
                @"msg" : @"카메라 권한이 없습니다. 설정에서 카메라 권한을 허용해주세요"
            });
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


+(void)gallery:(UIViewController*)vc param:(id)param callback:(void (^)(id res))callback{
    
    [DevilCamera requestCameraPermission:^(BOOL granted) {
        if(granted) {
            [DevilCamera goGallery:vc param:param callback:callback];
        } else {
            callback(@{
                @"r" : @FALSE,
                @"code" : @"403",
                @"msg" : @"권한이 없습니다. 설정에서 갤러리 권한을 허용해주세요"
            });
        }
    }];
}

+ (void)goGallery:(UIViewController*)vc param:(id)param callback:(void (^)(id res))callback {
    dispatch_async(dispatch_get_main_queue(), ^{
        DevilGalleryController* dc = [[DevilGalleryController alloc] init];
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
            dispatch_async(dispatch_get_main_queue(), ^{
                callback(true);
            });
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

+ (void)requestGalleryPermission:(void (^)(BOOL granted))callback {
    
    [PHPhotoLibrary requestAuthorization:^(PHAuthorizationStatus status) {
        switch (status) {
            case PHAuthorizationStatusAuthorized: {
                dispatch_async(dispatch_get_main_queue(), ^{
                    callback(true);
                });
                break;
            }
            case PHAuthorizationStatusDenied:
            case PHAuthorizationStatusNotDetermined:
            case PHAuthorizationStatusRestricted: {
                dispatch_async(dispatch_get_main_queue(), ^{
                    callback(false);
                });
                break;
            }
        }
    }];
}
@end
