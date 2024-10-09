//
//  ReplaceRuleInput.m
//  devilcore
//
//  Created by Mu Young Ko on 2024/10/10.
//

#import "ReplaceRuleInput.h"
#import "WildCardUITextView.h"
#import "WildCardUITextField.h"

@interface ReplaceRuleInput()
@property id input;
@end


@implementation ReplaceRuleInput

- (void)constructRule:(WildCardMeta *)meta parent:(UIView *)parent vv:(WildCardUIView *)vv layer:(id)layer depth:(int)depth result:(id)result{
    id input = layer[@"input"];
    self.input = input;
    UIView *v = nil;
    if([@"multiline" isEqualToString:input[@"select7"]]){
        v = [WildCardUITextView create:layer meta:meta];
    } else {
        v = [WildCardUITextField create:layer meta:meta];
    }
    self.replaceView = v;
    
    CGRect containerRect = [WildCardConstructor getFrame:layer:parent];
    containerRect.origin.x = containerRect.origin.y = 0;
    if([v isMemberOfClass:[WildCardUITextView class]] && ((WildCardUITextView*)v).variableHeight )
        [meta addWrapContent:vv depth:depth];
    
    v.frame = containerRect;
    [vv addSubview:v];
    
    vv.userInteractionEnabled = YES;
    [WildCardConstructor userInteractionEnableToParentPath:vv depth:depth];
}

- (void)updateRule:(WildCardMeta *)meta data:(id)opt{
    if([[self.replaceView class] isEqual:[WildCardUITextView class]]){
        WildCardUITextView* tf = (WildCardUITextView*)self.replaceView;
        if(tf.placeholderLabel == nil){
            UILabel* ppp = [[UILabel alloc] initWithFrame:tf.frame];
            if(tf.verticalAlignTop)
                ppp.frame = CGRectMake(0, 0, tf.frame.size.width, 25);
            ppp.text = tf.placeholderText;
            ppp.font = tf.font;
            ppp.textColor = [UIColor lightGrayColor];
            tf.placeholderLabel = ppp;
            [[tf superview] addSubview:ppp];
        }
    }
    WildCardUITextField* dt = (WildCardUITextField*)self.replaceView;
    NSString* select3 = self.input[@"select3"];
    NSString* text = @"";
    if(![opt[select3] isUndefined] && ![opt[select3] isNull])
        text = [NSString stringWithFormat:@"%@", opt[select3]]; //숫자가 나올때가 있다
    if(![dt.text isEqualToString:text])
        dt.text = text;
}

@end
