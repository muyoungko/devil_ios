//
//  ReplaceRuleRepeat.m
//  CloudJsonViewer
//
//  Created by Mu Young Ko on 2018. 6. 18..
//  Copyright © 2018년 Mu Young Ko. All rights reserved.
//

#import "ReplaceRuleRepeat.h"
#import "WildCardUtil.h"
#import "MappingSyntaxInterpreter.h"
#import "WildCardConstructor.h"
#import "WildCardCollectionViewAdapter.h"
#import "WildCardGridView.h"
#import "WildCardUIView.h"
#import "WildCardTrigger.h"
#import "WildCardAction.h"
#import <UIKit/UIKit.h>
#import "WildCardUICollectionView.h"
#import "WildCardVideoView.h"
#import "JevilInstance.h"
#import "DevilController.h"

@interface ReplaceRuleRepeat()
@property int tagOffsetX;
@property int tagOffsetY;
@property(nonatomic, retain) UIView* stickyView;
@property int stickyPosition;
@end

@implementation ReplaceRuleRepeat

-(void)constructRule:(WildCardMeta*)wcMeta parent:(UIView*)parent vv:(WildCardUIView*)vv layer:(id)layer depth:(int)depth result:(id)result{
    self.createdRepeatView = [[NSMutableArray alloc] init];
    self.replaceView = vv;
    self.stickyPosition = -1;
    
    id layers = layer[@"layers"];
    NSDictionary* triggerMap = layer[@"trigger"];
    
    NSDictionary* arrayContent = [layer objectForKey:@"arrayContent"];
    NSString* arrayContentTargetNode = [arrayContent objectForKey:@"targetNode"];
    NSString* arrayContentTargetNodeSurfix = [arrayContent objectForKey:@"targetNodeSurfix"];
    NSString* arrayContentTargetNodePrefix = [arrayContent objectForKey:@"targetNodePrefix"];
    NSString* arrayContentTargetNodeSelected = [arrayContent objectForKey:@"targetNodeSelected"];
    NSString* targetNode4 = [arrayContent objectForKey:@"targetNode4"];
    NSString* targetNode5 = [arrayContent objectForKey:@"targetNode5"];
    NSString* targetNode6 = [arrayContent objectForKey:@"targetNode6"];
    NSString* targetNode7 = [arrayContent objectForKey:@"targetNode7"];
    NSString* targetNode8 = [arrayContent objectForKey:@"targetNode8"];
    NSString* targetNode9 = [arrayContent objectForKey:@"targetNode9"];
    NSString* targetNode10 = [arrayContent objectForKey:@"targetNode10"];
    NSString* targetNode11 = [arrayContent objectForKey:@"targetNode11"];
    NSString* targetNode12 = [arrayContent objectForKey:@"targetNode12"];
    
    id shouldContinueChild = [@[] mutableCopy];
    if(arrayContentTargetNode) [shouldContinueChild addObject:arrayContentTargetNode];
    if(arrayContentTargetNodeSurfix) [shouldContinueChild addObject:arrayContentTargetNodeSurfix];
    if(arrayContentTargetNodePrefix) [shouldContinueChild addObject:arrayContentTargetNodePrefix];
    if(arrayContentTargetNodeSelected) [shouldContinueChild addObject:arrayContentTargetNodeSelected];
    if(targetNode4) [shouldContinueChild addObject:targetNode4];
    if(targetNode5) [shouldContinueChild addObject:targetNode5];
    if(targetNode6) [shouldContinueChild addObject:targetNode6];
    if(targetNode7) [shouldContinueChild addObject:targetNode7];
    if(targetNode8) [shouldContinueChild addObject:targetNode8];
    if(targetNode9) [shouldContinueChild addObject:targetNode9];
    if(targetNode10) [shouldContinueChild addObject:targetNode10];
    if(targetNode11) [shouldContinueChild addObject:targetNode11];
    if(targetNode12) [shouldContinueChild addObject:targetNode12];
    
    
    result[@"shouldContinueChild"] = shouldContinueChild;
    
    NSString* repeatType = [arrayContent objectForKey:@"repeatType"];
    self.repeatType = repeatType;
    float margin = 0;
    if([arrayContent objectForKey:@"margin"] != nil)
        margin = [[arrayContent objectForKey:@"margin"] floatValue];
    margin = [WildCardConstructor convertSketchToPixel:margin];
    
    float clipToPadding = 0;
    if([arrayContent objectForKey:@"clipToPadding"] != nil)
        clipToPadding = [[arrayContent objectForKey:@"clipToPadding"] floatValue];
    clipToPadding = [WildCardConstructor convertSketchToPixel:clipToPadding];
    
    id arrayContentContainer = nil;
    NSDictionary* arrayContentTargetLayer = nil;
    for( int i=0;i<[layers count];i++)
    {
        NSString* childName = [[layers objectAtIndex:i] objectForKey:@"name"];
        
        if([childName isEqualToString:arrayContentTargetNode])
        {
            arrayContentTargetLayer = [layers objectAtIndex:i];
            break;
        }
    }
    
    if([REPEAT_TYPE_RIGHT isEqualToString:repeatType])
    {
        int minLeft = 1000000;
        for (int i = 0; layers != nil && i < [layers count]; i++) {
            NSMutableDictionary* childLayer = layers[i];
            NSString* childName = childLayer[@"name"];
            if ([childName isEqualToString:arrayContentTargetNode]
                || [childName isEqualToString:arrayContentTargetNodeSurfix]
                || [childName isEqualToString:arrayContentTargetNodePrefix]
                || [childName isEqualToString:arrayContentTargetNodeSelected]
                )
            {
                CGRect childLayoutParam = [WildCardConstructor getFrame:childLayer :nil];
                if(minLeft > childLayoutParam.origin.x)
                    minLeft = childLayoutParam.origin.x;
            }
        }
        vv.paddingLeft = minLeft;
        vv.wrap_width = YES;
        self.createdContainer = vv;
        vv.userInteractionEnabled = YES;
        [WildCardConstructor userInteractionEnableToParentPath:vv depth:depth];
    }
    else if([REPEAT_TYPE_BOTTOM isEqualToString:repeatType])
    {
        int minTop = 1000000;
        for (int i = 0; layers != nil && i < [layers count]; i++) {
            NSMutableDictionary* childLayer = layers[i];
            NSString* childName = childLayer[@"name"];
            if ([childName isEqualToString:arrayContentTargetNode]
                || [childName isEqualToString:arrayContentTargetNodeSurfix]
                || [childName isEqualToString:arrayContentTargetNodePrefix]
                || [childName isEqualToString:arrayContentTargetNodeSelected]
                )
            {
                CGRect childLayoutParam = [WildCardConstructor getFrame:childLayer :nil];
                if(minTop > childLayoutParam.origin.y)
                    minTop = childLayoutParam.origin.y;
            }
        }
        vv.paddingTop = minTop;
        vv.wrap_height = YES;
        self.createdContainer = vv;
        vv.userInteractionEnabled = YES;
        [WildCardConstructor userInteractionEnableToParentPath:vv depth:depth];
    }
    else if([REPEAT_TYPE_GRID isEqualToString:repeatType])
    {
        CGRect containerRect = [WildCardConstructor getFrame:layer:parent];
        containerRect.origin.x = containerRect.origin.y = 0;
        WildCardGridView* container = [[WildCardGridView alloc] initWithFrame:containerRect];
        container.meta = wcMeta;
        container.depth = depth;
        arrayContentContainer = self.createdContainer = container;
        
        vv.userInteractionEnabled = YES;
        [WildCardConstructor userInteractionEnableToParentPath:vv depth:depth];
        
        BOOL innerLine = [@"Y" isEqualToString:[arrayContent objectForKey:@"innerLine"]];
        [container setInnerLine:innerLine];
        
        BOOL outerLine = [@"Y" isEqualToString:[arrayContent objectForKey:@"outerLine"]];
        [container setOuterLine:outerLine];
        
        if(arrayContent[@"lineColor"])
            container.lineColor =[WildCardUtil colorWithHexString:arrayContent[@"lineColor"]];
    }
    else if([REPEAT_TYPE_VIEWPAGER isEqualToString:repeatType])
    {
        UICollectionViewFlowLayout* flowLayout = [[UICollectionViewFlowLayout alloc] init];
        flowLayout.itemSize = CGSizeMake(100, 100);
        [flowLayout setScrollDirection:UICollectionViewScrollDirectionHorizontal];
        
        CGRect containerRect = [WildCardConstructor getFrame:layer:parent];
        containerRect.origin.x = containerRect.origin.y = 0;
        
        UICollectionView *container = [[UICollectionView alloc] initWithFrame:containerRect collectionViewLayout:flowLayout];
        [container registerClass:[UICollectionViewCell class] forCellWithReuseIdentifier:@"0"];
        [container registerClass:[UICollectionViewCell class] forCellWithReuseIdentifier:@"1"];
        [container registerClass:[UICollectionViewCell class] forCellWithReuseIdentifier:@"2"];
        [container registerClass:[UICollectionViewCell class] forCellWithReuseIdentifier:@"3"];
        [container registerClass:[UICollectionViewCell class] forCellWithReuseIdentifier:@"4"];
        [container registerClass:[UICollectionViewCell class] forCellWithReuseIdentifier:@"5"];
        [container registerClass:[UICollectionViewCell class] forCellWithReuseIdentifier:@"6"];
        [container registerClass:[UICollectionViewCell class] forCellWithReuseIdentifier:@"7"];
        [container registerClass:[UICollectionViewCell class] forCellWithReuseIdentifier:@"8"];
        [container registerClass:[UICollectionViewCell class] forCellWithReuseIdentifier:@"9"];
        [container registerClass:[UICollectionViewCell class] forCellWithReuseIdentifier:@"10"];
        [container registerClass:[UICollectionViewCell class] forCellWithReuseIdentifier:@"11"];
        [container registerClass:[UICollectionViewCell class] forCellWithReuseIdentifier:@"12"];
        [container registerClass:[UICollectionViewCell class] forCellWithReuseIdentifier:@"FOOTER"];
        
        //container.pagingEnabled = YES;
        
        [container setShowsHorizontalScrollIndicator:NO];
        [container setShowsVerticalScrollIndicator:NO];
        container.backgroundColor = [UIColor clearColor];
        WildCardCollectionViewAdapter* adapter = [[WildCardCollectionViewAdapter alloc] init];
        adapter.infinite = [@"Y" isEqualToString:arrayContent[@"infinite"]];
        adapter.collectionView = container;
        
        NSString* arrayContentTargetNode = [arrayContent objectForKey:@"targetNode"];
        for (int i = 0; layers != nil && i < [layers count]; i++) {
            NSMutableDictionary* childLayer = layers[i];
            NSString* childName = childLayer[@"name"];
            if ([childName isEqualToString:arrayContentTargetNode]){
                CGRect firstChildRect = [WildCardConstructor getFrame:layers[i]:vv];
                adapter.viewPagerContentWidth = firstChildRect.size.width;
                adapter.viewPagerStartPaddingX = firstChildRect.origin.x;
                break;
            }
        }
        
        adapter.repeatType = repeatType;
        adapter.margin = margin;
        container.contentInset = UIEdgeInsetsMake(0, adapter.viewPagerStartPaddingX, 0, adapter.viewPagerStartPaddingX);
        adapter.meta = wcMeta;
        adapter.depth = depth;
        self.adapterForRetain = adapter;
        container.delegate = adapter;
        container.dataSource = adapter;
        
        if(triggerMap != nil && triggerMap[WILDCARD_VIEW_PAGER_CHANGED] != nil) {
            
            WildCardTrigger* trigger = [[WildCardTrigger alloc] initWithType:WILDCARD_VIEW_PAGER_CHANGED nodeName:vv.name node:vv];
            NSMutableArray* actions = triggerMap[WILDCARD_VIEW_PAGER_CHANGED];
            for(int i=0;i<[actions count];i++)
                [trigger addAction:[WildCardAction parse:wcMeta action:actions[i]]];
            [wcMeta addTriggerAction:trigger];
        }
        
        [adapter addViewPagerSelected:^(int position) {
            for(int i=0;i<[adapter getCount];i++)
            {
                if(i==position)
                    adapter.data[i][WC_SELECTED] = @"Y";
                else
                    adapter.data[i][WC_SELECTED] = @"N";
            }
            
            [wcMeta doAllActionOfTrigger:WILDCARD_VIEW_PAGER_CHANGED node:vv.name];
            
            dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.3 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
                [WildCardVideoView autoPlay];
            });
        }];
        
        arrayContentContainer = self.createdContainer = container;
        
        vv.userInteractionEnabled = YES;
        [WildCardConstructor userInteractionEnableToParentPath:vv depth:depth];
    }
    else if([REPEAT_TYPE_HLIST isEqualToString:repeatType] || [REPEAT_TYPE_VLIST isEqualToString:repeatType])
    {
        UICollectionViewFlowLayout* flowLayout = [[UICollectionViewFlowLayout alloc] init];
        flowLayout.itemSize = CGSizeMake(100, 100);
        if([REPEAT_TYPE_HLIST isEqualToString:repeatType])
            [flowLayout setScrollDirection:UICollectionViewScrollDirectionHorizontal];
        else
            [flowLayout setScrollDirection:UICollectionViewScrollDirectionVertical];
         
        CGRect containerRect = [WildCardConstructor getFrame:layer:parent];
        containerRect.origin.x = containerRect.origin.y = 0;
        
        WildCardUICollectionView *container = [[WildCardUICollectionView alloc] initWithFrame:containerRect collectionViewLayout:flowLayout];
        
        NSString* pullToRefresh = [arrayContent objectForKey:@"pullToRefresh"];
        NSString* pullToRefreshJavascript = [arrayContent objectForKey:@"pullToRefreshJavascript"];
        if([@"Y" isEqualToString:pullToRefresh]) {
            UIRefreshControl* refreshControl = [[UIRefreshControl alloc] init];
            container.refreshControl = refreshControl;
            self.pullToRefreshJavascript = pullToRefreshJavascript;
            [container.refreshControl addTarget:self action:@selector(pullToRefresh:) forControlEvents:UIControlEventValueChanged];
        }
        
        [container registerClass:[UICollectionViewCell class] forCellWithReuseIdentifier:@"0"];
        [container registerClass:[UICollectionViewCell class] forCellWithReuseIdentifier:@"1"];
        [container registerClass:[UICollectionViewCell class] forCellWithReuseIdentifier:@"2"];
        [container registerClass:[UICollectionViewCell class] forCellWithReuseIdentifier:@"3"];
        [container registerClass:[UICollectionViewCell class] forCellWithReuseIdentifier:@"4"];
        [container registerClass:[UICollectionViewCell class] forCellWithReuseIdentifier:@"5"];
        [container registerClass:[UICollectionViewCell class] forCellWithReuseIdentifier:@"6"];
        [container registerClass:[UICollectionViewCell class] forCellWithReuseIdentifier:@"7"];
        [container registerClass:[UICollectionViewCell class] forCellWithReuseIdentifier:@"8"];
        [container registerClass:[UICollectionViewCell class] forCellWithReuseIdentifier:@"9"];
        [container registerClass:[UICollectionViewCell class] forCellWithReuseIdentifier:@"10"];
        [container registerClass:[UICollectionViewCell class] forCellWithReuseIdentifier:@"11"];
        [container registerClass:[UICollectionViewCell class] forCellWithReuseIdentifier:@"12"];
        [container registerClass:[UICollectionViewCell class] forCellWithReuseIdentifier:@"FOOTER"];
        
        [container setShowsHorizontalScrollIndicator:false];
        
        container.backgroundColor = [UIColor clearColor];
        WildCardCollectionViewAdapter* adapter = [[WildCardCollectionViewAdapter alloc] init];
        container.repeatType = adapter.repeatType = repeatType;
        adapter.margin = margin;
        adapter.meta = wcMeta;
        adapter.depth = depth;
        adapter.clipToPadding = clipToPadding;
        self.adapterForRetain = adapter;
        adapter.collectionView = container;
        container.delegate = adapter;
        container.dataSource = adapter;
        
        int minLeft = 1000000;
        int minTop = 1000000;
        for (int i = 0; layers != nil && i < [layers count]; i++) {
            NSMutableDictionary* childLayer = layers[i];
            NSString* childName = childLayer[@"name"];
            if ([childName isEqualToString:arrayContentTargetNode]
                || [childName isEqualToString:arrayContentTargetNodeSurfix]
                || [childName isEqualToString:arrayContentTargetNodePrefix]
                || [childName isEqualToString:arrayContentTargetNodeSelected]
                )
            {
                if([REPEAT_TYPE_HLIST isEqualToString:repeatType] || [REPEAT_TYPE_RIGHT isEqualToString:repeatType]){
                    CGRect childLayoutParam = [WildCardConstructor getFrame:childLayer :nil];
                    if(minLeft > childLayoutParam.origin.x)
                        minLeft = childLayoutParam.origin.x;
                } else if([REPEAT_TYPE_VLIST isEqualToString:repeatType] || [REPEAT_TYPE_BOTTOM isEqualToString:repeatType]){
                    CGRect childLayoutParam = [WildCardConstructor getFrame:childLayer :nil];
                    if(minTop > childLayoutParam.origin.y)
                        minTop = childLayoutParam.origin.y;
                }
            }
        }
        if(minLeft == 1000000)
            minLeft = 0;
        if(minTop == 1000000)
            minTop = 0;
    
        /**
         CollectionView는 iPhone에 상단의 header나 x padding에 의해 contentInset이 자동으로 결정된다
         하지만 아래처럼 세팅하면 이 자동 영역이 사라지고 무조건 xpadding 시작점 부터 리스트가 시작된다.
         container.contentInsetAdjustmentBehavior = UIScrollViewContentInsetAdjustmentNever;
        
         그럼 해더도 같이 무시되서 auto로 설정할수밖에 없는데, 여기서 문제가 되는게
         List가 No Header로 최상단부터 시작하면 안드로이드는 -48로 topmargin이 adjust되지만
         아이폰은 오히려 +48로 xpadding 만큼 자동으로 조정되어 서로 다르게 보이게 된다.
         그래서 List가 NoHeader이고 origin.y가 0인 경우 반대로 xpadding만큼 -top padding을 줘야한다.
         */
        float autoPaddingAdjust = 0;
        BOOL noHeader = [JevilInstance currentInstance].vc && [JevilInstance currentInstance].vc.navigationController.isNavigationBarHidden;
        if([[JevilInstance currentInstance].vc isKindOfClass:[DevilController class]]){
            DevilController* dc = (DevilController*)[JevilInstance currentInstance].vc;
            noHeader = [[WildCardConstructor sharedInstance] getHeaderCloudJson:dc.screenId :dc.landscape] == nil;
        }
        
        CGRect vvGlobalFrame = [WildCardUtil getGlobalFrame:vv];
        if(noHeader && vvGlobalFrame.origin.y == 0 && [REPEAT_TYPE_VLIST isEqualToString:repeatType]) {
            if (@available(iOS 11.0, *)) {
                UIWindow *window = UIApplication.sharedApplication.windows.firstObject;
                autoPaddingAdjust = -window.safeAreaInsets.top;
            }
        }
        
        if(enableReplaceRuleRepeatVListInset)
            container.contentInset = UIEdgeInsetsMake(minTop + autoPaddingAdjust, minLeft, 0, 0);
        else
            container.contentInset = UIEdgeInsetsMake(minTop, minLeft, 0, 0);
        
        arrayContentContainer = self.createdContainer = container;
        
        vv.userInteractionEnabled = YES;
        [WildCardConstructor userInteractionEnableToParentPath:vv depth:depth];
        
        if([REPEAT_TYPE_VLIST isEqualToString:repeatType] && arrayContent[@"sticky"]) {
            NSString* sticky_node = arrayContent[@"sticky"];
            NSArray* childLayers = [layer objectForKey:@"layers"];
            id stickyNodeLayer = [self getReferenceBlock:sticky_node :childLayers];
            WildCardUIView* stickyViewCore = [WildCardConstructor constructLayer:nil withLayer : stickyNodeLayer withParentMeta:wcMeta depth:0 instanceDelegate:wcMeta.wildCardConstructorInstanceDelegate];
            UIWindow *window = UIApplication.sharedApplication.windows.firstObject;
            
            float adjustAreaHeight = window.safeAreaInsets.top;
            BOOL noHeader = [JevilInstance currentInstance].vc && [JevilInstance currentInstance].vc.navigationController.isNavigationBarHidden;
            if([[JevilInstance currentInstance].vc isKindOfClass:[DevilController class]]){
                DevilController* dc = (DevilController*)[JevilInstance currentInstance].vc;
                noHeader = [[WildCardConstructor sharedInstance] getHeaderCloudJson:dc.screenId :dc.landscape] == nil;
            }
            if(!noHeader)
                adjustAreaHeight = 0;
            
            stickyViewCore.frame = CGRectMake(stickyViewCore.frame.origin.x, adjustAreaHeight,
                                              stickyViewCore.frame.size.width, stickyViewCore.frame.size.height);
            self.stickyView = [[WildCardUIView alloc] initWithFrame:CGRectMake(0, 0, stickyViewCore.frame.size.width,
                                                                               stickyViewCore.frame.size.height + adjustAreaHeight)];
            self.stickyView.backgroundColor = stickyViewCore.backgroundColor;
            [self.stickyView addSubview:stickyViewCore];
            self.stickyView.hidden = YES;
            [vv addSubview:self.stickyView];
            
            __block WildCardCollectionViewAdapter* fadapter = adapter;
            
            [adapter setScrolledCallback:^(id res) {
                id index_list = container.indexPathsForVisibleItems;
                if([index_list count] > 0 && self.stickyPosition >= 0) {
                    NSIndexPath* first = index_list[0];
                    for(NSIndexPath* a in index_list) {
                        if(first.row > a.row)
                            first = a;
                    }
                    
                    UICollectionViewLayoutAttributes *firstCellAttributes = [container layoutAttributesForItemAtIndexPath:first];
                    CGFloat y = firstCellAttributes.frame.origin.y - container.contentOffset.y;
                    //NSLog(@"self.stickyPosition= %d, first.row = %d, y=%f", self.stickyPosition, first.row, y);
                    
                    if(first.row >= self.stickyPosition)
                        self.stickyView.hidden = NO;
                    else
                        self.stickyView.hidden = YES;
                }
            }];
            
            [adapter setCellUpdateCallback:^(int index) {
                
                id cloudJson = fadapter.cloudJsonGetter(index);
                if([cloudJson[@"name"] isEqualToString:sticky_node]) {
                    self.stickyPosition = index;
                    NSString* targetJsonString = arrayContent[@"targetJson"];
                    JSValue* targetDataJson = [MappingSyntaxInterpreter
                                                          getJsonWithPath:wcMeta.correspondData : targetJsonString];
                    [WildCardConstructor applyRule:stickyViewCore withData:targetDataJson[index]];
                }
            }];
            
        }
        
    } else if([REPEAT_TYPE_TAG isEqualToString:repeatType]) {
        int minLeft = 1000000;
        int minTop = 1000000;
        for (int i = 0; layers != nil && i < [layers count]; i++) {
            NSMutableDictionary* childLayer = layers[i];
            NSString* childName = childLayer[@"name"];
            if ([childName isEqualToString:arrayContentTargetNode]
                || [childName isEqualToString:arrayContentTargetNodeSurfix]
                || [childName isEqualToString:arrayContentTargetNodePrefix]
                || [childName isEqualToString:arrayContentTargetNodeSelected]
                )
            {
                CGRect childLayoutParam = [WildCardConstructor getFrame:childLayer :nil];
                if(minLeft > childLayoutParam.origin.x)
                    minLeft = childLayoutParam.origin.x;
                if(minTop > childLayoutParam.origin.y)
                    minTop = childLayoutParam.origin.y;
            }
        }
        
        self.tagOffsetX = minLeft;
        self.tagOffsetY = minTop;
        self.createdContainer = vv;
    }
    
    if(arrayContentContainer != nil) {
        [vv addSubview:arrayContentContainer];
        [WildCardUtil followSizeFromFather:vv child:arrayContentContainer];
        if(self.stickyView)
           [vv bringSubviewToFront:self.stickyView];
    }
}

