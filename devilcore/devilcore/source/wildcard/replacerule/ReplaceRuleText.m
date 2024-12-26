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
#import "WildCardUtil.h"
#import "DevilDynamicAsset.h"

@interface ReplaceRuleText()

@property (nonatomic, retain) NSString* name;
@property (nonatomic, retain) NSString* textContentHighLightKey;
@property (nonatomic, retain) UIColor* textContentHighLightColor;

@end

@implementation ReplaceRuleText

- (void)constructRule:(WildCardMeta *)wcMeta parent:(UIView *)parent vv:(WildCardUIView *)vv layer:(id)layer depth:(int)depth result:(id)result{
    [super constructRule:wcMeta parent:parent vv:vv layer:layer depth:depth result:result];
    self.replaceJsonKey = layer[@"textContent"];
    self.name = layer[@"name"];
    self.textContentHighLightKey = layer[@"textContentHighLight"];
    
    NSString* color = layer[@"textContentHighLightColor"];
    if(color)
        self.textContentHighLightColor = [WildCardUtil colorWithHexString:color];
    
    if(layer[@"font"]) {
        NSString* font_key = layer[@"font"];
        UILabel* label = [vv subviews][0];
        
        UIFont* font = [[DevilDynamicAsset sharedInstance] getFont:font_key fontSize:label.font.pointSize];
        label.font = font;
    }
}

- (void)updateRule:(WildCardMeta *)meta data:(id)opt {
    UILabel* lv = (UILabel*)self.replaceView;
    NSString* text = [MappingSyntaxInterpreter interpret:self.replaceJsonKey:opt];
    if(text == nil || [@"<null>" isEqualToString:text] )
        text = @"";//self.replaceJsonLayer[@"textSpec"][@"text"];

    if([WildCardConstructor sharedInstance].textTransDelegate != nil )
        text = [[WildCardConstructor sharedInstance].textTransDelegate translateLanguage:text :self.name];
    
    if(self.textContentHighLightKey && self.textContentHighLightColor) {
        NSString* textContentHighLightText = [MappingSyntaxInterpreter interpret:self.textContentHighLightKey:opt];
        if(textContentHighLightText) {
            [lv setText:text];
            NSRange range = [text rangeOfString:textContentHighLightText options:NSCaseInsensitiveSearch];
            if (range.location != NSNotFound) {
                NSMutableAttributedString *string = [[NSMutableAttributedString alloc] initWithString:text];
                [string addAttribute:NSForegroundColorAttributeName value:self.textContentHighLightColor range:range];
                lv.attributedText = string;
            }
            
        } else
            [lv setText:text];
    } else {
        [lv setText:text];
    }
}

@end
