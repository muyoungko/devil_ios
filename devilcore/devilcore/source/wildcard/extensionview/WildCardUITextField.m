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
#import "JevilInstance.h"
#import "DevilLang.h"

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
            tf.attributedPlaceholder = [[NSAttributedString alloc] initWithString:trans(textSpec[@"text"]) attributes:@{NSForegroundColorAttributeName:[WildCardUtil colorWithHexString:placeHolderTextColor]}];
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
    
    tf.autoComma = NO;
    if(extension[@"select4"] != nil && [@"Y" isEqualToString:extension[@"select4"]]){
        tf.secureTextEntry = YES;
    } else if([@"number" isEqualToString:extension[@"select7"]]){
        tf.keyboardType = UIKeyboardTypeNumberPad;
    } else if([@"number_decimal" isEqualToString:extension[@"select7"]]){
        tf.keyboardType = UIKeyboardTypeDecimalPad;
    } else if([@"number_comma" isEqualToString:extension[@"select7"]]){
        tf.keyboardType = UIKeyboardTypeNumberPad;
        tf.autoComma = YES;
    }
    tf.keypadType = extension[@"select7"];
    
    if(extension[@"select5"] != nil)
    {
        tf.doneClickAction = extension[@"select5"];
    }
    
    if([@"search" isEqualToString:extension[@"select6"]])
        tf.returnKeyType = UIReturnKeySearch;
    else if([@"next" isEqualToString:extension[@"select6"]])
        tf.returnKeyType = UIReturnKeyNext;
    
    tf.delegate = tf;
    
    
    if(extension[@"select13"]) {
        __block NSString* script = extension[@"select13"];
        tf.textChangedCallback = ^(NSString * _Nonnull text) {
            [JevilInstance currentInstance].meta = meta;
            [[JevilInstance currentInstance] pushData];
            
            WildCardTrigger* trigger = [[WildCardTrigger alloc] init];
            [WildCardAction execute:trigger script:script meta:meta];
        };
    }
    
    if(extension[@"select14"]) {
        __block NSString* script = extension[@"select14"];
        tf.textFocusChangedCallback = ^(BOOL focus) {
            [JevilInstance currentInstance].meta = meta;
            [[JevilInstance currentInstance] pushData];
            
            WildCardTrigger* trigger = [[WildCardTrigger alloc] init];
            [WildCardAction execute:trigger script:script meta:meta];
        };
    }
    
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
        if([self.doneClickAction hasPrefix:@"Jevil.script"]) {
            WildCardTrigger* trigger = [[WildCardTrigger alloc] init];
            trigger.node = (WildCardUIView*)[self superview];
            [WildCardAction parseAndConducts:trigger action:self.doneClickAction meta:self.meta];
        } else {
            WildCardTrigger* trigger = [[WildCardTrigger alloc] init];
            trigger.node = (WildCardUIView*)[self superview];
            [WildCardAction execute:trigger script:self.doneClickAction meta:self.meta];
        }
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
    
    if(_autoComma) {
        NSString* text = [self.text stringByReplacingOccurrencesOfString:@"," withString:@""];
        self.text = [self formatString:text];
    }
    
    _meta.correspondData[_holder] = self.text;
    
    if(self.textChangedCallback != nil && ![[textField text] isEqualToString:self.lastText]) {
        self.lastText = [textField text];
        self.textChangedCallback([textField text]);
    }
}

-(NSString*) formatString:(NSString*)input {
    int chunkSize = 3;
    const char *cStr = [input UTF8String];
    int length = (int)strlen(cStr);
    
    // 0이 아닌 문자가 처음으로 나오는 인덱스 찾기
    int nonZeroIndex = 0;
    while (nonZeroIndex < length && cStr[nonZeroIndex] == '0') {
        nonZeroIndex++;
    }
    
    // 앞의 0을 제외한 부분을 NSString으로 변환
    NSString *result = [NSString stringWithUTF8String:&cStr[nonZeroIndex]];
    
    // 3글자마다 콤마 추가
    NSMutableString *formatted = [NSMutableString string];
    int count = 0;
    for (int i = 0; i < result.length; i++) {
        [formatted appendFormat:@"%c", [result characterAtIndex:i]];
        count++;
        if (count == chunkSize && i < result.length - 1) {
            [formatted appendString:@","];
            count = 0;
        }
    }
    
    return formatted;
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

- (BOOL)textField:(UITextField *)textField shouldChangeCharactersInRange:(NSRange)range replacementString:(NSString *)text
{
    if(self.maxLength == -1)
        return true;
    else if(range.location == self.maxLength-1)
        return true;
    else if(self.maxLength > 0 && [self.text length] < self.maxLength)
        return true;
    else
        return false;
    
}

- (BOOL)textFieldShouldEndEditing:(UITextField *)textField
{
    _meta.correspondData[_holder] = [textField text];
    return YES;
}

- (void)textFieldDidBeginEditing:(UITextField *)textField{
    if(self.textFocusChangedCallback != nil) {
        self.textFocusChangedCallback(true);
    }
}

- (void)textFieldDidEndEditing:(UITextField *)textField
{
    _meta.correspondData[_holder] = [textField text];
    if(self.textFocusChangedCallback != nil) {
        self.textFocusChangedCallback(false);
    }
}


- (void)touchesBegan:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event
{
    NSLog(@"touches begin - TextField input");
}

@end
