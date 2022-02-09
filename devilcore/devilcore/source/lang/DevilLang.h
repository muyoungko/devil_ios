//
//  DevilLang.h
//  devilcore
//
//  Created by Mu Young Ko on 2022/02/09.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

#define trans( str ) [DevilLang trans:str]

@interface DevilLang : NSObject

+(void)setCurrentLang:(NSString*)lang;
+(NSString*)getCurrentLang;
+(void)load;
+(NSString*)trans:(NSString*)name;

@end

NS_ASSUME_NONNULL_END
