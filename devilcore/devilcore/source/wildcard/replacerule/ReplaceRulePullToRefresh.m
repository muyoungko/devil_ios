//
//  ReplaceRulePullToRefresh.m
//  devilcore
//
//  Created by Mu Young Ko on 2022/05/06.
//

#import "ReplaceRulePullToRefresh.h"

@implementation ReplaceRulePullToRefresh

- (void)constructRule:(WildCardMeta *)wcMeta parent:(UIView *)parent vv:(WildCardUIView *)vv layer:(id)layer depth:(int)depth result:(id)result{
    UIView* iv = [[UIImageView alloc] init];
    self.replaceView = iv;
    self.replaceJsonKey = layer[@"qrcode"][@"code"];
}

- (void)updateRule:(WildCardMeta *)meta data:(id)opt{
    
}


@end
