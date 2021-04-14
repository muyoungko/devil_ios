//
//  JulyUtil.h
//  sticar
//
//  Created by Mu Young Ko on 2019. 6. 28..
//  Copyright © 2019년 trix. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>

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

#define trim( str ) [str stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceCharacterSet] ]
#define empty( str ) ( str == nil || [str length] == 0)

#define encode( str ) [str stringByAddingPercentEncodingWithAllowedCharacters:[NSCharacterSet URLFragmentAllowedCharacterSet]]
#define urlencode( str ) [str stringByAddingPercentEncodingWithAllowedCharacters:[NSCharacterSet URLFragmentAllowedCharacterSet]]
#define urldecode( str ) [str stringByRemovingPercentEncoding]  

@interface JulyUtil : NSObject

+(NSString*)comma:(int)m;
+(NSString*)dateFormatSlash:(NSString*)yyyyMMdd;
+(NSString*)dateFormatMMddSlash:(NSString*)yyyyMMdd;
+(id)getFromList:(id)list col:(NSString*)col key:(NSString*)key;
+(int)getIndexFromList:(id)list col:(NSString*)col key:(NSString*)key;

+(void)request:(NSString*)url header:(id _Nullable)header postParam:(id _Nullable)params complete:(void (^)(id res))callback;
+(void)request:(NSString*)url header:(id _Nullable)header complete:(void (^)(id res))callback;
+(void)request:(NSString*)url postParam:(id _Nullable)params complete:(void (^)(id res))callback;
+(void)request:(NSString*)url complete:(void (^)(id res))callback;
+(void)requestPut:(NSString*)url header:(id _Nullable)header data:(NSData*)data complete:(void (^)(id res))callback;
+(void)share:(UIViewController*)vc text:(NSString*)textToShare;

@end

NS_ASSUME_NONNULL_END
