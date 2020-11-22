//
//  ReplaceRuleExtention.h
//  CloudJsonViewer
//
//  Created by Mu Young Ko on 2018. 10. 15..
//  Copyright © 2018년 Mu Young Ko. All rights reserved.
//

#import "ReplaceRule.h"



#define ReplaceRuleExtension(replaceView, replaceJsonLayer, replaceJsonKey) [[ReplaceRuleExtension alloc] initWith:replaceView:replaceJsonLayer:replaceJsonKey]

@interface ReplaceRuleExtension : ReplaceRule

-(id)initWith:(UIView*)replaceView
             :(NSDictionary*)replaceJsonLayer
             :(NSString*)replaceJsonKey;

@property BOOL constructed;

@end


