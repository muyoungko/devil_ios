//
//  WildCardAction.h
//  library
//
//  Created by Mu Young Ko on 2018. 10. 31..
//  Copyright © 2018년 sbs cnbc. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "WildCardTrigger.h"
#import "WildCardMeta.h"

NS_ASSUME_NONNULL_BEGIN

@interface WildCardAction : NSObject

@property (nonatomic, retain) WildCardMeta* meta;

+(void)execute:(WildCardTrigger*)trigger script:(NSString*)script meta:(WildCardMeta*)meta;

+(void)parseAndConducts:(WildCardTrigger*)trigger action:(NSString*)actionString meta:(WildCardMeta*)meta;

+(void)conduct:(WildCardTrigger*)trigger action:(NSString*)actionString meta:(WildCardMeta*)meta;

+(WildCardAction*)parse:(WildCardMeta*)meta  action:(NSString*) actionString;

- (instancetype)initWithMeta:(WildCardMeta*)meta;

-(void)act:(WildCardTrigger*)trigger;
@end

NS_ASSUME_NONNULL_END
