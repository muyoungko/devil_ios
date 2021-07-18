//
//  ReplaceRuleWeb.m
//  devilcore
//
//  Created by Mu Young Ko on 2021/04/27.
//

#import "ReplaceRuleWeb.h"
#import "MappingSyntaxInterpreter.h"

@implementation ReplaceRuleWeb

- (void)constructRule:(WildCardMeta *)wcMeta parent:(UIView *)parent vv:(WildCardUIView *)vv layer:(id)layer depth:(int)depth result:(id)result{
    DevilWebView* web = [[DevilWebView alloc] init];
    [vv addSubview:web];
    [WildCardConstructor followSizeFromFather:vv child:web];
    
    self.replaceView = web;
    self.replaceJsonKey = layer[@"web"][@"url"];
    UIView* cc = [vv superview];
    vv.userInteractionEnabled = YES;
    while([[cc class] isEqual:[WildCardUIView class]]){
        cc.userInteractionEnabled = YES;
        cc = [cc superview];
    }
}

- (void)updateRule:(WildCardMeta *)meta data:(id)opt{
    WKWebView* web = (WKWebView*)self.replaceView;
    NSString* url = [MappingSyntaxInterpreter interpret:self.replaceJsonKey:opt];
    if([url hasPrefix:@"/"])
        url = [NSString stringWithFormat:@"%@%@", [WildCardConstructor sharedInstance].project[@"web_host"], url];
    if(url != nil){
        [web loadRequest:[NSURLRequest requestWithURL:[NSURL URLWithString:url]]];
    }
}

@end
