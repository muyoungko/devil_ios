//
//  WildCardUITextField.m
//  library
//
//  Created by Mu Young Ko on 2018. 11. 10..
//  Copyright © 2018년 sbs cnbc. All rights reserved.
//

#import "WildCardUITextField.h"
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

@interface WildCardUITextField()
@property (nonatomic, retain) NSString* lastText;
@end

@implementation WildCardUITextField

+(WildCardUITextField*)create:(id)layer meta:(WildCardMeta*)meta {
    NSDictionary* extension = [layer objectForKey:@"extension"];
    WildCardUITextField* tf = [[WildCardUITextField alloc] init];
    NSMutableDictionary* textSpec = [layer objectForKey:@"textSpec"];
    if(textSpec != nil)
    {
        float sketchTextSize = [[textSpec objectForKey:@"textSize"] floatValue];
        float textSize = [WildCardConstructor convertTextSize:sketchTextSize];
        tf.font = [UIFont systemFontOfSize:textSize];
        tf.textColor = [WildCardUtil colorWithHexString:[textSpec objectForKey:@"textColor"]];
        NSString* text = [textSpec objectForKey:@"text"];
        if([WildCardConstructor sharedInstance].textTransDelegate != nil )
            text = [[WildCardConstructor sharedInstance].textTransDelegate translateLanguage:text];
        tf.placeholder = text;
        
        NSString *placeHolderTextColor = @"#777777";
        if(extension[@"select9"] != nil)
            placeHolderTextColor = extension[@"select9"];
        
        if(extension[@"select12"])
            tf.maxLength = [extension[@"select12"] intValue];
        else
            tf.maxLength = -1;
            
        if(SYSTEM_VERSION_GREATER_THAN_OR_EQUAL_TO(@"13.0"))
            tf.attributedPlaceholder = [[NSAttributedString alloc] initWithString:textSpec[@"text"] attributes:@{NSForegroundColorAttributeName:
                                                                                                                       [WildCardUtil colorWithHexString:placeHolderTextColor]}];
        else
            [tf setValue:[WildCardUtil colorWithHexString:placeHolderTextColor] forKeyPath:@"_placeholderLabel.textColor"];
        
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
    
    tf.delegate = tf;
    
    return tf;
}

-(id)init
{
    self = [super init];
    self.showXButton = NO;
    self.xbuttonImageName = nil;
    self.doneClickAction = nil;
    [self addTarget:self action:@selector(textChanged:) forControlEvents:UIControlEventEditingChanged];
    return self;
}
- (BOOL)textFieldShouldReturn:(UITextField *)textField
{
    [self doneClick];
    return YES;
}

- (void)doneClick {
    if(self.doneClickAction != nil)
    {
        WildCardTrigger* trigger = [[WildCardTrigger alloc] init];
        [WildCardAction parseAndConducts:trigger action:self.doneClickAction meta:self.meta];
    }
}

- (void)textChanged:(UITextField *)textField{
    UIView* p = [self superview];
    if(self.showXButton)
    {
        UIButton* b = [p viewWithTag:5192837];
        if(b == nil)
        {
            float pw = p.frame.size.width;
            float ph = p.frame.size.height;
            float bw = ph;
            float inset = ph/3;
            UIButton* b = [[UIButton alloc] initWithFrame:CGRectMake(pw-bw, 0, bw, bw)];
            b.tag = 5192837;
            b.imageEdgeInsets = UIEdgeInsetsMake(inset, inset, inset, inset);
            [b setImage:[UIImage imageNamed:_xbuttonImageName] forState:UIControlStateNormal];
            b.accessibilityLabel = @"지우기";
            [b addTarget:self action:@selector(clearAll:) forControlEvents:UIControlEventTouchUpInside];
            [p addSubview:b];
        }
        b.hidden = NO;
        if([textField text].length > 0)
        {
            b.hidden = NO;
        }
        else
            b.hidden = YES;
    }
    [_meta.correspondData setObject:[textField text] forKey:_holder];
    
    if(self.textChangedCallback != nil && ![[textField text] isEqualToString:self.lastText]) {
        self.lastText = [textField text];
        self.textChangedCallback([textField text]);
    }
}

-(void)clearAll:(id)sender
{
    self.text = @"";
    if(self.showXButton)
    {
        UIView* p = [self superview];
        UIButton* b = [p viewWithTag:5192837];
        b.hidden = YES;
    }
}

- (BOOL)textField:(UITextField *)textField shouldChangeCharactersInRange:(NSRange)range replacementString:(NSString *)string
{
    return YES;
}
- (BOOL)textFieldShouldEndEditing:(UITextField *)textField
{
    [_meta.correspondData setObject:[textField text] forKey:_holder];
    return YES;
}

- (void)textFieldDidBeginEditing:(UITextField *)textField{
    if(self.textFocusChangedCallback != nil) {
        self.textFocusChangedCallback(true);
    }
}

- (void)textFieldDidEndEditing:(UITextField *)textField
{
    [_meta.correspondData setObject:[textField text] forKey:_holder];
    if(self.textFocusChangedCallback != nil) {
        self.textFocusChangedCallback(false);
    }
}

- (BOOL)shouldChangeTextInRange:(UITextRange *)range replacementText:(NSString *)text {
    if(self.maxLength > 0 && [text length] <= self.maxLength)
        return true;
    else
        return true;
}

- (void)touchesBegan:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event
{
    NSLog(@"touches begin - TextField input");
}

@end
