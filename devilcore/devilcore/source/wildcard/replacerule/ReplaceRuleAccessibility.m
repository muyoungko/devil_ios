//
//  ReplaceRuleAccessibility.m
//  devilcore
//
//  Created by Mu Young Ko on 2021/05/12.
//

#import "ReplaceRuleAccessibility.h"
#import "MappingSyntaxInterpreter.h"
#import "WildCardConstructor.h"

@implementation ReplaceRuleAccessibility

- (void)constructRule:(WildCardMeta *)wcMeta parent:(UIView *)parent vv:(WildCardUIView *)vv layer:(id)layer depth:(int)depth result:(id)result{
    self.replaceView = vv;
    self.replaceJsonLayer = layer;
    self.replaceJsonKey = layer[@"accessibility"];
}

- (void)updateRule:(WildCardMeta *)meta data:(id)opt {
    NSString* text = [MappingSyntaxInterpreter interpret:self.replaceJsonKey:opt];
    if(text == nil)
        self.replaceView.accessibilityLabel = self.replaceJsonLayer[@"name"];
    else
        self.replaceView.accessibilityLabel = text;
}

@end
