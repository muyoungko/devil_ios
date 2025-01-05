//
//  ReplaceRuleStrip.m
//  devilcore
//
//  Created by Mu Young Ko on 2021/01/23.
//

#import "ReplaceRuleStrip.h"
#import "WildCardPagerTabStrip.h"
#import "WildCardUtil.h"
#import "WildCardPagerTabStripMaker.h"

@implementation ReplaceRuleStrip

- (void)constructRule:(WildCardMeta *)wcMeta parent:(UIView *)parent vv:(WildCardUIView *)vv layer:(id)layer depth:(int)depth result:(id)result{
    self.replaceJsonLayer = layer;
    
    WildCardPagerTabStrip *strip = [WildCardPagerTabStripMaker construct:layer :vv];
    self.replaceView = strip;
    [vv addSubview:strip];
    vv.userInteractionEnabled = YES;
    [WildCardUtil followSizeFromFather:vv child:strip];
    
}

- (void)updateRule:(WildCardMeta *)meta data:(id)opt{
    [WildCardPagerTabStripMaker update:self :opt];
}

@end
