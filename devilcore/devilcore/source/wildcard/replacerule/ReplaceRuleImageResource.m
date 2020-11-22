//
//  ReplaceRuleImageResource.m
//  sticar
//
//  Created by Mu Young Ko on 2019. 7. 5..
//  Copyright © 2019년 trix. All rights reserved.
//

#import "ReplaceRuleImageResource.h"

@implementation ReplaceRuleImageResource

-(id)initWith:(UIView*)replaceView
             :(NSDictionary*)replaceJsonLayer
             :(NSString*)replaceJsonKey
{
    self = [super initWith:replaceView :RULE_TYPE_IMAGE_RESOURCE :replaceJsonLayer :replaceJsonKey];
    return self;
}

@end
