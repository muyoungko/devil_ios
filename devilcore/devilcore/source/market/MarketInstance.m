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
#import "DevilImageMapMarketComponent.h"
#import "DevilChartMarketComponent.h"
#import "DevilBlockDrawerMarketComponent.h"
#import "DevilGoogleAdsBannerMarketComponent.h"
#import "WildCardMeta.h"
#import "ReplaceRule.h"
#import "ReplaceRuleMarket.h"
#import "DevilGoogleMapMarketComponent.h"
#import "DevilPaintMarketComponent.h"

@implementation MarketInstance

+(MarketComponent*)create:(id)market meta:(id)meta vv:(id)vv{
    NSString* type = market[@"type"];
    MarketComponent* r = nil;
    
    if([@"chat" isEqualToString:type]) {
        r = [[DevilChat alloc] initWithLayer:market meta:meta];
    } else if([@"calendar" isEqualToString:type]) {
        r = [[DevilCalendar alloc] initWithLayer:market meta:meta];
    } else if([@"kr.co.july.picker" isEqualToString:type]) {
        r = [[DevilPicker alloc] initWithLayer:market meta:meta];
    } else if([@"kr.co.july.imagemap" isEqualToString:type]) {
        r = [[DevilImageMapMarketComponent alloc] initWithLayer:market meta:meta];
    } else if([@"kr.co.july.chart" isEqualToString:type]) {
        r = [[DevilChartMarketComponent alloc] initWithLayer:market meta:meta];
    } else if([@"kr.co.july.blockdrawer" isEqualToString:type]) {
        r = [[DevilBlockDrawerMarketComponent alloc] initWithLayer:market meta:meta];
    } else if([@"kr.co.july.googleads" isEqualToString:type]) {
        r = [[DevilGoogleAdsBannerMarketComponent alloc] initWithLayer:market meta:meta];
    } else if([@"kr.co.july.map" isEqualToString:type]) {
        r = [[DevilGoogleMapMarketComponent alloc] initWithLayer:market meta:meta];
    } else if([@"kr.co.july.paint" isEqualToString:type]) {
        r = [[DevilPaintMarketComponent alloc] initWithLayer:market meta:meta];
    } else {
        r = [[MarketComponent alloc] initWithLayer:market meta:meta];
    }
    r.vv = vv;
    return r;
}

+(MarketComponent*)findMarketComponent:(id)meta replaceView:(id)vv{
    WildCardMeta* mmeta = (WildCardMeta*)meta;
    for(ReplaceRule* rule in mmeta.replaceRules) {
        if([rule isKindOfClass:[ReplaceRuleMarket class]] && rule.replaceView == vv) {
            ReplaceRuleMarket* m = (ReplaceRuleMarket*)rule;
            return m.marketComponent;
        }
    }
    return nil;
}
@end
