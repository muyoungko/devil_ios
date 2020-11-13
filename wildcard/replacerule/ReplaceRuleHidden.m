//
//  ReplaceRuleHidden.m
//  CloudJsonViewer
//
//  Created by Mu Young Ko on 2018. 10. 4..
//  Copyright © 2018년 Mu Young Ko. All rights reserved.
//

#import "ReplaceRuleHidden.h"

@implementation ReplaceRuleHidden

-(id)initWith:(UIView*)replaceView
             :(NSDictionary*)replaceJsonLayer
             :(NSString*)replaceJsonKey
{
    self = [super initWith:replaceView :RULE_TYPE_HIDDEN :replaceJsonLayer :replaceJsonKey];
    return self;
}

@end
