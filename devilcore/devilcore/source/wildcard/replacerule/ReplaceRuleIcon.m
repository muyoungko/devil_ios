//
//  ReplaceRuleIcon.m
//  devilcore
//
//  Created by Mu Young Ko on 2021/02/14.
//

#import "ReplaceRuleIcon.h"
#import "MappingSyntaxInterpreter.h"

@implementation ReplaceRuleIcon

-(id)initWith:(UIView*)replaceView
             :(NSDictionary*)replaceJsonLayer
             :(NSString*)replaceJsonKey
{
    self = [super initWith:replaceView :RULE_TYPE_ICON :replaceJsonLayer :replaceJsonKey];
    return self;
}

+(void)update:(ReplaceRuleIcon*)rule :(id)opt{
    NSString* targetIconNode = [MappingSyntaxInterpreter interpret:rule.replaceJsonKey:opt];
    id vs = [rule.replaceView subviews];
    for(WildCardUIView* v in vs){
        if([targetIconNode isEqual:v.name]){
            v.hidden = NO;
        } else {
            v.hidden = YES;
        }
    }
}

@end
