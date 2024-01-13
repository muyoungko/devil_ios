//
//  DevilLang.h
//  devilcore
//
//  Created by Mu Young Ko on 2022/02/09.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

#define trans( str ) [DevilLang trans:str]
#define trans2( str, node ) [DevilLang trans:str:node]

@interface DevilLang : NSObject

@property BOOL multiLanguage;
@property BOOL collectLanguage;
@property (nonatomic, retain) NSMutableDictionary* sent;
@property (nonatomic, retain) NSMutableDictionary* sentWait;

+(DevilLang*)sharedInstance;
+(void)setCurrentLang:(NSString*)lang;
+(NSString*)getCurrentLang;
+(void)load;
+(void)parseLanguage:(id)language :(BOOL)collect_prod;
+(NSString*)trans:(NSString*)name;
+(NSString*)trans:(NSString*)name :(NSString*)node;
-(void)flush;
-(void)clear;

@end

NS_ASSUME_NONNULL_END
