//
//  ReplaceRuleColor.h
//  library
//
//  Created by Mu Young Ko on 2018. 11. 5..
//  Copyright © 2018년 sbs cnbc. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "ReplaceRule.h"

NS_ASSUME_NONNULL_BEGIN

#define ReplaceRuleColor(replaceView, replaceJsonLayer, replaceJsonKey) [[ReplaceRuleColor alloc] initWith:replaceView:replaceJsonLayer:replaceJsonKey]

@interface ReplaceRuleColor : ReplaceRule

-(id)initWith:(UIView*)replaceView
             :(NSDictionary*)replaceJsonLayer
             :(NSString*)replaceJsonKey;

@end

NS_ASSUME_NONNULL_END
