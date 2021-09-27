//
//  WildCardExtensionConstructor.m
//  CloudJsonViewer
//
//  Created by Mu Young Ko on 2018. 10. 15..
//  Copyright © 2018년 Mu Young Ko. All rights reserved.
//

#import "WildCardExtensionConstructor.h"
#import "ReplaceRuleExtension.h"
#import "WildCardConstructor.h"
#import "MappingSyntaxInterpreter.h"
#import "WildCardCollectionViewAdapter.h"
#import "WildCardLCAnimatedPageControl.h"
#import "WildCardUtil.h"
#import "WildCardUITapGestureRecognizer.h"
#import "WildCardUITextField.h"
#import "WildCardUITextView.h"

@implementation WildCardExtensionConstructor

+(int)fromString:(NSString*)type
{
    static NSMutableDictionary* typeMap = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        typeMap = [[NSMutableDictionary alloc] init];
        [typeMap setObject:[NSNumber numberWithInt:WILDCARD_EXTENSION_TYPE_BILL_BOARD_PAGER] forKey:@"billboardpager"];
        [typeMap setObject:[NSNumber numberWithInt:WILDCARD_EXTENSION_TYPE_CUSTOM] forKey:@"custom"];
        [typeMap setObject:[NSNumber numberWithInt:WILDCARD_EXTENSION_TYPE_STAR_RATING] forKey:@"starRating"];
        [typeMap setObject:[NSNumber numberWithInt:WILDCARD_EXTENSION_TYPE_INPUT] forKey:@"input"];
        [typeMap setObject:[NSNumber numberWithInt:WILDCARD_EXTENSION_TYPE_CHEKBOX] forKey:@"checkbox"];
        [typeMap setObject:[NSNumber numberWithInt:WILDCARD_EXTENSION_TYPE_PROGRESS_BAR] forKey:@"progressBar"];
    });
    
    NSNumber* n = [typeMap objectForKey:type];
    if(n == nil)
        return WILDCARD_EXTENSION_TYPE_UNDIFINED;
    else
        return [n intValue];
}

+(int)getExtensionType:(NSDictionary*)extension
{
    int type = [WildCardExtensionConstructor fromString:extension[@"type"]];
    return type;
}

+(UIView*)construct:(UIView*)extensionContainer : (NSDictionary*)layer  :(WildCardMeta*) meta
{
    NSDictionary* extension = [layer objectForKey:@"extension"];
    int type = [WildCardExtensionConstructor fromString:extension[@"type"]];
    switch (type) {
        case WILDCARD_EXTENSION_TYPE_CUSTOM:
        {
            UIView* customExtensionView = [[WildCardConstructor sharedInstance].delegate onCustomExtensionCreate:meta extensionLayer:extension];
            return customExtensionView;
            break;
        }
        case WILDCARD_EXTENSION_TYPE_CHEKBOX:
        {
            return nil;
            break;
        }
        case WILDCARD_EXTENSION_TYPE_PROGRESS_BAR:
        {
            return nil;
            break;
        }
        case WILDCARD_EXTENSION_TYPE_INPUT:
        {
            if([@"multiline" isEqualToString:extension[@"select7"]]){
                WildCardUITextView *r = [WildCardUITextView create:layer meta:meta];
                return r;
            } else {
                return [WildCardUITextField create:layer meta:meta];
            }
            
            break;
        }
        case WILDCARD_EXTENSION_TYPE_BILL_BOARD_PAGER:
        {
            NSString* viewPagerNodeName = extension[@"select3"];
            
            int circleSize = [extension[@"select4"] intValue];
            int circleDistance = [extension[@"select5"] intValue];
            NSString* activeCircleColor = extension[@"select6"];
            NSString* inactiveCircleInnerColor = extension[@"select7"];
            NSString* inactiveCircleBorderColor = extension[@"select8"];
            
            
            UIPageControl* pc = [[UIPageControl alloc] initWithFrame:CGRectMake(0, 0, extensionContainer.frame.size.width, extensionContainer.frame.size.height)];
            if(inactiveCircleBorderColor)
                pc.pageIndicatorTintColor = [WildCardUtil colorWithHexString:inactiveCircleBorderColor];
            else
                pc.pageIndicatorTintColor = [UIColor lightGrayColor];
            
            if(activeCircleColor)
                pc.currentPageIndicatorTintColor = [WildCardUtil colorWithHexString:activeCircleColor];
            else
                pc.pageIndicatorTintColor = [UIColor grayColor];

            return pc;
            break;
        }
    }
    
    return nil;
}

