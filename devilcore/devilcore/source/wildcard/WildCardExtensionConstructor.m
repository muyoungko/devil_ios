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

#define SYSTEM_VERSION_EQUAL_TO(v)                  ([[[UIDevice currentDevice] systemVersion] compare:v options:NSNumericSearch] == NSOrderedSame)
#define SYSTEM_VERSION_GREATER_THAN(v)              ([[[UIDevice currentDevice] systemVersion] compare:v options:NSNumericSearch] == NSOrderedDescending)
#define SYSTEM_VERSION_GREATER_THAN_OR_EQUAL_TO(v)  ([[[UIDevice currentDevice] systemVersion] compare:v options:NSNumericSearch] != NSOrderedAscending)
#define SYSTEM_VERSION_LESS_THAN(v)                 ([[[UIDevice currentDevice] systemVersion] compare:v options:NSNumericSearch] == NSOrderedAscending)
#define SYSTEM_VERSION_LESS_THAN_OR_EQUAL_TO(v)     ([[[UIDevice currentDevice] systemVersion] compare:v options:NSNumericSearch] != NSOrderedDescending)


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
            
            tf.delegate = tf;
            
            return tf;
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
                [adapter addViewPagerSelected:^(int index) {
                    adapter.pageControl.currentPage = index;
                }];
                
            }
            
            break;
        }
        case WILDCARD_EXTENSION_TYPE_INPUT:
        {
            WildCardUITextField* dt = (WildCardUITextField*)[rule.replaceView subviews][0];
            NSString* select3 = extension[@"select3"];
            dt.text = opt[select3];
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
