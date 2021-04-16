//
//  DevilUtil.m
//  devilcore
//
//  Created by Mu Young Ko on 2021/04/11.
//

#import "DevilUtil.h"
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

+ (void) convertMovToMp4:(NSString*)path to:(NSString*)outputPath callback:(void (^)(id res))callback {
    NSString* oldExt = [DevilUtil getFileExt:path];
    if([oldExt isEqualToString:@"mov"]){
        NSURL* videoURL = [NSURL URLWithString:path];
        AVURLAsset *avAsset = [AVURLAsset URLAssetWithURL:videoURL options:nil];
        NSArray *compatiblePresets = [AVAssetExportSession exportPresetsCompatibleWithAsset:avAsset];
        AVAssetExportSession *exportSession = [[AVAssetExportSession alloc] initWithAsset:avAsset presetName:AVAssetExportPresetLowQuality];

        exportSession.outputURL = [NSURL URLWithString:outputPath];
        exportSession.outputFileType = AVFileTypeMPEG4;
        exportSession.shouldOptimizeForNetworkUse = YES;

        [exportSession exportAsynchronouslyWithCompletionHandler:^{
        switch ([exportSession status])
        {
            case AVAssetExportSessionStatusFailed:
               NSLog(@"Export session failed");
                callback(@{@"r":@FALSE});
               break;
            case AVAssetExportSessionStatusCancelled:
               NSLog(@"Export canceled");
                callback(@{@"r":@FALSE});
               break;
            case AVAssetExportSessionStatusCompleted:
            {
               //Video conversion finished
               NSLog(@"Successful!");
                callback(@{@"r":@TRUE});
            }
               break;
            default:
               break;
        }
        }];
    } else {
        callback(@{@"r":@FALSE});
    }
}

@end