-(void)pullToRefresh:(UIRefreshControl*)refreshControl {
    NSLog(@"pullToRefresh");
    dispatch_time_t popTime = dispatch_time(DISPATCH_TIME_NOW, 1.0f * NSEC_PER_SEC);
    dispatch_after(popTime, dispatch_get_main_queue(), ^{
        NSLog(@"pullToRefresh after");
        WildCardCollectionViewAdapter* adapter = (WildCardCollectionViewAdapter*)self.adapterForRetain;
        WildCardUIView* vv = (WildCardUIView*)self.createdContainer;
        NSString *script = self.pullToRefreshJavascript;
        WildCardTrigger* trigger = [[WildCardTrigger alloc] init];
        trigger.node = vv;
        [WildCardAction execute:trigger script:script meta:adapter.meta];
        [refreshControl endRefreshing];
    });
}


-(id)getReferenceBlock:(NSString*)blockName :(id)childLayers{
    
    if([blockName hasPrefix:@"#"]) {
        blockName = [blockName stringByReplacingOccurrencesOfString:@"#" withString:@""];
        NSString* blockId = [[WildCardConstructor sharedInstance] getBlockIdByName:blockName];
        return  [[WildCardConstructor sharedInstance] getBlockJson:blockId];
    } else {
        for(int i=0;i<[childLayers count];i++) {
            NSDictionary* childLayer = [childLayers objectAtIndex:i];
            if([blockName isEqualToString:[childLayer objectForKey:@"name"]]) {
                return childLayer;
            }
        }
    }
    return nil;
}

