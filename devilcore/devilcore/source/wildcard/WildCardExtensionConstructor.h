//
//  WildCardExtensionConstructor.h
//  CloudJsonViewer
//
//  Created by Mu Young Ko on 2018. 10. 15..
//  Copyright © 2018년 Mu Young Ko. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

#define WILDCARD_EXTENSION_TYPE_UNDIFINED -1
#define WILDCARD_EXTENSION_TYPE_CUSTOM 3
#define WILDCARD_EXTENSION_TYPE_INPUT 4
#define WILDCARD_EXTENSION_TYPE_BILL_BOARD_PAGER 0
#define WILDCARD_EXTENSION_TYPE_STAR_RATING 1
#define WILDCARD_EXTENSION_TYPE_CHEKBOX 5
#define WILDCARD_EXTENSION_TYPE_PROGRESS_BAR 6

@class WildCardMeta;
@class ReplaceRuleExtension;

@interface WildCardExtensionConstructor : NSObject

+(UIView*)construct:(UIView*)extensionContainer : (NSDictionary*)layer  :(WildCardMeta*) meta;

+(void)update:(WildCardMeta*) meta extensionRule:(ReplaceRuleExtension*)rule data:(NSMutableDictionary*)opt;

+(int)getExtensionType:(NSDictionary*)extension;

@end

NS_ASSUME_NONNULL_END
