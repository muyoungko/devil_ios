//
//  WildCardUtil.h
//  CloudJsonViewer
//
//  Created by Mu Young Ko on 2018. 6. 18..
//  Copyright © 2018년 Mu Young Ko. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>

@interface WildCardUtil : NSObject

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

@end
