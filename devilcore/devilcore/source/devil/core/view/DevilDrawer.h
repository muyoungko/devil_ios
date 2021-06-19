//
//  DevilDrawer.h
//  devilcore
//
//  Created by Mu Young Ko on 2021/06/19.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@interface DevilDrawer : NSObject

+(id)sharedInstance;
+(void)menuReady:(NSString*)blockName :(id)param;
+(void)menuOpen:(NSString*)blockName;
+(void)menuClose;
-(void)test;


@end

NS_ASSUME_NONNULL_END
