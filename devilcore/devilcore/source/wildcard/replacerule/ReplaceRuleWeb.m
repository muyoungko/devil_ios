//
//  ReplaceRuleWeb.m
//  devilcore
//
//  Created by Mu Young Ko on 2021/04/27.
//

#import "ReplaceRuleWeb.h"
#import "MappingSyntaxInterpreter.h"
#import "DevilUtil.h"
#import "JevilInstance.h"
#import "DevilController.h"
#import "WildCardUITapGestureRecognizer.h"

@interface ReplaceRuleWeb()
@property (nonatomic, retain) NSString* lastUrl;
@property (nonatomic, retain) WildCardUITapGestureRecognizer* singleFingerTap;
@end

@implementation ReplaceRuleWeb

- (void)constructRule:(WildCardMeta *)wcMeta parent:(UIView *)parent vv:(WildCardUIView *)vv layer:(id)layer depth:(int)depth result:(id)result{
    DevilWebView* web = [[DevilWebView alloc] init];
    [vv addSubview:web];
    [WildCardUtil followSizeFromFather:vv child:web];
    
    self.replaceView = web;
    self.replaceJsonKey = layer[@"web"][@"url"];
    UIView* cc = [vv superview];
    vv.userInteractionEnabled = YES;
    while([[cc class] isEqual:[WildCardUIView class]]){
        cc.userInteractionEnabled = YES;
        cc = [cc superview];
    }
    
    DevilController* dc = (DevilController*)[JevilInstance currentInstance].vc;
    dc.onBackPressCallback = ^BOOL{
        if([web canGoBack]) {
            [web goBack];
            return YES;
        }
        return NO;
    };
    
    
    NSString* scriptScrollEnd = layer[@"web"][@"scriptScrollEnd"];
    if(scriptScrollEnd) {
        web.scrollBottomCallback = ^{
            WildCardTrigger* trigger = [[WildCardTrigger alloc] init];
            trigger.node = vv;
            [WildCardAction execute:trigger script:scriptScrollEnd meta:wcMeta];
        };
    }
    
}

- (void)updateRule:(WildCardMeta *)meta data:(id)opt{
    WKWebView* web = (WKWebView*)self.replaceView;
    NSString* url = [MappingSyntaxInterpreter interpret:self.replaceJsonKey:opt];
    if([url hasPrefix:@"/"]) {
        NSString* token = [Jevil get:@"x-access-token"];
        url = [NSString stringWithFormat:@"%@%@", [WildCardConstructor sharedInstance].project[@"web_host"], url];
        NSURL* nsurl = [NSURL URLWithString:url];
        id query = [DevilUtil queryToJson:nsurl];
        if(!query[@"token"] && token) {
            if([query count] > 0)
                url = [url stringByAppendingFormat:@"&token=%@", token];
            else
                url = [url stringByAppendingFormat:@"?token=%@", token];
        }
    }
    
    if(url != nil && [url hasPrefix:@"javascript:"]) {
        [web evaluateJavaScript:url completionHandler:^(id _Nullable, NSError * _Nullable error) {
            
        }];
    }
    else if(url != nil && ![url isEqualToString:self.lastUrl]){
        self.lastUrl = url;
        [web loadRequest:[NSURLRequest requestWithURL:[NSURL URLWithString:url]]];
    }
}

@end
