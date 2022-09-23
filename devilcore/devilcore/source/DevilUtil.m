//
//  DevilUtil.m
//  devilcore
//
//  Created by Mu Young Ko on 2021/04/11.
//

#import "DevilUtil.h"
#import <CoreServices/UTType.h>

@import AVKit;
@import AVFoundation;
@import SystemConfiguration;
@import CoreTelephony;
@import Foundation;
#import "DevilAlertDialog.h"
#import "DevilController.h"

@interface DevilUtil()
@property (nonatomic, retain) NSMutableArray* httpPutWaitQueue;
@property (nonatomic, retain) NSMutableArray* httpPutIngQueue;
@end

@implementation DevilUtil

+(DevilUtil*)sharedInstance{
    static DevilUtil *sharedInstance = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        sharedInstance = [[DevilUtil alloc] init];
        sharedInstance.httpPutWaitQueue = [@[] mutableCopy];
        sharedInstance.httpPutIngQueue = [@[] mutableCopy];
    });
    return sharedInstance;
}

+ (UIImage *)rotateImage:(UIImage *)image degrees:(CGFloat)degrees
{
    CGFloat radians = degrees * (M_PI / 180.0);

    UIView *rotatedViewBox = [[UIView alloc] initWithFrame:CGRectMake(0,0, image.size.height, image.size.width)];
    CGAffineTransform t = CGAffineTransformMakeRotation(radians);
    rotatedViewBox.transform = t;
    CGSize rotatedSize = rotatedViewBox.frame.size;

    UIGraphicsBeginImageContextWithOptions(rotatedSize, NO, [[UIScreen mainScreen] scale]);
    CGContextRef bitmap = UIGraphicsGetCurrentContext();

    CGContextTranslateCTM(bitmap, rotatedSize.height / 2, rotatedSize.width / 2);

    CGContextRotateCTM(bitmap, radians);

    CGContextScaleCTM(bitmap, 1.0, -1.0);
    CGContextDrawImage(bitmap, CGRectMake(-image.size.width / 2, -image.size.height / 2 , image.size.height, image.size.width), image.CGImage );
    UIImage *newImage = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();

    return newImage;
}

+ (NSString*) getFileExt:(NSString*)path {
    id ss = [path componentsSeparatedByString:@"."];
    NSString* ext = ss[[ss count]-1];
    int a = (int)[ext rangeOfString:@"?"].location;
    if(a >= 0) {
        ext = [ext substringToIndex:a];
    }
    return ext;
}

+ (NSString*) getFileName:(NSString*)path {
    id ss = [path componentsSeparatedByString:@"."];
    NSString* head = ss[[ss count]-2];
    id hh = [head componentsSeparatedByString:@"/"];
    NSString* name = hh[[hh count]-1];
    return name;
}

+ (NSString*) changeFileExt:(NSString*)path to:(NSString*)ext {
    id oldExt = [DevilUtil getFileExt:path];
    NSString* npath = [NSString stringWithFormat:@"%@%@",
                       [path substringToIndex:([path length] - [oldExt length])], ext ];
    return npath;
}

+ (UIImage *) getThumbnail:(NSString*)path {
    AVAsset *asset = [AVAsset assetWithURL:[NSURL fileURLWithPath:path]];
    AVAssetImageGenerator *imageGenerator = [[AVAssetImageGenerator alloc]initWithAsset:asset];
    imageGenerator.appliesPreferredTrackTransform = YES;
    CMTime time = CMTimeMake(0, 600);
    CGImageRef imageRef = [imageGenerator copyCGImageAtTime:time actualTime:NULL error:NULL];
    UIImage *thumbnail = [UIImage imageWithCGImage:imageRef];
    CGImageRelease(imageRef);
    return thumbnail;
}

+ (int) getDuration:(NSString*)path {
    AVAsset *asset = [AVAsset assetWithURL:[NSURL fileURLWithPath:path]];
    return CMTimeGetSeconds(asset.duration);
}


