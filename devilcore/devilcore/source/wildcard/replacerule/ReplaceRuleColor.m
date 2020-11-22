//
//  ReplaceRuleColor.m
//  library
//
//  Created by Mu Young Ko on 2018. 11. 5..
//  Copyright © 2018년 sbs cnbc. All rights reserved.
//

#import "ReplaceRuleColor.h"

@implementation ReplaceRuleColor

-(id)initWith:(UIView*)replaceView
             :(NSDictionary*)replaceJsonLayer
             :(NSString*)replaceJsonKey
{
    self = [super initWith:replaceView :RULE_TYPE_COLOR :replaceJsonLayer :replaceJsonKey];
    return self;
}

@end
