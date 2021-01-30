//
//  JevilUtil.h
//  devilcore
//
//  Created by Mu Young Ko on 2021/01/30.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@interface JevilUtil : NSObject

+(void)sync:(NSMutableDictionary*)src :(NSMutableDictionary*)dest;
+(void)syncList:(NSMutableArray*)src :(NSMutableArray*)dest;
+(NSString*)find:(NSMutableDictionary*)data :(NSMutableDictionary*)thisData;
+(BOOL)findCore:(id)data :(id)thisData :(id)outList;

@end

NS_ASSUME_NONNULL_END