+ (void) convertMovToMp4:(NSString*)path to:(NSString*)outputPath callback:(void (^)(id res))callback {
    NSString* oldExt = [DevilUtil getFileExt:path];
    if([oldExt isEqualToString:@"mov"] || [oldExt isEqualToString:@"MOV"] ||
       [oldExt isEqualToString:@"mp4"] || [oldExt isEqualToString:@"MP4"] ){
        /**
         po [[NSFileManager defaultManager] fileExistsAtPath:path]
         
         */
        NSURL* videoURL = [NSURL fileURLWithPath:path];
        AVURLAsset *avAsset = [AVURLAsset URLAssetWithURL:videoURL options:nil];
        NSArray *compatiblePresets = [AVAssetExportSession exportPresetsCompatibleWithAsset:avAsset];
        if ([compatiblePresets containsObject:AVAssetExportPreset640x480])
        {
            AVAssetExportSession *exportSession = [[AVAssetExportSession alloc] initWithAsset:avAsset presetName:
                                                   AVAssetExportPresetPassthrough];
            
            if([[NSFileManager defaultManager] fileExistsAtPath:outputPath])
                [[NSFileManager defaultManager]removeItemAtPath:outputPath error:nil];
            
            exportSession.outputURL = [NSURL fileURLWithPath:outputPath];
            exportSession.outputFileType = AVFileTypeMPEG4;
            exportSession.shouldOptimizeForNetworkUse = YES;
            
            [exportSession exportAsynchronouslyWithCompletionHandler:^{
                switch ([exportSession status])
                {
                    case AVAssetExportSessionStatusFailed:{
                        NSLog(@"Export session failed");
                        dispatch_async(dispatch_get_main_queue(), ^{callback(@{@"r":@FALSE});});
                    }
                        break;
                    case AVAssetExportSessionStatusCancelled:{
                        NSLog(@"Export canceled");
                        dispatch_async(dispatch_get_main_queue(), ^{callback(@{@"r":@FALSE});});
                    }
                        break;
                    case AVAssetExportSessionStatusCompleted:
                    {
                        //Video conversion finished
                        NSLog(@"Successful!");
                        dispatch_async(dispatch_get_main_queue(), ^{callback(@{@"r":@TRUE});});
                    }
                       break;
                    default:
                       break;
                }
            }];
        }
        
    } else {
        dispatch_async(dispatch_get_main_queue(), ^{callback(@{@"r":@FALSE});});
    }
}

+(NSInteger)sizeOfFile:(NSString *)filePath {
    NSDictionary *fileAttributes = [[NSFileManager defaultManager] attributesOfItemAtPath:filePath error:nil];
    NSInteger fileSize = [[fileAttributes objectForKey:NSFileSize] integerValue];

    return fileSize;

}

+(void)httpPutQueueClear {
    [[DevilUtil sharedInstance].httpPutWaitQueue removeAllObjects];
    [[DevilUtil sharedInstance].httpPutIngQueue removeAllObjects];
}

+(void)httpPutQueueResume {
    
    if([[DevilUtil sharedInstance].httpPutWaitQueue count] > 0) {
        __block id a = [[DevilUtil sharedInstance].httpPutWaitQueue firstObject];
        
        NSLog(@"httpPutQueueResume %lu %lu",
              [[DevilUtil sharedInstance].httpPutWaitQueue count],
              [[DevilUtil sharedInstance].httpPutIngQueue count]);
        
        [[DevilUtil sharedInstance].httpPutWaitQueue removeObjectAtIndex:0];
        [[DevilUtil sharedInstance].httpPutIngQueue addObject:a];
        
        NSString* url = a[@"url"];
        id contentType = a[@"contentType"];
        NSData* data = a[@"data"];
        void (^callback)(id res) = a[@"callback"];
        
        NSMutableURLRequest *request = [[NSMutableURLRequest alloc] init];
        [request setURL:[NSURL URLWithString:url]];
        [request setHTTPMethod:@"PUT"];
        if(contentType)
            [request setValue:contentType forHTTPHeaderField:@"Content-Type"];
        [request setHTTPBody:data];
        
        if([data length] == 0)
            @throw [NSException exceptionWithName:@"Devil" reason:[NSString stringWithFormat:@"Failed. Upload Data is 0 byte."] userInfo:nil];
        
        dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
            NSError *err;
            NSURLResponse *response;
            NSData *responseData = [NSURLConnection sendSynchronousRequest:request returningResponse:&response error:&err];
            NSString *res = [[NSString alloc]initWithData:responseData encoding:NSASCIIStringEncoding];
            [self httpPutQueueResume];
            dispatch_async(dispatch_get_main_queue(), ^{
                [[DevilUtil sharedInstance].httpPutIngQueue removeObject:a];
                if(err)
                    callback(nil);
                else
                    callback(@{@"r":@TRUE});
            });
            
        });
    }
}

