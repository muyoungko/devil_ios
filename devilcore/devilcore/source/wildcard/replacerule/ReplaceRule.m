//
//  ReplaceRule.m
//  CloudJsonViewer
//
//  Created by Mu Young Ko on 2018. 6. 18..
//  Copyright © 2018년 Mu Young Ko. All rights reserved.
//

#import "ReplaceRule.h"

@implementation ReplaceRule

-(id)initWith:(UIView*)replaceView
    :(int)replaceType
    :(NSMutableDictionary*)replaceJsonLayer
    :(NSString*)replaceJsonKey
{
    self = [super init];
    if (self != nil) {
        self.replaceView = replaceView;
        self.replaceType = replaceType;
        self.replaceJsonLayer = replaceJsonLayer;
        self.replaceJsonKey = replaceJsonKey;
    }
    return self;
}

- (id)initWithRuleJson:(NSDictionary *)replaceJsonLayer{
    self = [super init];
    self.replaceJsonLayer = replaceJsonLayer;
    return self;
}

-(void)constructRule:(WildCardMeta*)wcMeta parent:(UIView*)parent vv:(WildCardUIView*)vv layer:(id)layer depth:(int)depth result:(id)result{
    
}

-(void)updateRule:(WildCardMeta*)meta data:(id)opt {
    
}

@end
