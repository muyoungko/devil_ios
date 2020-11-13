//
//  Lang.h
//  gribjt
//
//  Created by Mu Young Ko on 2019. 8. 21..
//  Copyright © 2019년 Grib. All rights reserved.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN


#define trans( str ) [Lang trans:str]

@interface Lang : NSObject

+(void)setCurrentLang:(NSString*)lang;
+(NSString*)getCurrentLang;
+(void)load;
+(NSString*)trans:(NSString*)name;

@end

NS_ASSUME_NONNULL_END
