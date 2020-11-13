//
//  ReplaceRuleReplaceUrl.m
//  CloudJsonViewer
//
//  Created by Mu Young Ko on 2018. 10. 15..
//  Copyright © 2018년 Mu Young Ko. All rights reserved.
//

#import "ReplaceRuleReplaceUrl.h"

@implementation ReplaceRuleReplaceUrl

-(id)initWith:(UIView*)replaceView
             :(NSDictionary*)replaceJsonLayer
             :(NSString*)replaceJsonKey
{
    self = [super initWith:replaceView :RULE_TYPE_REPLACE_URL :replaceJsonLayer :replaceJsonKey];
    return self;
}

@end
