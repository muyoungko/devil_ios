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

#define urlencode( str ) [str stringByAddingPercentEncodingWithAllowedCharacters:[NSCharacterSet URLFragmentAllowedCharacterSet]]
#define urldecode( str ) [str stringByRemovingPercentEncoding]  

@interface JulyUtil : NSObject

+(NSString*)comma:(int)m;
+(NSString*)dateFormatSlash:(NSString*)yyyyMMdd;
+(NSString*)dateFormatMMddSlash:(NSString*)yyyyMMdd;
+(id)getFromList:(id)list col:(NSString*)col key:(NSString*)key;
+(int)getIndexFromList:(id)list col:(NSString*)col key:(NSString*)key;
+(void)request:(NSString*)url postParam:(id _Nullable)params complete:(void (^)(id res))callback;
+(void)share:(UIViewController*)vc text:(NSString*)textToShare;

@end

NS_ASSUME_NONNULL_END
