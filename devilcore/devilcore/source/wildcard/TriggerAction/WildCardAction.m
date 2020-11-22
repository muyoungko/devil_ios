//
//  WildCardAction.m
//  library
//
//  Created by Mu Young Ko on 2018. 10. 31..
//  Copyright © 2018년 sbs cnbc. All rights reserved.
//

#import "WildCardAction.h"
#import "WildCardApplyAgainAction.h"
#import "WildCardCustomAction.h"
#import "WildCardViewPagerLeftAction.h"
#import "WildCardViewPagerRightAction.h"
#import "WildCardSetTextAction.h"
#import "WildCardMeta.h"

@implementation WildCardAction

- (instancetype)initWithMeta:(WildCardMeta*)meta
{
    self = [super init];
    if (self) {
        self.meta = meta;
    }
    return self;
}


+(void)parseAndConducts:(WildCardTrigger*)trigger action:(NSString*)actionString meta:(WildCardMeta*)meta
{
    NSArray* list = [actionString componentsSeparatedByString:@"|"];
    for(int i=0;i< [list count];i++)
    {
        NSString* action = [list objectAtIndex:i];
        [WildCardAction conduct:trigger action:action meta:meta];
    }
}

+(void)conduct:(WildCardTrigger*)trigger action:(NSString*)actionString meta:(WildCardMeta*)meta
{
    WildCardAction* action = [WildCardAction parse:meta action:actionString];
    [action act:trigger];
}

+(WildCardAction*)parse:(WildCardMeta*)meta  action:(NSString*) actionString
{
    NSString* functionName = actionString;
    NSUInteger index = [actionString rangeOfString:@"("].location;
    
    if(index >= 0)
    {
        functionName = [actionString substringToIndex:index];
    }
    
    NSMutableArray* args = [[NSMutableArray alloc] init];
    NSUInteger to = [actionString rangeOfString:@")" options:NSBackwardsSearch].location;
    NSString *tmp = [actionString substringWithRange:NSMakeRange(index+1, to-index-1)];
    
    NSArray* a = [tmp componentsSeparatedByString:@","];
    for(int i=0;i<[a count];i++)
    {
        NSString* t = [a[i] stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]];
        [args addObject:t];
    }
    
    WildCardAction* action = nil;
    //TODO : hash 매칭을 해야한다.
    if([actionString hasPrefix:@"viewPagerRight"])
    {
        WildCardViewPagerRightAction * c = [[WildCardViewPagerRightAction alloc] initWithMeta:meta];
        c.node = args[0];
        action = c;
    }
    else if([actionString hasPrefix:@"viewPagerLeft"])
    {
        WildCardViewPagerLeftAction * c = [[WildCardViewPagerLeftAction alloc] initWithMeta:meta];
        c.node = args[0];
        action = c;
    }
    else if([actionString hasPrefix:@"viewPagerScroll"])
    {
        WildCardViewPagerScrollAction * c = [[WildCardViewPagerScrollAction alloc] initWithMeta:meta];
        c.node = args[0];
        c.toScrollIndexArgument = args[1];
        action = c;
    }
    else if([actionString hasPrefix:@"update"])
    {
        WildCardApplyAgainAction * c = [[WildCardApplyAgainAction alloc] initWithMeta:meta];
        c.node = args[0];
        action = c;
    }
    else if([actionString hasPrefix:@"setText"])
    {
        WildCardSetTextAction * c = [[WildCardSetTextAction alloc] initWithMeta:meta];
        c.targetNodeName = args[0];
        c.jsonPath = args[1];
        action = c;
    }
    else if([actionString hasPrefix:@"setValue"])
    {
        WildCardSetValueAction * c = [[WildCardSetValueAction alloc] initWithMeta:meta];
        c.toJsonPath = args[0];
        c.targetjsonPath = args[1];
        action = c;
    }
    else if([actionString hasPrefix:@"startAnimation"])
    {
        //action = new LottieAnimationStart(context, meta, args.get(0));
    }
    else if(meta.wildCardConstructorInstanceDelegate != nil)
    {
        WildCardInstanceCustomAction * c = [[WildCardInstanceCustomAction alloc] initWithMeta:meta];
        c.args = args;
        c.function = functionName;
        action = c;
    }
    else
    {
        WildCardCustomAction * c = [[WildCardCustomAction alloc] initWithMeta:meta];
        c.args = args;
        c.function = functionName;
        action = c;
    }
    
    return action;
}

-(void)act:(WildCardTrigger*)trigger
{
    
}
@end
