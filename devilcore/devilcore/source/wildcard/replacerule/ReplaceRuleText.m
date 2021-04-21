//
//  ReplaceRuleText.m
//  CloudJsonViewer
//
//  Created by Mu Young Ko on 2018. 6. 18..
//  Copyright © 2018년 Mu Young Ko. All rights reserved.
//

#import "ReplaceRuleText.h"
#import "MappingSyntaxInterpreter.h"
#import "WildCardConstructor.h"

@implementation ReplaceRuleText


- (void)constructRule:(WildCardMeta *)wcMeta parent:(UIView *)parent vv:(WildCardUIView *)vv layer:(id)layer depth:(int)depth result:(id)result{
    self.replaceJsonKey = layer[@"textContent"];
}

- (void)updateRule:(WildCardMeta *)meta data:(id)opt {
    UILabel* lv = (UILabel*)self.replaceView;
    NSString* text = [MappingSyntaxInterpreter interpret:self.replaceJsonKey:opt];
    if(text == nil)
        text = self.replaceJsonLayer[@"textSpec"][@"text"];

    if([WildCardConstructor sharedInstance].textTransDelegate != nil )
        text = [[WildCardConstructor sharedInstance].textTransDelegate translateLanguage:text];
    
    [lv setText:text];
}

@end