+(void)update:(WildCardMeta*) meta extensionRule:(ReplaceRuleExtension*)rule data:(NSMutableDictionary*)opt
{
    NSMutableDictionary* layer = rule.replaceJsonLayer;
    NSMutableDictionary* extension = layer[@"extension"];
    NSString* typeStr = extension[@"type"];
    int type = [WildCardExtensionConstructor fromString:typeStr];
    NSString* name = layer[@"name"];
    switch (type) {
        case WILDCARD_EXTENSION_TYPE_CUSTOM:
        {
            [[WildCardConstructor sharedInstance].delegate onCustomExtensionUpdate:rule.replaceView meta:meta extensionLayer:extension data:opt];
            break;
        }
        case WILDCARD_EXTENSION_TYPE_BILL_BOARD_PAGER:
        {
            NSString* viewPagerNodeName = extension[@"select3"];
            WildCardUIView* vv = meta.generatedViews[viewPagerNodeName];
            if(vv != nil && [[vv subviews] count] > 0)
            {
                UICollectionView* cv = [vv subviews][0];
                WildCardCollectionViewAdapter* adapter = (WildCardCollectionViewAdapter*)cv.delegate;
                adapter.pageControl = [[rule.replaceView subviews] objectAtIndex:0];
                adapter.pageControl.numberOfPages = [adapter.data count];
                if([adapter.data count] == 1)
                    adapter.pageControl.hidden = YES;
                else
                    adapter.pageControl.hidden = NO;
                [adapter addViewPagerSelected:^(int index) {
                    adapter.pageControl.currentPage = index;
                }];
                
            }
            
            break;
        }
        case WILDCARD_EXTENSION_TYPE_INPUT:
        {
            if([[[rule.replaceView subviews][0] class] isEqual:[WildCardUITextView class]]){
                WildCardUITextView* tf = (WildCardUITextView*)[rule.replaceView subviews][0];
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
            WildCardUITextField* dt = (WildCardUITextField*)[rule.replaceView subviews][0];
            NSString* select3 = extension[@"select3"];
            NSString* text = @"";
            if(opt[select3] != nil && opt[select3] != [NSNull null])
                text = [NSString stringWithFormat:@"%@", opt[select3]]; //숫자가 나올때가 있다
            if(![dt.text isEqualToString:text])
                dt.text = text;
            break;
        }
        case WILDCARD_EXTENSION_TYPE_STAR_RATING:
        {
            
            break;
        }
        case WILDCARD_EXTENSION_TYPE_PROGRESS_BAR:
        {
            NSString* barBgNodeName = extension[@"select3"];
            NSString* watch = extension[@"select4"];
            UIView* barBg = [meta getView:barBgNodeName];
            int rate  = [meta.correspondData[watch] intValue];
            float barBgWidth = barBg.frame.size.width;
            rule.replaceView.frame = CGRectMake(rule.replaceView.frame.origin.x, rule.replaceView.frame.origin.y,
                                                barBgWidth*rate/100.0f, rule.replaceView.frame.size.height);
            break;
        }
        case WILDCARD_EXTENSION_TYPE_CHEKBOX:
        {
            NSString* onNodeName = extension[@"select3"];
            NSString* offNodeName = extension[@"select4"];
            NSString* watch = extension[@"select5"];
            NSString* onValue = extension[@"select6"];
            NSString* defaultOnOff = extension[@"select7"];
            WildCardUIView* onNodeView = meta.generatedViews[onNodeName];
            WildCardUIView* offNodeView = meta.generatedViews[offNodeName];
            
            if(!rule.constructed)
            {
                rule.constructed = YES;
                rule.replaceView.userInteractionEnabled = YES;
                
                WildCardUITapGestureRecognizer *singleFingerTap =
                [[WildCardUITapGestureRecognizer alloc] initWithTarget:[WildCardConstructor sharedInstance]
                                                                action:@selector(onExtensionCheckBoxClickListener:)];
                singleFingerTap.meta = meta;
                singleFingerTap.nodeName = ((WildCardUIView*)rule.replaceView).name;
                singleFingerTap.extensionForCheckBox = extension;
                singleFingerTap.rule = rule;
                [rule.replaceView addGestureRecognizer:singleFingerTap];
            }
            
            
            BOOL check = YES;
            if(meta.correspondData[watch] == nil)
            {
                if([@"Y" isEqualToString:defaultOnOff])
                    check = YES;
                else
                    check = NO;
            }
            else if([meta.correspondData[watch] isEqualToString:onValue])
            {
                check = YES;
            }
            else
            {
                check = NO;
            }
            
            rule.replaceView.isAccessibilityElement = YES;
            rule.replaceView.accessibilityTraits = UIAccessibilityTraitButton;
            rule.replaceView.accessibilityLabel = [NSString stringWithFormat:@"%@ %@", layer[@"name"], check?@"선택됨":@"선택안됨"];
            if(check)
            {
                onNodeView.hidden = NO;
                offNodeView.hidden = YES;
                
                meta.correspondData[watch] = onValue;
            }
            else
            {
                onNodeView.hidden = YES;
                offNodeView.hidden = NO;
                
                meta.correspondData[watch] = @"N";
            }
            
            
            break;
        }
    }
}
@end