+(void)httpPut:(NSString*)url contentType:(id _Nullable)contentType data:(NSData*)data complete:(void (^)(id res))callback {
    
    __block NSString* udid = [NSUUID UUID].UUIDString;
    
    [[DevilUtil sharedInstance].httpPutWaitQueue addObject:[@{
        @"udid":udid,
        @"url":url,
        @"contentType":contentType,
        @"data":data,
        @"callback":callback
    } mutableCopy]];
    
    if([[DevilUtil sharedInstance].httpPutIngQueue count] < 8) {
        [DevilUtil httpPutQueueResume];
    }
}

+(id) parseUrl:(NSString*)url {
    NSURLComponents *components = [NSURLComponents componentsWithURL:[NSURL URLWithString:url] resolvingAgainstBaseURL:NO];
    NSArray *queryItems = [components queryItems];

    NSMutableDictionary *dict = [NSMutableDictionary new];

    for (NSURLQueryItem *item in queryItems){
        [dict setObject:[item value] forKey:[item name]];
    }
    
    dict[@"path"] = [components path];
    dict[@"host"] = [components host];
    dict[@"scheme"] = [components scheme];
    
    return dict;
}

+(id) queryToJson:(NSURL*)url {
    NSURLComponents *components = [NSURLComponents componentsWithURL:url resolvingAgainstBaseURL:NO];
    NSArray *queryItems = [components queryItems];

    NSMutableDictionary *dict = [NSMutableDictionary new];

    for (NSURLQueryItem *item in queryItems){
        if([item value] == nil)
            continue;
        [dict setObject:[item value] forKey:[item name]];
    }
    
    return dict;
}

+ (void)clearTmpDirectory
{
    NSArray* tmpDirectory = [[NSFileManager defaultManager] contentsOfDirectoryAtPath:NSTemporaryDirectory() error:NULL];
    for (NSString *file in tmpDirectory) {
        [[NSFileManager defaultManager] removeItemAtPath:[NSString stringWithFormat:@"%@%@", NSTemporaryDirectory(), file] error:NULL];
    }
}


+ (UIImage *)resizeImageProperly:(UIImage *)image {
    if(image.size.width > 512) {
        float x = image.size.width / image.size.height * 512.0f;
        CGSize newSize = CGSizeMake(x, 512);
        UIGraphicsBeginImageContextWithOptions(newSize, NO, 0.0);
        [image drawInRect:CGRectMake(0, 0, newSize.width, newSize.height)];
        UIImage *newImage = UIGraphicsGetImageFromCurrentImageContext();
        UIGraphicsEndImageContext();
        return newImage;
    } else
        return image;
}

+ (BOOL)isWifiConnection {
    SCNetworkReachabilityFlags  flags = 0;
    SCNetworkReachabilityRef netReachability;
    netReachability = SCNetworkReachabilityCreateWithName(CFAllocatorGetDefault(), [@"www.google.com" UTF8String]);
    if(netReachability)
    {
        SCNetworkReachabilityGetFlags(netReachability, &flags);
        CFRelease(netReachability);
    }
    if(flags & kSCNetworkReachabilityFlagsIsWWAN)
        return NO;
    else
        return YES;
}

+ (BOOL)isPhoneX {
    BOOL iPhoneX = NO;
    if (@available(iOS 11.0, *)) {
        UIWindow *mainWindow = [[[UIApplication sharedApplication] delegate] window];
        if (mainWindow.safeAreaInsets.top > 24.0) {
            iPhoneX = YES;
        }
    }
    
    return iPhoneX;
}

