//
//  WildCardTrigger.m
//  library
//
//  Created by Mu Young Ko on 2018. 10. 31..
//  Copyright © 2018년 sbs cnbc. All rights reserved.
//

#import "WildCardTrigger.h"
#import "WildCardUIView.h"
#import "WildCardAction.h"

@implementation WildCardTrigger

-(id)initWithType:(NSString*)type nodeName:(NSString*)nodeName node:(WildCardUIView*)node
{
    self = [super init];
    if(self)
    {
        self.node = node;
        self.nodeName = nodeName;
        self.type = type;
        self.actions = [[NSMutableArray alloc] init];
    }
    
    return self;
}

-(void)addAction:(WildCardAction*)action
{
    [_actions addObject:action];
}


-(void)doAllAction
{
    for(int i=0;i<[_actions count];i++)
    {
        [_actions[i] act:self];
    }
}

@end
