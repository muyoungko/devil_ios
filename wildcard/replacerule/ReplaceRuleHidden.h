//
//  ReplaceRuleHidden.h
//  CloudJsonViewer
//
//  Created by Mu Young Ko on 2018. 10. 4..
//  Copyright © 2018년 Mu Young Ko. All rights reserved.
//

#import "ReplaceRule.h"

#define ReplaceRuleHidden(replaceView, replaceJsonLayer, replaceJsonKey) [[ReplaceRuleHidden alloc] initWith:replaceView:replaceJsonLayer:replaceJsonKey]

@interface ReplaceRuleHidden : ReplaceRule


-(id)initWith:(UIView*)replaceView
             :(NSDictionary*)replaceJsonLayer
             :(NSString*)replaceJsonKey;

@end
