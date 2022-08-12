//
//  ReplaceRuleMarket.m
//  devilcore
//
//  Created by Mu Young Ko on 2021/07/12.
//

#import "ReplaceRuleMarket.h"
#import "MarketComponent.h"
#import "MarketInstance.h"

@interface ReplaceRuleMarket()

@end

@implementation ReplaceRuleMarket

- (void)constructRule:(WildCardMeta *)wcMeta parent:(UIView *)parent vv:(WildCardUIView *)vv layer:(id)layer depth:(int)depth result:(id)result{
    id market = layer[@"market"];
    self.replaceJsonLayer = market;
    self.replaceView = vv;
    self.marketComponent = [MarketInstance create:market meta:wcMeta vv:vv];
    [self.marketComponent initialized];
}

- (void)updateRule:(WildCardMeta *)meta data:(id)opt{
    [self.marketComponent update:opt];
}

@end
