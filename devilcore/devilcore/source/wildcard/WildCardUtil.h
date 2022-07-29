//
//  WildCardUtil.h
//  CloudJsonViewer
//
//  Created by Mu Young Ko on 2018. 6. 18..
//  Copyright © 2018년 Mu Young Ko. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>

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


@interface WildCardUtil : NSObject

+(void)setSketchWidth:(float)w;
+(float)headerHeightInPixcelIfHeader:(UIViewController*)vc;
+(float)headerHeightInPixcel;
+(float)headerHeightInSketch;
+(UIColor*) colorWithHexString: (NSString *) hexString;
+(UIColor*) colorWithHexStringWithoutAlpha: (NSString *) hexString;
+(float) alphaWithHexString: (NSString *) hexString;
+(BOOL)hasGravityBottom:(int)gravity;
+(BOOL)hasGravityCenterVertical:(int)gravity;
+(BOOL)hasGravityRight:(int)gravity;
+(BOOL)hasGravityCenterHorizontal:(int)gravity;
+(void)fitToScreen:(id)layer;
+(void)fitToScreen:(id)layer sketch_height_more:(int)sketch_height_more;
+(void)fitToScreenRecur:(id)layer offsety:(float)offsety theight:(float)height;
+(CGRect)getGlobalFrame:(UIView*)v;
+(float) convertPixcelToSketch:(float)p;
+(float) convertSketchToPixel:(float)p;
+(float) measureHeight:(NSMutableDictionary*)cloudJson data:(NSMutableDictionary*)data;
+(UIView*)findView:(id)layer name:(NSString*)name;

@end
