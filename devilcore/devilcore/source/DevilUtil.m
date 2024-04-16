//
//  DevilUtil.m
//  devilcore
//
//  Created by Mu Young Ko on 2021/04/11.
//

#import "DevilUtil.h"
#import <CoreServices/UTType.h>
#import <CommonCrypto/CommonDigest.h>
#import "JevilInstance.h"

@import AVKit;
@import AVFoundation;
@import SystemConfiguration;
@import CoreTelephony;
@import Foundation;
#import "DevilAlertDialog.h"
#import "DevilController.h"
#import "DevilSdk.h"
#import "DevilLang.h"

@interface DevilUtil()
@property (nonatomic, retain) NSMutableArray* httpPutWaitQueue;
@property (nonatomic, retain) NSMutableArray* httpPutIngQueue;

@end

@implementation DevilUtil

+(DevilUtil*)sharedInstance {
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
    //return urldecode(name);
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
        
        dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_HIGH, 0), ^{
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
        return [DevilUtil resizeImage:image width:512];
    } else
        return image;
}

+ (UIImage *)resizeImage:(UIImage *)image width:(float)width {
    float x = image.size.width / image.size.height * width;
    CGSize newSize = CGSizeMake(x, width);
    UIGraphicsBeginImageContextWithOptions(newSize, NO, 0.0);
    [image drawInRect:CGRectMake(0, 0, newSize.width, newSize.height)];
    UIImage *newImage = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    return newImage;
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

            [alertController addAction:[UIAlertAction actionWithTitle:yesText
                                                              style:UIAlertActionStyleCancel
                                                            handler:^(UIAlertAction *action) {
                callback(true);
                                                                
            }]];
            [vc presentViewController:alertController animated:YES completion:^{}];

            [vc setActiveAlert:alertController];
            
    }
}

+(NSString*)orientationToString:(UIInterfaceOrientationMask)mask{
    if(mask & UIInterfaceOrientationMaskPortrait && mask & UIInterfaceOrientationMaskLandscape) {
        return @"all";
    } else if(mask & UIInterfaceOrientationMaskPortrait) {
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

+(NSString*)sha256:(NSString*)text {
    const char* utf8chars = [text UTF8String];
    unsigned char result[CC_SHA256_DIGEST_LENGTH];
    CC_SHA256(utf8chars, (CC_LONG)strlen(utf8chars), result);

    NSMutableString *ret = [NSMutableString stringWithCapacity:CC_SHA256_DIGEST_LENGTH*2];
    for(int i = 0; i<CC_SHA256_DIGEST_LENGTH; i++) {
        [ret appendFormat:@"%02x",result[i]];
    }
    return ret;
}

+(NSString*)sha256ToHex:(NSString*)text {
    const char* utf8chars = [text UTF8String];
    unsigned char result[CC_SHA256_DIGEST_LENGTH];
    CC_SHA256(utf8chars, (CC_LONG)strlen(utf8chars), result);

    NSMutableString *ret = [NSMutableString stringWithCapacity:CC_SHA256_DIGEST_LENGTH*2];
    for(int i = 0; i<CC_SHA256_DIGEST_LENGTH; i++) {
        [ret appendFormat:@"%02x",result[i]];
    }
    return ret;
}

+(NSString*)sha256ToHash:(NSString*)text {
    const char* utf8chars = [text UTF8String];
    unsigned char result[CC_SHA256_DIGEST_LENGTH];
    CC_SHA256(utf8chars, (CC_LONG)strlen(utf8chars), result);

    NSMutableString *ret = [NSMutableString stringWithCapacity:CC_SHA256_DIGEST_LENGTH*2];
    for(int i = 0; i<CC_SHA256_DIGEST_LENGTH; i++) {
        [ret appendFormat:@"%02x",result[i]];
    }
    return ret;
}

+(NSString*)sha512ToHash:(NSString*)text {
    const char* utf8chars = [text UTF8String];
    unsigned char result[CC_SHA512_DIGEST_LENGTH];
    CC_SHA512(utf8chars, (CC_LONG)strlen(utf8chars), result);

    NSMutableString *ret = [NSMutableString stringWithCapacity:CC_SHA512_DIGEST_LENGTH*2];
    for(int i = 0; i<CC_SHA512_DIGEST_LENGTH; i++) {
        [ret appendFormat:@"%02x",result[i]];
    }
    return ret;
}

+(NSString*)fileNameToContentType:(NSString*)path {
    NSString* contentType = nil;
    if([path hasSuffix:@"jpg"] || [path hasSuffix:@"jpeg"])
        contentType = @"image/jpeg";
    else if([path hasSuffix:@"png"])
        contentType = @"image/png";
    else if([path hasSuffix:@"mp4"])
        contentType = @"video/mp4";
    else if([path hasSuffix:@"pdf"])
        contentType = @"application/pdf";
    else
        contentType = @"application/octet-stream";
    return contentType;
}

+(BOOL)shouldLandscape {
    UIInterfaceOrientationMask c = [DevilSdk sharedInstance].currentOrientation;
    if((c & UIInterfaceOrientationMaskLandscape) && (c & UIInterfaceOrientationMaskPortrait)) {
        //현재 Device Orienation에 따라 결정
        //그런데 현재 화면이 potrait이고 다음화면이 landscape이면 현재화면이 나온다.
        //결국 현재 화면 상태는 의미없고 현재 기기의 가로/세로 상태를 구해야한다
        UIInterfaceOrientation orientation = [[UIApplication sharedApplication].windows firstObject].windowScene.interfaceOrientation;
        UIDeviceOrientation device_orientation = [[UIDevice currentDevice] orientation];
        return (device_orientation == UIInterfaceOrientationLandscapeLeft || device_orientation == UIInterfaceOrientationLandscapeRight);

    } else {
        return [DevilSdk sharedInstance].currentOrientation == UIInterfaceOrientationMaskLandscape;
    }
}

+(BOOL)isLandscape:(UIInterfaceOrientationMask)orientation {
    
    return orientation == UIInterfaceOrientationMaskLandscape || orientation == UIInterfaceOrientationMaskLandscapeLeft || orientation == UIInterfaceOrientationMaskLandscapeRight;
}

+(NSString*)generateDocumentFilePath:(NSString*)ext {
    NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    NSString *documentsDirectory = paths[0];
    
    NSString* outputFileName = [NSString stringWithFormat:@"%ld.%@", (long)([NSDate now].timeIntervalSince1970 * 1000), ext];
    return [documentsDirectory stringByAppendingPathComponent:outputFileName];
}

+(NSString*)generateTempFilePath:(NSString*)ext {
    NSString* outputFileName = [NSString stringWithFormat:@"%ld.%@", (long)([NSDate now].timeIntervalSince1970 * 1000), ext];
    return [NSTemporaryDirectory() stringByAppendingPathComponent:outputFileName];
}

+(NSString*)generateDocumentFilePathWithName:(NSString*)name{
    NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    NSString *documentsDirectory = paths[0];
    return [documentsDirectory stringByAppendingPathComponent:name];
}

+(NSString*)generateTempFilePathWithName:(NSString*)name{
    return [NSTemporaryDirectory() stringByAppendingPathComponent:name];
}
@end
