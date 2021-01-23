//
//  ReplaceRuleStrip.m
//  devilcore
//
//  Created by Mu Young Ko on 2021/01/23.
//

#import "ReplaceRuleStrip.h"

@implementation ReplaceRuleStrip

-(id)initWith:(UIView*)replaceView
             :(NSDictionary*)replaceJsonLayer
             :(NSString*)replaceJsonKey
{
    self = [super initWith:replaceView :RULE_TYPE_STRIP :replaceJsonLayer :replaceJsonKey];
    return self;
}

@end
