//
//  ReplaceRuleIcon.m
//  devilcore
//
//  Created by Mu Young Ko on 2021/02/14.
//

#import "ReplaceRuleIcon.h"
#import "MappingSyntaxInterpreter.h"

@implementation ReplaceRuleIcon

- (void)constructRule:(WildCardMeta *)wcMeta parent:(UIView *)parent vv:(WildCardUIView *)vv layer:(id)layer depth:(int)depth result:(id)result{
    
    self.replaceJsonKey = layer[@"icon"];
    self.replaceView = vv;
}

- (void)updateRule:(WildCardMeta *)meta data:(id)opt{
    NSString* targetIconNode = [MappingSyntaxInterpreter interpret:self.replaceJsonKey:opt];
    id vs = [self.replaceView subviews];
    for(WildCardUIView* v in vs){
        if([targetIconNode isEqual:v.name]){
            v.hidden = NO;
        } else {
            v.hidden = YES;
        }
    }
}

@end
