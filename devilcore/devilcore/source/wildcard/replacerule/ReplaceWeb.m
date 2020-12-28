//
//  ReplaceWe.m
//  devilcore
//
//  Created by Mu Young Ko on 2020/12/28.
//

#import "ReplaceWeb.h"

@implementation ReplaceWeb

-(id)initWith:(UIView*)replaceView
             :(NSDictionary*)replaceJsonLayer
             :(NSString*)replaceJsonKey
{
    self = [super initWith:replaceView :RULE_TYPE_WEB :replaceJsonLayer :replaceJsonKey];
    return self;
}


@end
