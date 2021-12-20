//
//  WildCardTimer.h
//  devilcore
//
//  Created by Mu Young Ko on 2021/01/12.
//

#import <Foundation/Foundation.h>
#import "WildCardMeta.h"
#import "WildCardUILabel.h"
#import "WildCardUIView.h"

NS_ASSUME_NONNULL_BEGIN

@interface WildCardTimer : NSObject

-(id)initWith:(WildCardMeta*)meta :(WildCardUILabel*)tv :(id)layer :(NSString*)name :(WildCardUIView*)vv;
-(void)reset;
-(void)startTimeFrom:(NSString*)mm_ss;
-(void)startTimeFromSec:(int)sec;

@end

NS_ASSUME_NONNULL_END
