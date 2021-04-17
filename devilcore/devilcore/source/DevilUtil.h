//
//  DevilUtil.h
//  devilcore
//
//  Created by Mu Young Ko on 2021/04/11.
//

#import <Foundation/Foundation.h>
@import UIKit;

NS_ASSUME_NONNULL_BEGIN

#define UIColorFromRGB(rgbValue) \
[UIColor colorWithRed:((float)((rgbValue & 0xFF0000) >> 16))/255.0 \
green:((float)((rgbValue & 0x00FF00) >>  8))/255.0 \
blue:((float)((rgbValue & 0x0000FF) >>  0))/255.0 \
alpha:1.0]

@interface DevilUtil : NSObject

+ (UIImage *)rotateImage:(UIImage *)image degrees:(CGFloat)degrees;
+ (void) convertMovToMp4:(NSString*)path to:(NSString*)outputPath callback:(void (^)(id res))callback;
+ (NSString*) changeFileExt:(NSString*)path to:(NSString*)ext;
+ (NSString*) getFileExt:(NSString*)path;
+ (NSInteger)sizeOfFile:(NSString *)filePath;
+ (UIImage *) getThumbnail:(NSString*)path;
+ (int) getDuration:(NSString*)path;

@end

NS_ASSUME_NONNULL_END
