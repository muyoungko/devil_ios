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

#define UIColorFromRGBA(argbValue) \
[UIColor colorWithRed:((float)((argbValue & 0x00FF0000) >> 16))/255.0 \
green:((float)((argbValue & 0x0000FF00) >>  8))/255.0 \
blue:((float)((argbValue & 0x000000FF) >>  0))/255.0 \
alpha:((float)((argbValue & 0xFF000000) >>  24))/255.0]

#define urlencode( str ) [str stringByAddingPercentEncodingWithAllowedCharacters:[NSCharacterSet URLHostAllowedCharacterSet]]
#define urldecode( str ) [str stringByRemovingPercentEncoding]  

@interface DevilUtil : NSObject

+ (UIImage *)rotateImage:(UIImage *)image degrees:(CGFloat)degrees;
+ (void) convertMovToMp4:(NSString*)path to:(NSString*)outputPath callback:(void (^)(id res))callback;
+ (NSString*) changeFileExt:(NSString*)path to:(NSString*)ext;
+ (NSString*) getFileExt:(NSString*)path;
+ (NSString*) getFileName:(NSString*)path;
+ (NSInteger)sizeOfFile:(NSString *)filePath;
+ (UIImage *) getThumbnail:(NSString*)path;
+ (int) getDuration:(NSString*)path;
+(void)httpPut:(NSString*)url contentType:(id _Nullable)contentType data:(NSData*)data complete:(void (^)(id res))callback;
+(id) parseUrl:(NSString*)url;
+(id) queryToJson:(NSURL*)url;
+ (void)clearTmpDirectory;
+ (UIImage *)resizeImageProperly:(UIImage *)image;
+ (BOOL)isWifiConnection;

@end

NS_ASSUME_NONNULL_END
