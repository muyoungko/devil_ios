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

@implementation WildCardUITextField

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
- (void)textFieldDidEndEditing:(UITextField *)textField
{
    [_meta.correspondData setObject:[textField text] forKey:_holder];
}

- (void)touchesBegan:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event
{
    NSLog(@"touches begin - TextField input");
}
@end
