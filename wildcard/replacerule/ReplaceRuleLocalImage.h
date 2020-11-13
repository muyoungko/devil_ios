//
//  ReplaceRuleLocalImage.h
//  CloudJsonViewer
//
//  Created by Mu Young Ko on 2018. 6. 18..
//  Copyright © 2018년 Mu Young Ko. All rights reserved.
//

#import "ReplaceRule.h"

#define ReplaceRuleLocalImage(replaceView, replaceJsonLayer, replaceJsonKey) [[ReplaceRuleLocalImage alloc] initWith:replaceView:replaceJsonLayer:replaceJsonKey]

@interface ReplaceRuleLocalImage : ReplaceRule

-(id)initWith:(UIView*)replaceView
             :(NSDictionary*)replaceJsonLayer
             :(NSString*)replaceJsonKey;

@end
