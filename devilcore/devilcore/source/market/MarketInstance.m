//
//  MarketInstance.m
//  devilcore
//
//  Created by Mu Young Ko on 2021/07/12.
//

#import "MarketInstance.h"
#import "MarketComponent.h"
#import "DevilChat.h"
#import "DevilCalendar.h"
#import "DevilPicker.h"

@implementation MarketInstance

+(MarketComponent*)create:(id)market meta:(id)meta{
    NSString* type = market[@"type"];
    MarketComponent* r = nil;
    if([@"chat" isEqualToString:type]) {
        r = [[DevilChat alloc] initWithLayer:market meta:meta];
    } else if([@"calendar" isEqualToString:type]) {
        r = [[DevilCalendar alloc] initWithLayer:market meta:meta];
    } else if([@"kr.co.july.picker" isEqualToString:type]) {
        r = [[DevilPicker alloc] initWithLayer:market meta:meta];
    } else {
        r = [[MarketComponent alloc] initWithLayer:market meta:meta];
    }
    return r;
}

@end
