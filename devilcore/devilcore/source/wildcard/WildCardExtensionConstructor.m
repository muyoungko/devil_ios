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
#import "WildCardUIPageControl.h"
#import "JevilInstance.h"
#import "JevilCtx.h"
#import "WildCardProgressBar.h"
#import "WildCardUILabel.h"

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
            NSString* type = extension[@"select9"];
            
            if([@"number" isEqualToString:type]) {
                UIView* vv = extensionContainer;
                WildCardUILabel* tv = [[WildCardUILabel alloc] init];
                [vv addSubview:tv];
                
                tv.frame = CGRectMake(0, 0, vv.frame.size.width, vv.frame.size.height);
                tv.lineBreakMode = NSLineBreakByTruncatingTail;
                
                NSDictionary* textSpec = [layer objectForKey:@"textSpec"];
                
                if([[textSpec objectForKey:@"stroke"] boolValue])
                    tv.stroke = YES;
                else
                    tv.stroke = NO;
                
                int halignment = 1;
                int valignment = 0;
                if([textSpec objectForKey:@"alignment"] != nil)
                    halignment = [[textSpec objectForKey:@"alignment"] intValue];
                if([textSpec objectForKey:@"valignment"] != nil)
                    valignment = [[textSpec objectForKey:@"valignment"] intValue];
                
                if(halignment == 3)
                    halignment = GRAVITY_LEFT;
                else if(halignment == 17)
                    halignment = GRAVITY_HORIZONTAL_CENTER;
                else if(halignment == 5)
                    halignment = GRAVITY_RIGHT;
                
                if(valignment == 0) {
                    valignment = GRAVITY_TOP;
                }
                else if(valignment == 1) {
                    valignment = GRAVITY_VERTICAL_CENTER;
                }
                else if(valignment == 2) {
                    valignment = GRAVITY_BOTTOM;
                }
                
                tv.alignment = halignment | valignment;
                
                if([WildCardUtil hasGravityCenterHorizontal:tv.alignment])
                    tv.textAlignment = NSTextAlignmentCenter;
                else if([WildCardUtil hasGravityRight:tv.alignment])
                    tv.textAlignment = NSTextAlignmentRight;
                
                
                float textSize = [WildCardConstructor convertTextSize:[[textSpec objectForKey:@"textSize"] floatValue]];
                
                if([[textSpec objectForKey:@"bold"] boolValue])
                {
                    tv.font = [UIFont boldSystemFontOfSize:textSize];
                }
                else
                {
                    tv.font = [UIFont systemFontOfSize:textSize];
                }
                tv.textColor = [WildCardUtil colorWithHexString:[textSpec objectForKey:@"textColor"]];
                return tv;
            } else {
                WildCardUIPageControl* pc = [[WildCardUIPageControl alloc] initWithFrame:CGRectMake(0, 0, extensionContainer.frame.size.width, extensionContainer.frame.size.height)];
                if(inactiveCircleBorderColor)
                    pc.pageIndicatorTintColor = [WildCardUtil colorWithHexString:inactiveCircleBorderColor];
                else
                    pc.pageIndicatorTintColor = [UIColor lightGrayColor];
                
                if(activeCircleColor)
                    pc.currentPageIndicatorTintColor = [WildCardUtil colorWithHexString:activeCircleColor];
                else
                    pc.pageIndicatorTintColor = [UIColor grayColor];
                pc.meta = meta;
                pc.viewPagerNodeName = viewPagerNodeName;
                [pc addTarget:[WildCardConstructor sharedInstance] action:@selector(onExtensionPageControlClickListener:) forControlEvents:UIControlEventValueChanged];
                
                return pc;
            }
            
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
            NSString* type = extension[@"select9"];
            WildCardUIView* vv = meta.generatedViews[viewPagerNodeName];
            if(vv != nil && [[vv subviews] count] > 0)
            {
                UICollectionView* cv = [vv subviews][0];
                WildCardCollectionViewAdapter* adapter = (WildCardCollectionViewAdapter*)cv.delegate;
                if([@"number" isEqualToString:type]) {
                    UILabel *label = [rule.replaceView subviews][0];
                    label.text = [NSString stringWithFormat:@"%d / %d", 1, (int)[adapter getCount]];
                    rule.replaceView.hidden = [adapter getCount] <= 1;
                    [adapter addViewPagerSelected:^(int index) {
                        UILabel *label = [rule.replaceView subviews][0];
                        label.text = [NSString stringWithFormat:@"%d / %d", (index)+1, (int)[adapter getCount]];
                    }];
                } else {
                    adapter.pageControl = [[rule.replaceView subviews] objectAtIndex:0];
                    adapter.pageControl.numberOfPages = [adapter getCount];
                    if([adapter getCount] == 1)
                        adapter.pageControl.hidden = YES;
                    else
                        adapter.pageControl.hidden = NO;
                    [adapter addViewPagerSelected:^(int index) {
                        adapter.pageControl.currentPage = index;
                    }];
                }
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
            if(![opt[select3] isUndefined] && ![opt[select3] isNull])
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
            __block NSString* watch = extension[@"select4"];
            NSString* cap = extension[@"select5"];
            WildCardUIView* barBg = (WildCardUIView*)[meta getView:barBgNodeName];
            __block BOOL dragable = [@"Y" isEqualToString:extension[@"select6"]];
            __block BOOL vertical = [@"Y" isEqualToString:extension[@"select8"]];
            
            if(!rule.constructed) {
                rule.constructed = YES;
                
                WildCardProgressBar* barController = [[WildCardProgressBar alloc] init];
                meta.forRetain[@"progress_key"] = barController;
                barController.dragable = dragable;
                barController.vertical = vertical;
                barController.meta = meta;
                barController.progressGroup = (WildCardUIView*)[barBg superview];
                if(cap)
                    barController.cap = (WildCardUIView*)[meta getView:cap];
                barController.bar = (WildCardUIView*)rule.replaceView;
                barController.bar_bg = barBg;
                barController.watch = watch;
                barController.dragUpScript = extension[@"select7"];
                barController.moveScript = extension[@"select9"];
                [barController construct];
            }
            
            WildCardProgressBar* barController = meta.forRetain[@"progress_key"];
             
            if(rule.constructed && barController.moving) {
                return;
            }
            
            [barController update];
            
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
            if(![meta.correspondData hasProperty:watch])
            {
                if([@"Y" isEqualToString:defaultOnOff])
                    check = YES;
                else
                    check = NO;
            }
            else if([[meta.correspondData[watch] toString] isEqualToString:onValue])
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
