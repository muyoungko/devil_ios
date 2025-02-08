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
#import "JevilInstance.h"
#import "DevilController.h"
#import "DevilLang.h"

#define SYSTEM_VERSION_EQUAL_TO(v)                  ([[[UIDevice currentDevice] systemVersion] compare:v options:NSNumericSearch] == NSOrderedSame)
#define SYSTEM_VERSION_GREATER_THAN(v)              ([[[UIDevice currentDevice] systemVersion] compare:v options:NSNumericSearch] == NSOrderedDescending)
#define SYSTEM_VERSION_GREATER_THAN_OR_EQUAL_TO(v)  ([[[UIDevice currentDevice] systemVersion] compare:v options:NSNumericSearch] != NSOrderedAscending)
#define SYSTEM_VERSION_LESS_THAN(v)                 ([[[UIDevice currentDevice] systemVersion] compare:v options:NSNumericSearch] == NSOrderedAscending)
#define SYSTEM_VERSION_LESS_THAN_OR_EQUAL_TO(v)     ([[[UIDevice currentDevice] systemVersion] compare:v options:NSNumericSearch] != NSOrderedDescending)

@interface WildCardUITextView()
@property (nonatomic, retain) NSString* lastText;
@end

@implementation WildCardUITextView

+(WildCardUITextView*)create:(id)layer meta:(WildCardMeta*)meta {
    NSDictionary* extension = [layer objectForKey:@"extension"];
    if(extension == nil)
        extension = [layer objectForKey:@"input"];
    
    WildCardUITextView* tf = [[WildCardUITextView alloc] init];
    tf.backgroundColor = [UIColor clearColor];
    NSMutableDictionary* textSpec = [layer objectForKey:@"textSpec"];
    if(textSpec != nil)
    {
        float sketchTextSize = [[textSpec objectForKey:@"textSize"] floatValue];
        float textSize = [WildCardConstructor convertTextSize:sketchTextSize];
        tf.font = [UIFont systemFontOfSize:textSize];
        tf.originalTextColor = tf.textColor = [WildCardUtil colorWithHexString:[textSpec objectForKey:@"textColor"]];
        tf.emtpy = true;
        
        NSString* text = [textSpec objectForKey:@"text"];
        if([WildCardConstructor sharedInstance].textTransDelegate != nil )
            text = [[WildCardConstructor sharedInstance].textTransDelegate translateLanguage:text];
        tf.placeholderText = trans(text);
        
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
            tf.verticalAlignTop = true;
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
    } else if([@"number_decimal" isEqualToString:extension[@"select7"]]){
        tf.keyboardType = UIKeyboardTypeDecimalPad;
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
    
    if(extension[@"select8"] != nil) {
        tf.maxLine = [extension[@"select8"] intValue];
    } else
        tf.maxLine = 1;
    
    tf.minHeight = [WildCardConstructor getFrame:layer:nil].size.height;
    tf.variableHeight = [extension[@"select10"] isEqualToString:@"Y"];
    
    NSString *placeHolderTextColor = @"#aaaaaa";
    if(extension[@"select9"] != nil)
        placeHolderTextColor = extension[@"select9"];
    
    if(SYSTEM_VERSION_GREATER_THAN_OR_EQUAL_TO(@"13.0"))
        [tf setValue:[WildCardUtil colorWithHexString:placeHolderTextColor] forKeyPath:@"_placeholderLabel.textColor"];
    else
        [tf setValue:[WildCardUtil colorWithHexString:placeHolderTextColor] forKeyPath:@"_placeholderLabel.textColor"];
    
    CGRect rect = [WildCardUtil getTextSize:@"sample text" font:tf.font maxWidth:200 maxHeight:CGFLOAT_MAX];
    tf.lineHeight = rect.size.height;
    
    /**
     한줄부터 variable하게 높이가 결정되는 멀티라인 텍스트는 다음과 같이 top패딩을구하여 vcenter를 맞춘다.
     그런데 이미 여러줄이 상태에서 위에서 부터 쌓이는 텍스트 인풋은 topInset이 거의 없어야한다
     즉 valign이 필요하다
     */
    if(tf.verticalAlignTop == NO)
        tf.topInset = tf.minHeight/2-tf.lineHeight/2;
    tf.textContainerInset = UIEdgeInsetsMake(tf.topInset, 0, 0, 0);
    
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
    self.emtpy = YES;
    self.xbuttonImageName = nil;
    self.doneClickAction = nil;
    [[NSNotificationCenter defaultCenter] addObserver:self
                                          selector:@selector(textChanged:)
                                          name:UITextViewTextDidChangeNotification
                                          object:nil];
    return self;
}

- (void)updatePlaceHolderVisible {
    if(self.placeholderLabel != nil){
        if(self.text == nil || [@"" isEqualToString:self.text])
            self.placeholderLabel.hidden = NO;
        else
            self.placeholderLabel.hidden = YES;
    }
}

- (void)setText:(NSString *)text{
    [super setText:text];
    [self updatePlaceHolderVisible];
    [self updateHeight];
}

- (void)textViewDidBeginEditing:(UITextView *)textView{
    if(self.placeholderLabel != nil){
        self.placeholderLabel.hidden = YES;
    }
    
    if(self.textFocusChangedCallback != nil) {
        self.textFocusChangedCallback(true);
    }
}

- (void)textViewDidEndEditing:(UITextView *)textView{
    _meta.correspondData[_holder] = [textView text];
    [self updatePlaceHolderVisible];
    
    if(self.textFocusChangedCallback != nil) {
        self.textFocusChangedCallback(false);
    }
}

- (void)textViewDidChange:(UITextView *)textView{
    _meta.correspondData[_holder] = [textView text];
    [self updatePlaceHolderVisible];
}

- (BOOL)textView:(UITextView *)textView shouldChangeTextInRange:(NSRange)range replacementText:(NSString *)text {
    if([text length] > 0 && [text characterAtIndex:0] == '\n') {
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
            
            _meta.correspondData[_holder] = @"";
        }
    }
    return YES;
}

- (void)updateHeight {
    if(self.variableHeight) {
        id lines = [self.text componentsSeparatedByString:@"\n"];
        int len = (int)[lines count];
        if(len > self.maxLine)
            len = self.maxLine;
        
        float h = len*self.lineHeight + self.topInset;
        if(h < self.minHeight)
            h = self.minHeight;
        
        self.frame = CGRectMake(self.frame.origin.x, self.frame.origin.y,
                                          self.frame.size.width, h);
        
        self.superview.frame = CGRectMake(self.superview.frame.origin.x, self.superview.frame.origin.y,
                                          self.superview.frame.size.width, h);
        [self.meta requestLayout];
        DevilController* vc = (DevilController*)[JevilInstance currentInstance].vc;
        [vc adjustFooterHeight];
        [vc adjustFooterPositionOnKeyboard];
    }
}

- (void)textChanged:(UITextField *)textField{
    _meta.correspondData[_holder] = self.text;
    [self updateHeight];
    
    if(self.textChangedCallback != nil && ![self.text isEqualToString:self.lastText]) {
        self.lastText = self.text;
        self.textChangedCallback(self.text);
    }
}




@end
