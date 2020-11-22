//
//  ReplaceRuleExtention.m
//  CloudJsonViewer
//
//  Created by Mu Young Ko on 2018. 10. 15..
//  Copyright © 2018년 Mu Young Ko. All rights reserved.
//

#import "ReplaceRuleExtension.h"

@implementation ReplaceRuleExtension


-(id)initWith:(UIView*)replaceView
             :(NSDictionary*)replaceJsonLayer
             :(NSString*)replaceJsonKey
{
    self = [super initWith:replaceView :RULE_TYPE_EXTENSION :replaceJsonLayer :replaceJsonKey];
    
    self.constructed = NO;
    
    return self;
}



@end
