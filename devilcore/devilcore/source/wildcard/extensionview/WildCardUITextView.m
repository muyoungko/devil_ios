//
//  WildCardUITextField.m
//  library
//
//  Created by Mu Young Ko on 2018. 11. 10..
//  Copyright © 2018년 sbs cnbc. All rights reserved.
//

#import "WildCardUITextView.h"
#import "WildCardMeta.h"
#import "WildCardTrigger.h"
#import "WildCardAction.h"
#import "WildCardUtil.h"
#import "WildCardConstructor.h"

#define SYSTEM_VERSION_EQUAL_TO(v)                  ([[[UIDevice currentDevice] systemVersion] compare:v options:NSNumericSearch] == NSOrderedSame)
#define SYSTEM_VERSION_GREATER_THAN(v)              ([[[UIDevice currentDevice] systemVersion] compare:v options:NSNumericSearch] == NSOrderedDescending)
#define SYSTEM_VERSION_GREATER_THAN_OR_EQUAL_TO(v)  ([[[UIDevice currentDevice] systemVersion] compare:v options:NSNumericSearch] != NSOrderedAscending)
#define SYSTEM_VERSION_LESS_THAN(v)                 ([[[UIDevice currentDevice] systemVersion] compare:v options:NSNumericSearch] == NSOrderedAscending)
#define SYSTEM_VERSION_LESS_THAN_OR_EQUAL_TO(v)     ([[[UIDevice currentDevice] systemVersion] compare:v options:NSNumericSearch] != NSOrderedDescending)

@implementation WildCardUITextView

+(WildCardUITextView*)create:(id)layer meta:(WildCardMeta*)meta {
    NSDictionary* extension = [layer objectForKey:@"extension"];
    WildCardUITextView* tf = [[WildCardUITextView alloc] init];
    NSMutableDictionary* textSpec = [layer objectForKey:@"textSpec"];
    if(textSpec != nil)
    {
        float sketchTextSize = [[textSpec objectForKey:@"textSize"] floatValue];
        float textSize = [WildCardConstructor convertTextSize:sketchTextSize];
        tf.font = [UIFont systemFontOfSize:textSize];
        tf.originalTextColor = tf.textColor = [WildCardUtil colorWithHexString:[textSpec objectForKey:@"textColor"]];
        tf.emtpy = true;
        tf.placeholderLabel = nil;
        NSString* text = [textSpec objectForKey:@"text"];
        if([WildCardConstructor sharedInstance].textTransDelegate != nil )
            text = [[WildCardConstructor sharedInstance].textTransDelegate translateLanguage:text];
        tf.placeholderText = text;
        
        if(SYSTEM_VERSION_GREATER_THAN_OR_EQUAL_TO(@"13.0"))
            ;
        else
            [tf setValue:[WildCardUtil colorWithHexString:@"#777777"] forKeyPath:@"_placeholderLabel.textColor"];
        
        int halignment = 1;
        int valignment = 0;
        if([textSpec objectForKey:@"alignment"] != nil)
            halignment = [[textSpec objectForKey:@"alignment"] intValue];
        if([textSpec objectForKey:@"valignment"] != nil)
            valignment = [[textSpec objectForKey:@"valignment"] intValue];
        
        if(halignment == 3)
            tf.textAlignment = NSTextAlignmentLeft;
        else if(halignment == 17)
            tf.textAlignment = NSTextAlignmentCenter;
        else if(halignment == 5)
            tf.textAlignment = NSTextAlignmentRight;
        
        if(valignment == 0) {
            valignment = GRAVITY_TOP;
        }
        else if(valignment == 1) {
            valignment = GRAVITY_VERTICAL_CENTER;
        }
        else if(valignment == 2) {
            valignment = GRAVITY_BOTTOM;
        }
    }
    tf.userInteractionEnabled = YES;
    NSString* holder = extension[@"select3"];
    tf.meta = meta;
    tf.holder = holder;
    tf.autocapitalizationType = UITextAutocapitalizationTypeNone;
    
    tf.returnKeyType = UIReturnKeyDone;

    if([WildCardConstructor sharedInstance].xButtonImageName != nil)
    {
        tf.xbuttonImageName = [WildCardConstructor sharedInstance].xButtonImageName;
        tf.showXButton = YES;
    }
    
    if(extension[@"select4"] != nil && [@"Y" isEqualToString:extension[@"select4"]]){
        tf.secureTextEntry = YES;
    } else if([@"number" isEqualToString:extension[@"select7"]]){
        tf.keyboardType = UIKeyboardTypeNumberPad;
    }
    
    if(extension[@"select5"] != nil)
    {
        tf.doneClickAction = extension[@"select5"];
    }
    
    if([@"search" isEqualToString:extension[@"select6"]])
        tf.returnKeyType = UIReturnKeySearch;
    else if([@"next" isEqualToString:extension[@"select6"]])
        tf.returnKeyType = UIReturnKeyNext;
    else if([@"enter" isEqualToString:extension[@"select6"]])
        tf.returnKeyType = UIReturnKeyNext;
    
    tf.delegate = tf;
    
    tf.showsVerticalScrollIndicator = YES;
    tf.showsHorizontalScrollIndicator = NO;
    
    return tf;
}

