//
//  ReplaceRuleRepeat.m
//  CloudJsonViewer
//
//  Created by Mu Young Ko on 2018. 6. 18..
//  Copyright © 2018년 Mu Young Ko. All rights reserved.
//

#import "ReplaceRuleRepeat.h"

@implementation ReplaceRuleRepeat

-(id)initWith:(UIView*)replaceView
             :(NSDictionary*)replaceJsonLayer
             :(NSString*)replaceJsonKey
{
    self = [super initWith:replaceView :RULE_TYPE_REPEAT :replaceJsonLayer :replaceJsonKey];
    self.createdRepeatView = [[NSMutableArray alloc] init];
    
    return self;
}

@end

@implementation CreatedViewInfo

-(id)initWithView:(UIView*)v type:(int)type{
    self = [super init];
    self.view = v;
    self.type = type;
    return self;
}
@end