+(void)saveFileFromUrl:(NSString*)url to:(NSString*)filename callback:(void (^)(id res))callback {
    
    NSURLSessionConfiguration* configuration = [NSURLSessionConfiguration defaultSessionConfiguration];
    NSURLSession* session = [NSURLSession sessionWithConfiguration:configuration];

    NSURL *URL = [NSURL URLWithString:url];
    NSURLSessionDataTask* task = [session dataTaskWithURL:URL completionHandler:^(NSData * _Nullable data, NSURLResponse * _Nullable response, NSError * _Nullable error) {
        if(error) {
            dispatch_async(dispatch_get_main_queue(), ^{
                callback(@{@"r":@FALSE, @"msg":[error description]});
            });
        } else {
            NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
            NSString *documentsDirectory = paths[0];
            NSString* path = [documentsDirectory stringByAppendingPathComponent:filename];
            BOOL success = [data writeToFile:path atomically:YES];
            dispatch_async(dispatch_get_main_queue(), ^{
                callback(@{@"r":@TRUE, @"dest":path});
            });
        }
    }];
    [task resume];
}

+(NSString*)replaceUdidPrefixDir:(NSString*)url {
    //ios document path 가 매번 달라진다
    //예) /private/var/mobile/Containers/Data/Application/0B572ED5-40EC-4EDD-A98C-B2A7E3DCE077/tmp/EA9D3098-4566-4A69-859D-D00638981094.jpg
    if([url containsString:@"/Data/Application"]) {
        id aa = [url componentsSeparatedByString:@"/"];
        bool checkData = false;
        bool checkApplication = false;
        bool checkUdid = false;
        NSString* surfix = @"";
        for(NSString* a in aa) {
            if([a isEqualToString:@"Data"])
                checkData = true;
            else if([a isEqualToString:@"Application"])
                checkApplication = true;
            else if(checkApplication && checkData && !checkUdid)
                checkUdid = true;
            else if(checkApplication && checkData && checkUdid) {
                if([surfix length] > 0)
                    surfix = [surfix stringByAppendingString:@"/"];
                surfix = [surfix stringByAppendingString:a];
            }
        }
        
        
        id aaa = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
        NSString *prefix = aaa[0];
        prefix = [prefix stringByReplacingOccurrencesOfString:@"/Documents" withString:@""];
        NSString *path = [NSString stringWithFormat:@"%@/%@", prefix, surfix];
        
        return path;
    } else {
        return url;
    }
}

+(void)showAlert:(DevilController*)vc msg:(NSString*)msg showYes:(BOOL)showYes yesText:(NSString*)yesText cancelable:(BOOL)cancelable callback:(void (^)(BOOL res))callback
{
    if(![DevilAlertDialog showAlertTemplateParam:@{@"msg":msg,
                                                   @"yes_text":yesText,
                                                 } :^(BOOL yes) {
        callback(true);
        }])
    {
            UIAlertController *alertController = [UIAlertController alertControllerWithTitle:msg
                                                                                     message:nil
                                                                              preferredStyle:UIAlertControllerStyleAlert];

            [alertController addAction:[UIAlertAction actionWithTitle:@"확인"
                                                              style:UIAlertActionStyleCancel
                                                            handler:^(UIAlertAction *action) {
                callback(true);
                                                                
            }]];
            [vc presentViewController:alertController animated:YES completion:^{}];

            [vc setActiveAlert:alertController];
            
    }
}

+(NSString*)orientationToString:(UIInterfaceOrientationMask)mask{
    NSString* r = @"";
    if(mask & UIInterfaceOrientationMaskPortrait) {
        return @"portrait";
    } else if(mask & UIInterfaceOrientationMaskLandscapeLeft) {
        return @"landscape";
    }
    return @"?";
}

+(NSString *) byteToHex : (NSData*)data
{
    NSUInteger bytesCount = data.length;
    if (bytesCount) {
        const char *hexChars = "0123456789ABCDEF";
        const unsigned char *dataBuffer = data.bytes;
        char *chars = malloc(sizeof(char) * (bytesCount * 2 + 1));
        if (chars == NULL) {
            // malloc returns null if attempting to allocate more memory than the system can provide. Thanks Cœur
            [NSException raise:NSInternalInconsistencyException format:@"Failed to allocate more memory" arguments:nil];
            return nil;
        }
        char *s = chars;
        for (unsigned i = 0; i < bytesCount; ++i) {
            *s++ = hexChars[((*dataBuffer & 0xF0) >> 4)];
            *s++ = hexChars[(*dataBuffer & 0x0F)];
            dataBuffer++;
        }
        *s = '\0';
        NSString *hexString = [NSString stringWithUTF8String:chars];
        free(chars);
        
        return [hexString lowercaseString];
    }
    return @"";
}
@end