-(void)updateRule:(WildCardMeta*)meta data:(id)opt {
    ReplaceRuleRepeat* repeatRule = self;
    
    NSDictionary* layer = repeatRule.replaceJsonLayer;
    NSDictionary* arrayContent = [layer objectForKey:@"arrayContent"];
    NSString* targetNode = [arrayContent objectForKey:@"targetNode"];
    NSString* targetNodeSurfix = [arrayContent objectForKey:@"targetNodeSurfix"];
    NSString* targetNodePrefix = [arrayContent objectForKey:@"targetNodePrefix"];
    NSString* targetNodeSelected = [arrayContent objectForKey:@"targetNodeSelected"];
    NSString* targetNode4 = [arrayContent objectForKey:@"targetNode4"];
    NSString* targetNode5 = [arrayContent objectForKey:@"targetNode5"];
    NSString* targetNode6 = [arrayContent objectForKey:@"targetNode6"];
    NSString* targetNode7 = [arrayContent objectForKey:@"targetNode7"];
    NSString* targetNode8 = [arrayContent objectForKey:@"targetNode8"];
    NSString* targetNode9 = [arrayContent objectForKey:@"targetNode9"];
    NSString* targetNode10 = [arrayContent objectForKey:@"targetNode10"];
    NSString* targetNode11 = [arrayContent objectForKey:@"targetNode11"];
    NSString* targetNode12 = [arrayContent objectForKey:@"targetNode12"];
    NSString* targetNodeSelectedIf = [arrayContent objectForKey:@"targetNodeSelectedIf"];
    NSString* targetNodeSurfixIf = [arrayContent objectForKey:@"targetNodeSurfixIf"];
    NSString* targetNodePrefixIf = [arrayContent objectForKey:@"targetNodePrefixIf"];
    NSString* targetNode4If = [arrayContent objectForKey:@"targetNode4If"];
    NSString* targetNode5If = [arrayContent objectForKey:@"targetNode5If"];
    NSString* targetNode6If = [arrayContent objectForKey:@"targetNode6If"];
    NSString* targetNode7If = [arrayContent objectForKey:@"targetNode7If"];
    NSString* targetNode8If = [arrayContent objectForKey:@"targetNode8If"];
    NSString* targetNode9If = [arrayContent objectForKey:@"targetNode9If"];
    NSString* targetNode10If = [arrayContent objectForKey:@"targetNode10If"];
    NSString* targetNode11If = [arrayContent objectForKey:@"targetNode11If"];
    NSString* targetNode12If = [arrayContent objectForKey:@"targetNode12If"];
    
    NSString* targetJsonString = [arrayContent objectForKey:@"targetJson"]; 
    NSString* repeatType = [arrayContent objectForKey:@"repeatType"];
    float margin = [[arrayContent objectForKey:@"margin"] floatValue];
    margin = [WildCardUtil convertSketchToPixel:margin];
    
    JSValue* targetDataJson = [MappingSyntaxInterpreter
                                          getJsonWithPath:opt : targetJsonString];
    
    NSArray* childLayers = [layer objectForKey:@"layers"];
    NSDictionary* targetLayer = nil;
    NSDictionary* targetLayerSurfix = nil;
    NSDictionary* targetLayerPrefix = nil;
    NSDictionary* targetLayerSelected = nil;
    NSDictionary* targetLayer4 = nil;
    NSDictionary* targetLayer5 = nil;
    NSDictionary* targetLayer6 = nil;
    NSDictionary* targetLayer7 = nil;
    NSDictionary* targetLayer8 = nil;
    NSDictionary* targetLayer9 = nil;
    NSDictionary* targetLayer10 = nil;
    NSDictionary* targetLayer11 = nil;
    NSDictionary* targetLayer12 = nil;
    
    for(int i=0;![targetDataJson isUndefined] && i<[targetDataJson[@"length"] toInt32];i++)
    {
        if(i == 0)
        {
            if(![[targetDataJson[i] class] isSubclassOfClass:[NSDictionary class]]
               || targetDataJson[i][WC_INDEX] != nil)
                break;
        }
        /**
         2021.11.1 collectionView의 조건부 reload를 하기 위해 data를 비교한다. 거기서 WC_INDEX와 같은것을 제외하기 위해 아예 데이터 변조를 하지 않도록한다
         */
//        targetDataJson[i][WC_INDEX] = [NSString stringWithFormat:@"%d", i];
//        targetDataJson[i][WC_LENGTH] = [NSString stringWithFormat:@"%lu", [targetDataJson[@"length"] toInt32]];
    }
    
    
    targetLayer = [self getReferenceBlock:targetNode :childLayers];
    targetLayerPrefix = [self getReferenceBlock:targetNodePrefix :childLayers];
    targetLayerSurfix = [self getReferenceBlock:targetNodeSurfix :childLayers];
    targetLayerSelected = [self getReferenceBlock:targetNodeSelected :childLayers];
    targetLayer4 = [self getReferenceBlock:targetNode4 :childLayers];
    targetLayer5 = [self getReferenceBlock:targetNode5 :childLayers];
    targetLayer6 = [self getReferenceBlock:targetNode6 :childLayers];
    targetLayer7 = [self getReferenceBlock:targetNode7 :childLayers];
    targetLayer8 = [self getReferenceBlock:targetNode8 :childLayers];
    targetLayer9 = [self getReferenceBlock:targetNode9 :childLayers];
    targetLayer10 = [self getReferenceBlock:targetNode10 :childLayers];
    targetLayer11 = [self getReferenceBlock:targetNode11 :childLayers];
    targetLayer12 = [self getReferenceBlock:targetNode12 :childLayers];
    
    if([REPEAT_TYPE_BOTTOM isEqualToString:repeatType] || [REPEAT_TYPE_RIGHT isEqualToString:repeatType])
    {
        int i;
        for(i=0;![targetDataJson isUndefined] && i<[targetDataJson[@"length"] toInt32];i++)
        {
            WildCardUIView* thisNode = nil;
            NSDictionary* thisLayer = targetLayer;
            int thisType = CREATED_VIEW_TYPE_NORMAL;
            JSValue* thisData = targetDataJson[i];
            if(targetLayerSelected != nil && [MappingSyntaxInterpreter ifexpression:targetNodeSelectedIf data:thisData]){
                thisLayer = targetLayerSelected;
                thisType = CREATED_VIEW_TYPE_SELECTED;
            }
            
            if (i < [repeatRule.createdRepeatView count] && thisType == ((CreatedViewInfo*)repeatRule.createdRepeatView[i]).type)
                thisNode = (WildCardUIView*)((CreatedViewInfo*)repeatRule.createdRepeatView[i]).view;
            else
            {
                int containerDepth = ((WildCardUIView*)repeatRule.createdContainer).depth;
                thisNode = [WildCardConstructor constructLayer:nil withLayer : thisLayer withParentMeta:meta  depth:containerDepth+1 instanceDelegate:meta.wildCardConstructorInstanceDelegate];
                
                if (i < [repeatRule.createdRepeatView count] ){
                    [[repeatRule.createdContainer subviews][i] removeFromSuperview];
                    [repeatRule.createdRepeatView removeObjectAtIndex:i];
                }
                [repeatRule.createdContainer insertSubview:thisNode atIndex:i];
                CreatedViewInfo* createdViewInfo = [[CreatedViewInfo alloc] initWithView:thisNode type:thisType];
                [repeatRule.createdRepeatView insertObject:createdViewInfo atIndex:i];
                
                int nextType = [REPEAT_TYPE_RIGHT isEqualToString:repeatType] ? WC_NEXT_TYPE_HORIZONTAL : WC_NEXT_TYPE_VERTICAL;
                if(i > 0) {
                    WildCardUIView* prevView = (WildCardUIView*)((CreatedViewInfo*)[repeatRule.createdRepeatView objectAtIndex:i-1]).view;
                    [meta addNextChain:prevView next:thisNode margin:margin nextType:nextType depth:containerDepth];
                } else {
                    if(nextType == WC_NEXT_TYPE_HORIZONTAL)
                        thisNode.frame = CGRectMake([(WildCardUIView*)[thisNode superview] paddingLeft] , thisNode.frame.origin.y, thisNode.frame.size.width, thisNode.frame.size.height);
                    else
                        thisNode.frame = CGRectMake(thisNode.frame.origin.x, [(WildCardUIView*)[thisNode superview] paddingTop] , thisNode.frame.size.width, thisNode.frame.size.height);
                }
            }
            
            thisNode.hidden = NO;
            [WildCardConstructor userInteractionEnableToParentPath:repeatRule.createdContainer depth:10];
            thisNode.userInteractionEnabled = YES;
            [WildCardConstructor applyRule:thisNode withData:targetDataJson[i]];
            
            
        }
        
        for (int a=(i-1); a >= 0; a--) {
            UIView *child = ((CreatedViewInfo*)repeatRule.createdRepeatView[a]).view;
            [[child superview] bringSubviewToFront:child];
        }
        
        for (; i < [repeatRule.createdRepeatView count]; i++) {
            ((CreatedViewInfo*)repeatRule.createdRepeatView[i]).view.hidden = YES;
        }
    }
    else if([REPEAT_TYPE_GRID isEqualToString:repeatType])
    {
        WildCardGridView* gv = (WildCardGridView *)repeatRule.createdContainer;
        
        float w = [[[targetLayer objectForKey:@"frame"] objectForKey:@"w"] floatValue];
        float containerWidth = [[[layer objectForKey:@"frame"] objectForKey:@"w"] floatValue];
        int col = (int)(containerWidth / w);
        if( (containerWidth / w) - col > 0.7f)
            col ++;
        gv.col = col;
        gv.data = targetDataJson;
        
        gv.cloudJsonGetter = ^NSDictionary *(int position) {
            if(targetNodeSelected != nil && [MappingSyntaxInterpreter ifexpression:targetNodeSelectedIf data: targetDataJson[position]])
                return targetLayerSelected;
            else if(targetLayerPrefix != nil && [MappingSyntaxInterpreter ifexpression:targetNodePrefixIf data: targetDataJson[position]])
                return targetLayerPrefix;
            else if(targetLayerSurfix != nil && [MappingSyntaxInterpreter ifexpression:targetNodeSurfixIf data: targetDataJson[position]])
                return targetLayerSurfix;
            else if(targetLayer4 != nil && [MappingSyntaxInterpreter ifexpression:targetNode4If data: targetDataJson[position]])
                return targetLayer4;
            else if(targetLayer5 != nil && [MappingSyntaxInterpreter ifexpression:targetNode5If data: targetDataJson[position]])
                return targetLayer5;
            else if(targetLayer6 != nil && [MappingSyntaxInterpreter ifexpression:targetNode6If data: targetDataJson[position]])
                return targetLayer6;
            else if(targetLayer7 != nil && [MappingSyntaxInterpreter ifexpression:targetNode7If data: targetDataJson[position]])
                return targetLayer7;
            else if(targetLayer8 != nil && [MappingSyntaxInterpreter ifexpression:targetNode8If data: targetDataJson[position]])
                return targetLayer8;
            else if(targetLayer9 != nil && [MappingSyntaxInterpreter ifexpression:targetNode9If data: targetDataJson[position]])
                return targetLayer9;
            else if(targetLayer10 != nil && [MappingSyntaxInterpreter ifexpression:targetNode10If data: targetDataJson[position]])
                return targetLayer10;
            else if(targetLayer11 != nil && [MappingSyntaxInterpreter ifexpression:targetNode11If data: targetDataJson[position]])
                return targetLayer11;
            else if(targetLayer12 != nil && [MappingSyntaxInterpreter ifexpression:targetNode12If data: targetDataJson[position]])
                return targetLayer12;
            return targetLayer;
        };
        
        gv.typeGetter = ^NSString *(int position) {
            if(targetNodeSelected != nil && [MappingSyntaxInterpreter ifexpression:targetNodeSelectedIf data: targetDataJson[position]])
                return @"3";
            else if(targetLayerPrefix != nil && [MappingSyntaxInterpreter ifexpression:targetNodePrefixIf data: targetDataJson[position]])
                return @"2";
            else if(targetLayerSurfix != nil && [MappingSyntaxInterpreter ifexpression:targetNodeSurfixIf data: targetDataJson[position]])
                return @"1";
            else if(targetLayer4 != nil && [MappingSyntaxInterpreter ifexpression:targetNode4If data: targetDataJson[position]])
                return @"4";
            else if(targetLayer5 != nil && [MappingSyntaxInterpreter ifexpression:targetNode5If data: targetDataJson[position]])
                return @"5";
            else if(targetLayer6 != nil && [MappingSyntaxInterpreter ifexpression:targetNode6If data: targetDataJson[position]])
                return @"6";
            else if(targetLayer7 != nil && [MappingSyntaxInterpreter ifexpression:targetNode7If data: targetDataJson[position]])
                return @"7";
            else if(targetLayer8 != nil && [MappingSyntaxInterpreter ifexpression:targetNode8If data: targetDataJson[position]])
                return @"8";
            else if(targetLayer9 != nil && [MappingSyntaxInterpreter ifexpression:targetNode9If data: targetDataJson[position]])
                return @"9";
            else if(targetLayer10 != nil && [MappingSyntaxInterpreter ifexpression:targetNode10If data: targetDataJson[position]])
                return @"10";
            else if(targetLayer11 != nil && [MappingSyntaxInterpreter ifexpression:targetNode11If data: targetDataJson[position]])
                return @"11";
            else if(targetLayer12 != nil && [MappingSyntaxInterpreter ifexpression:targetNode12If data: targetDataJson[position]])
                return @"12";
            return @"0";
        };
        
        [gv reloadData];
    }
    else if([REPEAT_TYPE_VIEWPAGER isEqualToString:repeatType])
    {
        UICollectionView *cv = (UICollectionView *)repeatRule.createdContainer;
        WildCardCollectionViewAdapter* adapter = (WildCardCollectionViewAdapter*)repeatRule.adapterForRetain;
        
        adapter.data = targetDataJson;
        
        [adapter autoSwipe:[@"Y" isEqualToString:arrayContent[@"autoSwipe"]]];
        
        BOOL atLeastOneSelected = false;
        for(int i=0;i<[targetDataJson[@"length"] toInt32];i++)
        {
            if([@"Y" isEqualToString:targetDataJson[i][WC_SELECTED]])
            {
                atLeastOneSelected = true;
                break;
            }
        }
        if(!atLeastOneSelected && [targetDataJson[@"length"] toInt32] > 0)
            targetDataJson[0][WC_SELECTED] = @"Y";
        
        adapter.cloudJsonGetter = ^NSDictionary *(int position) {
            if(targetNodeSelected != nil && [MappingSyntaxInterpreter ifexpression:targetNodeSelectedIf data: targetDataJson[position]])
                return targetLayerSelected;
            else if(targetLayerPrefix != nil && [MappingSyntaxInterpreter ifexpression:targetNodePrefixIf data: targetDataJson[position]])
                return targetLayerPrefix;
            else if(targetLayerSurfix != nil && [MappingSyntaxInterpreter ifexpression:targetNodeSurfixIf data: targetDataJson[position]])
                return targetLayerSurfix;
            else if(targetLayer4 != nil && [MappingSyntaxInterpreter ifexpression:targetNode4If data: targetDataJson[position]])
                return targetLayer4;
            else if(targetLayer5 != nil && [MappingSyntaxInterpreter ifexpression:targetNode5If data: targetDataJson[position]])
                return targetLayer5;
            else if(targetLayer6 != nil && [MappingSyntaxInterpreter ifexpression:targetNode6If data: targetDataJson[position]])
                return targetLayer6;
            else if(targetLayer7 != nil && [MappingSyntaxInterpreter ifexpression:targetNode7If data: targetDataJson[position]])
                return targetLayer7;
            else if(targetLayer8 != nil && [MappingSyntaxInterpreter ifexpression:targetNode8If data: targetDataJson[position]])
                return targetLayer8;
            else if(targetLayer9 != nil && [MappingSyntaxInterpreter ifexpression:targetNode9If data: targetDataJson[position]])
                return targetLayer9;
            else if(targetLayer10 != nil && [MappingSyntaxInterpreter ifexpression:targetNode10If data: targetDataJson[position]])
                return targetLayer10;
            else if(targetLayer11 != nil && [MappingSyntaxInterpreter ifexpression:targetNode11If data: targetDataJson[position]])
                return targetLayer11;
            else if(targetLayer12 != nil && [MappingSyntaxInterpreter ifexpression:targetNode12If data: targetDataJson[position]])
                return targetLayer12;
            return targetLayer;
        };
        
        adapter.typeGetter = ^NSString *(int position) {
            if(targetNodeSelected != nil && [MappingSyntaxInterpreter ifexpression:targetNodeSelectedIf data: targetDataJson[position]])
                return @"3";
            else if(targetLayerPrefix != nil && [MappingSyntaxInterpreter ifexpression:targetNodePrefixIf data: targetDataJson[position]])
                return @"0";
            else if(targetLayerSurfix != nil && [MappingSyntaxInterpreter ifexpression:targetNodeSurfixIf data: targetDataJson[position]])
                return @"1";
            else if(targetLayer4 != nil && [MappingSyntaxInterpreter ifexpression:targetNode4If data: targetDataJson[position]])
                return @"4";
            else if(targetLayer5 != nil && [MappingSyntaxInterpreter ifexpression:targetNode5If data: targetDataJson[position]])
                return @"5";
            else if(targetLayer6 != nil && [MappingSyntaxInterpreter ifexpression:targetNode6If data: targetDataJson[position]])
                return @"6";
            else if(targetLayer7 != nil && [MappingSyntaxInterpreter ifexpression:targetNode7If data: targetDataJson[position]])
                return @"7";
            else if(targetLayer8 != nil && [MappingSyntaxInterpreter ifexpression:targetNode8If data: targetDataJson[position]])
                return @"8";
            else if(targetLayer9 != nil && [MappingSyntaxInterpreter ifexpression:targetNode9If data: targetDataJson[position]])
                return @"9";
            else if(targetLayer10 != nil && [MappingSyntaxInterpreter ifexpression:targetNode10If data: targetDataJson[position]])
                return @"10";
            else if(targetLayer11 != nil && [MappingSyntaxInterpreter ifexpression:targetNode11If data: targetDataJson[position]])
                return @"11";
            else if(targetLayer12 != nil && [MappingSyntaxInterpreter ifexpression:targetNode12If data: targetDataJson[position]])
                return @"12";
            return @"2";
        };
        
        NSString* vvname = ((WildCardUIView*)self.replaceView).name;
        DevilController* dc = (DevilController*)[JevilInstance currentInstance].vc;
        if(dc.viewPagerReservedSelectedCallbackMap && dc.viewPagerReservedSelectedCallbackMap[vvname]) {
            [adapter setViewPagerSelectedCallback:dc.viewPagerReservedSelectedCallbackMap[vvname]];
        }
        
        if([adapter shouldReload]) {
            [cv reloadData];
            if(adapter.infinite) {
                dispatch_async(dispatch_get_main_queue(), ^{
                    if(targetDataJson)
                        [cv scrollToItemAtIndexPath:[NSIndexPath indexPathForItem:([targetDataJson[@"length"] toInt32]/2) inSection:0] atScrollPosition:UICollectionViewScrollPositionCenteredHorizontally animated:NO];
                });
            }
        }
        
        if(dc.viewPagerReservedSelectedIndexMap && dc.viewPagerReservedSelectedIndexMap[vvname] && [adapter getCount] > 0) {
            dispatch_async(dispatch_get_main_queue(), ^{
                int index = [dc.viewPagerReservedSelectedIndexMap[vvname] intValue];
                [cv scrollToItemAtIndexPath:[NSIndexPath indexPathForItem:index inSection:0] atScrollPosition:UICollectionViewScrollPositionCenteredHorizontally animated:NO];
                [dc.viewPagerReservedSelectedIndexMap removeObjectForKey:vvname];
            });
        }
    }
    else if([REPEAT_TYPE_HLIST isEqualToString:repeatType] || [REPEAT_TYPE_VLIST isEqualToString:repeatType])
    {
        UICollectionView *cv = (UICollectionView *)repeatRule.createdContainer;
        WildCardCollectionViewAdapter* adapter = (WildCardCollectionViewAdapter*)repeatRule.adapterForRetain;
        
        adapter.data = targetDataJson;
        adapter.cloudJsonGetter = ^NSDictionary *(int position) {
            if(targetNodeSelected != nil && [MappingSyntaxInterpreter ifexpression:targetNodeSelectedIf data: targetDataJson[position]])
                return targetLayerSelected;
            else if(targetLayerPrefix != nil && [MappingSyntaxInterpreter ifexpression:targetNodePrefixIf data: targetDataJson[position]])
                return targetLayerPrefix;
            else if(targetLayerSurfix != nil && [MappingSyntaxInterpreter ifexpression:targetNodeSurfixIf data: targetDataJson[position]])
                return targetLayerSurfix;
            else if(targetLayer4 != nil && [MappingSyntaxInterpreter ifexpression:targetNode4If data: targetDataJson[position]])
                return targetLayer4;
            else if(targetLayer5 != nil && [MappingSyntaxInterpreter ifexpression:targetNode5If data: targetDataJson[position]])
                return targetLayer5;
            else if(targetLayer6 != nil && [MappingSyntaxInterpreter ifexpression:targetNode6If data: targetDataJson[position]])
                return targetLayer6;
            else if(targetLayer7 != nil && [MappingSyntaxInterpreter ifexpression:targetNode7If data: targetDataJson[position]])
                return targetLayer7;
            else if(targetLayer8 != nil && [MappingSyntaxInterpreter ifexpression:targetNode8If data: targetDataJson[position]])
                return targetLayer8;
            else if(targetLayer9 != nil && [MappingSyntaxInterpreter ifexpression:targetNode9If data: targetDataJson[position]])
                return targetLayer9;
            else if(targetLayer10 != nil && [MappingSyntaxInterpreter ifexpression:targetNode10If data: targetDataJson[position]])
                return targetLayer10;
            else if(targetLayer11 != nil && [MappingSyntaxInterpreter ifexpression:targetNode11If data: targetDataJson[position]])
                return targetLayer11;
            else if(targetLayer12 != nil && [MappingSyntaxInterpreter ifexpression:targetNode12If data: targetDataJson[position]])
                return targetLayer12;
            return targetLayer;
        };
        
        adapter.typeGetter = ^NSString *(int position) {
            if(targetNodeSelected != nil && [MappingSyntaxInterpreter ifexpression:targetNodeSelectedIf data: targetDataJson[position]])
                return @"3";
            else if(targetLayerPrefix != nil && [MappingSyntaxInterpreter ifexpression:targetNodePrefixIf data: targetDataJson[position]])
                return @"0";
            else if(targetLayerSurfix != nil && [MappingSyntaxInterpreter ifexpression:targetNodeSurfixIf data: targetDataJson[position]])
                return @"1";
            else if(targetLayer4 != nil && [MappingSyntaxInterpreter ifexpression:targetNode4If data: targetDataJson[position]])
                return @"4";
            else if(targetLayer5 != nil && [MappingSyntaxInterpreter ifexpression:targetNode5If data: targetDataJson[position]])
                return @"5";
            else if(targetLayer6 != nil && [MappingSyntaxInterpreter ifexpression:targetNode6If data: targetDataJson[position]])
                return @"6";
            else if(targetLayer7 != nil && [MappingSyntaxInterpreter ifexpression:targetNode7If data: targetDataJson[position]])
                return @"7";
            else if(targetLayer8 != nil && [MappingSyntaxInterpreter ifexpression:targetNode8If data: targetDataJson[position]])
                return @"8";
            else if(targetLayer9 != nil && [MappingSyntaxInterpreter ifexpression:targetNode9If data: targetDataJson[position]])
                return @"9";
            else if(targetLayer10 != nil && [MappingSyntaxInterpreter ifexpression:targetNode10If data: targetDataJson[position]])
                return @"10";
            else if(targetLayer11 != nil && [MappingSyntaxInterpreter ifexpression:targetNode11If data: targetDataJson[position]])
                return @"11";
            else if(targetLayer12 != nil && [MappingSyntaxInterpreter ifexpression:targetNode12If data: targetDataJson[position]])
                return @"12";
            return @"2";
        };
         
        
        if([adapter shouldReload])
            [cv reloadData];
        
    } else if([REPEAT_TYPE_TAG isEqualToString:repeatType]) {
        int i;
        float offsetX = self.tagOffsetX;
        float offsetY = self.tagOffsetY;
        float containerWidth = [self getLayerWidth:self.replaceJsonLayer];
        float containerHeight = [self getLayerHeight:self.replaceJsonLayer ];
        int dpMargin = [WildCardConstructor convertSketchToPixel:margin];
        BOOL containerWrapHeight = ((WildCardUIView*)repeatRule.createdContainer).wrap_height;
        for(i=0;i<[targetDataJson[@"length"] toInt32];i++)
        {
            WildCardUIView* thisNode = nil;
            NSDictionary* thisLayer = targetLayer;
            int thisType = CREATED_VIEW_TYPE_NORMAL;
            JSValue* thisData = targetDataJson[i];
            if(targetLayerSelected != nil && [MappingSyntaxInterpreter ifexpression:targetNodeSelectedIf data:thisData]){
                thisLayer = targetLayerSelected;
                thisType = CREATED_VIEW_TYPE_SELECTED;
            }
            
            if (i < [repeatRule.createdRepeatView count] && thisType == ((CreatedViewInfo*)repeatRule.createdRepeatView[i]).type)
                thisNode = (WildCardUIView*)((CreatedViewInfo*)repeatRule.createdRepeatView[i]).view;
            else
            {
                int containerDepth = ((WildCardUIView*)repeatRule.createdContainer).depth;
                thisNode = [WildCardConstructor constructLayer:nil withLayer : thisLayer withParentMeta:meta  depth:containerDepth+1 instanceDelegate:meta.wildCardConstructorInstanceDelegate];
                
                if (i < [repeatRule.createdRepeatView count] ){
                    [[repeatRule.createdContainer subviews][i] removeFromSuperview];
                    [repeatRule.createdRepeatView removeObjectAtIndex:i];
                }
                [repeatRule.createdContainer insertSubview:thisNode atIndex:i];
                CreatedViewInfo* createdViewInfo = [[CreatedViewInfo alloc] initWithView:thisNode type:thisType];
                [repeatRule.createdRepeatView insertObject:createdViewInfo atIndex:i];
            }
            
            thisNode.frame = CGRectMake((int)offsetX, (int)offsetY, thisNode.frame.size.width, thisNode.frame.size.height);
            thisNode.hidden = NO;
            [WildCardConstructor userInteractionEnableToParentPath:repeatRule.createdContainer depth:10];
            repeatRule.createdContainer.userInteractionEnabled = true;
            thisNode.userInteractionEnabled = YES;
            [WildCardConstructor applyRule:thisNode withData:targetDataJson[i]];
            
            float thisWidth = [WildCardUtil measureWidth:thisLayer data:targetDataJson[i]];
            
            float thisHeight = [self getLayerHeight:thisLayer];
            offsetX += dpMargin;

            if(offsetX + thisWidth < containerWidth)
                offsetX += thisWidth;
            else {
                if(containerWrapHeight || (offsetY + thisHeight  + dpMargin < containerHeight)) {
                    offsetY += thisHeight + dpMargin;
                    offsetX = self.tagOffsetX;
                    
                    thisNode.frame = CGRectMake((int)offsetX, (int)offsetY, thisNode.frame.size.width, thisNode.frame.size.height);
                    offsetX += thisWidth;
                    offsetX += dpMargin;
                } else {
                    break;
                }
            }
        }
        
        for (; i < [repeatRule.createdRepeatView count]; i++) {
            ((CreatedViewInfo*)repeatRule.createdRepeatView[i]).view.hidden = YES;
        }
    }
}


-(float)getLayerWidth:(id)layer {
    id frame = layer[@"frame"];
    float w = [frame[@"w"] floatValue];
    return [WildCardConstructor convertSketchToPixel:w];
}

-(float)getLayerHeight:(id)layer {
    id frame = layer[@"frame"];
    float h = [frame[@"h"] floatValue];
    return [WildCardConstructor convertSketchToPixel:h];
}


static BOOL enableReplaceRuleRepeatVListInset = YES;
+(void)disableInset {
    enableReplaceRuleRepeatVListInset = NO;
}
+(void)enableInset {
    enableReplaceRuleRepeatVListInset = YES;
}
@end

@implementation CreatedViewInfo

-(id)initWithView:(UIView*)v type:(int)type{
    self = [super init];
    self.view = v;
    self.type = type;
    return self;
}

@end
