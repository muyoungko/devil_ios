//
//  ReplaceRulePageControl.m
//  devilcore
//
//  Created by Mu Young Ko on 2025/04/11.
//

#import "ReplaceRulePageControl.h"
#import "WildCardUILabel.h"
#import "WildCardUIPageControl.h"
#import "WildCardMeta.h"

@implementation ReplaceRulePageControl
- (void)constructRule:(WildCardMeta *)wcMeta parent:(UIView *)parent vv:(WildCardUIView *)vv layer:(id)layer depth:(int)depth result:(id)result{
    self.replaceJsonLayer = layer[@"pagecontrol"];
    self.replaceView = vv;
    
    id extension = self.replaceJsonLayer;
    WildCardMeta* meta = wcMeta;
    
    NSString* viewPagerNodeName = extension[@"select3"];
    
    int circleSize = [extension[@"select4"] intValue];
    int circleDistance = [extension[@"select5"] intValue];
    NSString* activeCircleColor = extension[@"select6"];
    NSString* inactiveCircleInnerColor = extension[@"select7"];
    NSString* inactiveCircleBorderColor = extension[@"select8"];
    NSString* type = extension[@"select9"];
    
    if([@"number" isEqualToString:type]) {
        
    } else {
        WildCardUIPageControl* pc = [[WildCardUIPageControl alloc] initWithFrame:CGRectMake(0, 0, vv.frame.size.width, vv.frame.size.height)];
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
        
        [vv addSubview:pc];
    }
}

-(void)updateRule:(WildCardMeta *)meta data:(id)opt {
    id extension = self.replaceJsonLayer;
    NSString* viewPagerNodeName = extension[@"select3"];
    NSString* type = extension[@"select9"];
    BOOL hiddenWhenOne = [@"Y" isEqualToString:extension[@"select10"]];
    WildCardUIView* vv = meta.generatedViews[viewPagerNodeName];
    
    if(vv != nil && [[vv subviews] count] > 0)
    {
        UICollectionView* cv = [vv subviews][0];
        WildCardCollectionViewAdapter* adapter = (WildCardCollectionViewAdapter*)cv.delegate;
        if([@"number" isEqualToString:type]) {
            UILabel *label = [[self replaceView] subviews][0];
            label.text = [NSString stringWithFormat:@"%d / %d", 1, (int)[adapter getCount]];
            if(hiddenWhenOne)
                self.replaceView.hidden = [adapter getCount] <= 1;
            [adapter addViewPagerSelected:^(int index) {
                UILabel *label = [self.replaceView subviews][0];
                label.text = [NSString stringWithFormat:@"%d / %d", (index)+1, (int)[adapter getCount]];
            }];
        } else {
            adapter.pageControl = [[self.replaceView subviews] objectAtIndex:0];
            adapter.pageControl.numberOfPages = [adapter getCount];
            if(hiddenWhenOne && [adapter getCount] == 1)
                adapter.pageControl.hidden = YES;
            else
                adapter.pageControl.hidden = NO;
            [adapter addViewPagerSelected:^(int index) {
                adapter.pageControl.currentPage = index;
            }];
        }
    }
    
}

@end
