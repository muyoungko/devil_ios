//
//  ReplaceRuleReplaceUrl.h
//  CloudJsonViewer
//
//  Created by Mu Young Ko on 2018. 10. 15..
//  Copyright © 2018년 Mu Young Ko. All rights reserved.
//

#import "ReplaceRule.h"

#define ReplaceRuleReplaceUrl(replaceView, replaceJsonLayer, replaceJsonKey) [[ReplaceRuleReplaceUrl alloc] initWith:replaceView:replaceJsonLayer:replaceJsonKey]

NS_ASSUME_NONNULL_BEGIN

@interface ReplaceRuleReplaceUrl : ReplaceRule

-(id)initWith:(UIView*)replaceView
             :(NSDictionary*)replaceJsonLayer
             :(NSString*)replaceJsonKey;

@end

NS_ASSUME_NONNULL_END
