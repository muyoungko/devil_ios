//
//  ReplaceRuleImageResource.h
//  sticar
//
//  Created by Mu Young Ko on 2019. 7. 5..
//  Copyright © 2019년 trix. All rights reserved.
//

#import "ReplaceRule.h"

NS_ASSUME_NONNULL_BEGIN

#define ReplaceRuleImageResource(replaceView, replaceJsonLayer, replaceJsonKey) [[ReplaceRuleImageResource alloc] initWith:replaceView:replaceJsonLayer:replaceJsonKey]

@interface ReplaceRuleImageResource : ReplaceRule

-(id)initWith:(UIView*)replaceView
             :(NSDictionary*)replaceJsonLayer
             :(NSString*)replaceJsonKey;

@end

NS_ASSUME_NONNULL_END
