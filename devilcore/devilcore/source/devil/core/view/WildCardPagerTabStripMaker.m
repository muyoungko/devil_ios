//
//  WildCardPagerTabStripMaker.m
//  devilcore
//
//  Created by Mu Young Ko on 2021/01/23.
//

#import "WildCardPagerTabStripMaker.h"
#import "MappingSyntaxInterpreter.h"
#import "WildCardConstructor.h"
#import "WildCardUIView.h"
#import "WildCardUtil.h"

@implementation WildCardPagerTabStripMaker

+(WildCardPagerTabStrip*)construct:(id)layer :(UIView*)vv{
    
    UICollectionViewFlowLayout *flowLayout = [[UICollectionViewFlowLayout alloc] init];
    flowLayout.scrollDirection = UICollectionViewScrollDirectionHorizontal;
    flowLayout.sectionInset = UIEdgeInsetsMake(0, 0, 0, 0);
    
    WildCardPagerTabStrip* strip = [[WildCardPagerTabStrip alloc] initWithFrame:CGRectMake(0, 0,
                                                                                           vv.frame.size.width,
                                                                                           vv.frame.size.height) collectionViewLayout:flowLayout];
    
    id stripLayer = layer[@"strip"];
    NSString* offnodeName = stripLayer[@"offnode"];
    NSString* onnodeName = stripLayer[@"onnode"];
    NSString* underlineName = stripLayer[@"underline"];
    id offnode = [self getChildLayer:layer :offnodeName];
    if(offnode != nil) {
        id offnodeText = [self getChildLayerByClass:offnode:@"text"];
        if(offnodeText != nil){
            id textSpec = offnodeText[@"textSpec"];
            float textSize = [WildCardConstructor convertTextSize:[textSpec[@"textSize"] floatValue]];
            if([WildCardConstructor sharedInstance].textConvertDelegate) {
                textSize = [[WildCardConstructor sharedInstance].textConvertDelegate convertTextSize:[textSpec[@"textSize"] floatValue]];
            }
            strip.textSize = textSize;
            strip.textColor = [WildCardUtil colorWithHexString:[textSpec objectForKey:@"textColor"]];
        }
    }
    
    id onnode = [self getChildLayer:layer :onnodeName];
    if(onnode != nil) {
        id onnodeText = [self getChildLayerByClass:onnode:@"text"];
        if(onnodeText != nil){
            id textSpec = onnodeText[@"textSpec"];
            float textSize = [WildCardConstructor convertTextSize:[textSpec[@"textSize"] floatValue]];
            if([WildCardConstructor sharedInstance].textConvertDelegate) {
                textSize = [[WildCardConstructor sharedInstance].textConvertDelegate convertTextSize:[textSpec[@"textSize"] floatValue]];
            }
            strip.selectedTextSize = textSize;
            strip.selectedTextColor = [WildCardUtil colorWithHexString:[textSpec objectForKey:@"textColor"]];
        }
        
        CGRect onnodeRect = [WildCardConstructor getFrame:onnode:nil];
        flowLayout.sectionInset = UIEdgeInsetsMake(0, onnodeRect.origin.x, 0, onnodeRect.origin.x);
    }

    if(onnode != nil){
        id underLine = [self getChildLayer:onnode:underlineName];
        if(underLine != nil){
            UIColor* color = [WildCardUtil colorWithHexString:[underLine objectForKey:@"backgroundColor"]];
            strip.selectedBar.backgroundColor = color;
            CGRect underLineRect = [WildCardConstructor getFrame:underLine:nil];
            strip.selectedBarHeight = underLineRect.size.height;
        }
    }
    
    if([layer objectForKey:@"backgroundColor"])
        strip.backgroundColor = [WildCardUtil colorWithHexString:[layer objectForKey:@"backgroundColor"]];
    else
        strip.backgroundColor = [UIColor clearColor];
    strip.allowsSelection = YES;
    strip.allowsMultipleSelection = NO;
    strip.leftRightMargin = 10;
    strip.scrollsToTop = NO;
    strip.showsHorizontalScrollIndicator = NO;
    
    return strip;
}

+(id)getChildLayer:(id)layer:(NSString*)name {
    id layers = layer[@"layers"];
    for(int i=0;i<[layers count];i++){
        id child = layers[i];
        NSString* childName = child[@"name"];
        if([childName isEqualToString:name]){
            return child;
        }
    }
    return nil;
}

+(id)getChildLayerByClass:(id)layer:(NSString*)_class {
    id layers = layer[@"layers"];
    for(int i=0;i<[layers count];i++){
        id child = layers[i];
        NSString* childName = child[@"_class"];
        if([childName isEqualToString:_class]){
            return child;
        }
    }
    return nil;
}

+(void)update:(ReplaceRule*)rule :(id)opt{
    WildCardPagerTabStrip* strip = (WildCardPagerTabStrip*) rule.replaceView;
    id stripLayer = rule.replaceJsonLayer[@"strip"];
    NSString* textJson = stripLayer[@"textJson"];
    NSString* listJson = stripLayer[@"listJson"];
    JSValue* list_js = [MappingSyntaxInterpreter getJsonWithPath:opt:listJson];
    strip.list = [[list_js toArray] mutableCopy];
    strip.jsonPath = textJson;
    if([strip.list count] == 0)
        [strip superview].hidden = YES;
    else
        [strip superview].hidden = NO;
    [strip reloadData];
}

@end