-(id)init
{
    self = [super init];
    self.showXButton = NO;
    self.emtpy = YES;
    self.xbuttonImageName = nil;
    self.doneClickAction = nil;
    [[NSNotificationCenter defaultCenter] addObserver:self
                                          selector:@selector(textChanged:)
                                          name:UITextViewTextDidChangeNotification
                                          object:nil];
    return self;
}

- (void)setText:(NSString *)text{
    [super setText:text];
    if(self.placeholderLabel != nil){
        if(text == nil || [@"" isEqualToString:text])
            self.placeholderLabel.hidden = NO;
        else
            self.placeholderLabel.hidden = YES;
    }
}

- (void)textViewDidBeginEditing:(UITextView *)textView{
    if(self.placeholderLabel != nil){
        self.placeholderLabel.hidden = YES;
    }
}

- (void)textViewDidEndEditing:(UITextView *)textView{
    NSString* text = [textView text];
    [_meta.correspondData setObject:[textView text] forKey:_holder];
    if(self.placeholderLabel != nil){
        if(text == nil || [@"" isEqualToString:text])
            self.placeholderLabel.hidden = NO;
        else
            self.placeholderLabel.hidden = YES;
    }
}

- (void)textViewDidChange:(UITextView *)textView{
    NSString* text = self.text;
    [_meta.correspondData setObject:self.text forKey:_holder];
    if(self.placeholderLabel != nil){
        if(text == nil || [@"" isEqualToString:text])
            self.placeholderLabel.hidden = NO;
        else
            self.placeholderLabel.hidden = YES;
    }
}

- (BOOL)textFieldShouldReturn:(UITextField *)textField
{
    if(self.doneClickAction != nil)
    {
        WildCardTrigger* trigger = [[WildCardTrigger alloc] init];
        [WildCardAction parseAndConducts:trigger action:self.doneClickAction meta:self.meta];
        textField.text = @"";
        [_meta.correspondData setObject:@"" forKey:_holder];
    }
        
    return YES;
}

- (void)textChanged:(UITextField *)textField{
    [_meta.correspondData setObject:self.text forKey:_holder];
}


//- (BOOL)textField:(UITextField *)textField shouldChangeCharactersInRange:(NSRange)range replacementString:(NSString *)string
//{
//    return YES;
//}
//- (BOOL)textFieldShouldEndEditing:(UITextField *)textField
//{
//    [_meta.correspondData setObject:[textField text] forKey:_holder];
//    return YES;
//}
//- (void)textFieldDidEndEditing:(UITextField *)textField
//{
//    [_meta.correspondData setObject:[textField text] forKey:_holder];
//}
//
//- (void)touchesBegan:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event
//{
//    NSLog(@"touches begin - TextField input");
//}
@end
