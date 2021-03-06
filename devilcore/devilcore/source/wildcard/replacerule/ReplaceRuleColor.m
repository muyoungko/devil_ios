//
//  ReplaceRuleColor.m
//  library
//
//  Created by Mu Young Ko on 2018. 11. 5..
//  Copyright © 2018년 sbs cnbc. All rights reserved.
//

#import "ReplaceRuleColor.h"
#import "WildCardConstructor.h"
#import "MappingSyntaxInterpreter.h"
#import "WildCardUtil.h"
#import "WildCardUILabel.h"

@implementation ReplaceRuleColor


- (void)constructRule:(WildCardMeta *)wcMeta parent:(UIView *)parent vv:(WildCardUIView *)vv layer:(id)layer depth:(int)depth result:(id)result{
    self.replaceJsonLayer = [layer objectForKey:@"colorMapping"];
    self.replaceView = vv;
    
}

- (void)updateRule:(WildCardMeta *)meta data:(id)opt{
    NSMutableDictionary* colorMapping = self.replaceJsonLayer;
    if(colorMapping[@"b"] != nil && [colorMapping[@"b"] length] > 0) {
        NSString* jsonpath = colorMapping[@"b"];
        NSString* colorCode = [MappingSyntaxInterpreter interpret:jsonpath :opt];
        if(colorCode != nil && [colorCode length] > 0){
            UIColor *c = [WildCardUtil colorWithHexString:colorCode];
            self.replaceView.backgroundColor = c;
            WildCardUIView* v = (WildCardUIView*)self.replaceView;
            if(v.layer.borderWidth > 0 && (colorMapping[@"f"] == nil || [@"" isEqualToString:colorMapping[@"f"]]))
                v.layer.borderColor = [c CGColor];
        }
    }
    if(colorMapping[@"f"] != nil && [colorMapping[@"f"] length] > 0) {
        NSString* jsonpath = colorMapping[@"f"];
        NSString* colorCode = [MappingSyntaxInterpreter interpret:jsonpath :opt];
        if(colorCode != nil && [colorCode length] > 0){
            UIColor *c = [WildCardUtil colorWithHexString:colorCode];
            if([self.replaceView class] == [WildCardUIView class])
            {
                WildCardUIView* v = (WildCardUIView*)self.replaceView;
                if([[v subviews] count] == 1 && [[v subviews][0] class] == [WildCardUILabel class])
                {
                    WildCardUILabel* tv = (WildCardUILabel*)[v subviews][0];
                    [tv setTextColor:c];
                } else if([[v subviews] count] == 1 && [[v subviews][0] class] == [UIImageView class]) {
                    UIImageView* iv = (UIImageView*)[v subviews][0];
                    iv.image = [iv.image imageWithRenderingMode:UIImageRenderingModeAlwaysTemplate];
                    iv.tintColor = c;
                } else if(v.layer.borderWidth > 0)
                {
                    v.layer.borderColor = [c CGColor];
                }
                else
                    [self.replaceView setBackgroundColor:c];
            }
            else
                [self.replaceView setBackgroundColor:c];
        }
    }
}

@end
