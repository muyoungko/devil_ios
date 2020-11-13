//
//  ReplaceRuleLocalImage.m
//  CloudJsonViewer
//
//  Created by Mu Young Ko on 2018. 6. 18..
//  Copyright © 2018년 Mu Young Ko. All rights reserved.
//

#import "ReplaceRuleLocalImage.h"

@implementation ReplaceRuleLocalImage

-(id)initWith:(UIView*)replaceView
             :(NSDictionary*)replaceJsonLayer
             :(NSString*)replaceJsonKey
{
    self = [super initWith:replaceView :RULE_TYPE_LOCAL_IMAGE :replaceJsonLayer :replaceJsonKey];
    return self;
}

@end
