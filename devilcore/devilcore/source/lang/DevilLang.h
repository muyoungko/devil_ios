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

@property BOOL multiLanguage;
@property BOOL collectLanguage;
@property (nonatomic, retain) NSMutableDictionary* sent;
@property (nonatomic, retain) NSMutableDictionary* sentWait;

+(DevilLang*)sharedInstance;
+(void)setCurrentLang:(NSString*)lang;
+(NSString*)getCurrentLang;
+(void)load;
+(void)parseLanguage:(id)language;
+(NSString*)trans:(NSString*)name;
-(void)flush;

@end

NS_ASSUME_NONNULL_END
