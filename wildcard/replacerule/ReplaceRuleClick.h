//
//  ReplaceRuleClick.h
//  CloudJsonViewer
//
//  Created by Mu Young Ko on 2018. 6. 18..
//  Copyright © 2018년 Mu Young Ko. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "ReplaceRule.h"

#define ReplaceRuleClick(replaceView, replaceJsonLayer, replaceJsonKey) [[ReplaceRuleClick alloc] initWith:replaceView:replaceJsonLayer:replaceJsonKey]

@interface ReplaceRuleClick : ReplaceRule


-(id)initWith:(UIView*)replaceView
             :(NSDictionary*)replaceJsonLayer
             :(NSString*)replaceJsonKey;

@end
