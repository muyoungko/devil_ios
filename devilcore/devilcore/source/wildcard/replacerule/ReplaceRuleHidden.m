//
//  ReplaceRuleHidden.m
//  CloudJsonViewer
//
//  Created by Mu Young Ko on 2018. 10. 4..
//  Copyright © 2018년 Mu Young Ko. All rights reserved.
//

#import "ReplaceRuleHidden.h"
#import "WildCardConstructor.h"
#import "MappingSyntaxInterpreter.h"

@implementation ReplaceRuleHidden


- (void)constructRule:(WildCardMeta *)wcMeta parent:(UIView *)parent vv:(WildCardUIView *)vv layer:(id)layer depth:(int)depth result:(id)result{
    self.replaceView = vv;
}

- (void)updateRule:(WildCardMeta *)meta data:(id)opt{
    if(self.replaceJsonLayer[@"hiddenCondition"]){
        if([MappingSyntaxInterpreter ifexpression:self.replaceJsonLayer[@"hiddenCondition"] data:opt defaultValue:YES]) {
            self.replaceView.hidden = YES;
        } else {
            self.replaceView.hidden = NO;
        }
    } else {
        if([MappingSyntaxInterpreter ifexpression:self.replaceJsonLayer[@"showCondition"] data:opt defaultValue:NO]) {
            self.replaceView.hidden = NO;
        } else {
            self.replaceView.hidden = YES;
        }
    }
}
@end
