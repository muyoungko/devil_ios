//
//  ReplaceRuleStrip.h
//  devilcore
//
//  Created by Mu Young Ko on 2021/01/23.
//
#import <UIKit/UIKit.h>
#import "ReplaceRule.h"

NS_ASSUME_NONNULL_BEGIN

#define ReplaceStrip(replaceView, replaceJsonLayer, replaceJsonKey) [[ReplaceRuleStrip alloc] initWith:replaceView:replaceJsonLayer:replaceJsonKey]

@interface ReplaceRuleStrip : ReplaceRule

-(id)initWith:(UIView*)replaceView
             :(NSDictionary*)replaceJsonLayer
             :(NSString*)replaceJsonKey;

@end

NS_ASSUME_NONNULL_END
