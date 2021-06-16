//
//  DevilUtil.m
//  devilcore
//
//  Created by Mu Young Ko on 2021/04/11.
//

#import "DevilUtil.h"

@import AVKit;
@import AVFoundation;

@implementation DevilUtil

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
    return ext;
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
    CMTime time = CMTimeMake(1, 1);
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
    if([oldExt isEqualToString:@"mov"] || [oldExt isEqualToString:@"MOV"]){
        /**
         po [[NSFileManager defaultManager] fileExistsAtPath:path]
         
         */
        NSURL* videoURL = [NSURL fileURLWithPath:path];
        AVURLAsset *avAsset = [AVURLAsset URLAssetWithURL:videoURL options:nil];
        NSArray *compatiblePresets = [AVAssetExportSession exportPresetsCompatibleWithAsset:avAsset];
        if ([compatiblePresets containsObject:AVAssetExportPreset640x480])
        {
            AVAssetExportSession *exportSession = [[AVAssetExportSession alloc] initWithAsset:avAsset presetName:AVAssetExportPresetPassthrough];
            
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


+(void)httpPut:(NSString*)url contentType:(id _Nullable)contentType data:(NSData*)data complete:(void (^)(id res))callback{
    

    
    NSMutableURLRequest *request = [[NSMutableURLRequest alloc] init];
    [request setURL:[NSURL URLWithString:url]];
    [request setHTTPMethod:@"PUT"];
    if(contentType)
        [request setValue:contentType forHTTPHeaderField:@"Content-Type"];
    [request setHTTPBody:data];
    
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
        NSError *err;
        NSURLResponse *response;
        NSData *responseData = [NSURLConnection sendSynchronousRequest:request returningResponse:&response error:&err];
        NSString *res = [[NSString alloc]initWithData:responseData encoding:NSASCIIStringEncoding];
        dispatch_async(dispatch_get_main_queue(), ^{
            if(err)
                callback(nil);
            else
                callback(@{@"r":@TRUE});
        });
        
    });
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
@end
