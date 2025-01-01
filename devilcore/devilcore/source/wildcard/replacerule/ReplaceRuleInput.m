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
@property (nonatomic, retain) id input;
@property (nonatomic, retain) NSString* show_password_node;
@property BOOL password;
@property BOOL show_password_switch;
@property BOOL first_update;
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
        id input = layer[@"input"];
        self.password = [@"Y" isEqualToString:input[@"select4"]];
        if(self.password) {
            self.show_password_node = input[@"select15"];
            self.show_password_switch = NO;
        }
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
    self.first_update = YES;
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
    
    if(self.first_update) {
        self.first_update = NO;
        
        if(self.show_password_node && self.password) {
            DevilController* vc = (DevilController*)[JevilInstance currentInstance].vc;
            MetaAndViewResult* mv = [vc findViewWithMeta:self.show_password_node];
            if(mv && mv.view) {
                UITapGestureRecognizer* tap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(showPasswordClick:)];
                [WildCardConstructor userInteractionEnableToParentPath:mv.view depth:5];
                mv.view.userInteractionEnabled = YES;
                [mv.view addGestureRecognizer:tap];
            }
        }
    }
}

- (void)showPasswordClick:(id)sender {
    self.show_password_switch = !self.show_password_switch;
    WildCardUITextField* tf = (WildCardUITextField*)self.replaceView;
    if(self.show_password_switch)
        tf.secureTextEntry = NO;
    else
        tf.secureTextEntry = YES;
}

@end
