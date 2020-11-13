//
//  HttpUtil.h
//  library
//
//  Created by Mu Young Ko on 2017. 1. 28..
//  Copyright © 2017년 sbs cnbc. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>

@interface HttpUtil : NSObject


+(void)get:(NSString*)url : (void (^)(id))callback;
+(void)getImage:(NSString*)url : (void (^)(id))callback;
+(void)post:(NSString*)url :(NSDictionary *)parameters : (void (^)(id))callback;

@end
