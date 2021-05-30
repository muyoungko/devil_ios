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

@interface ReplaceRuleRepeat()
@property int tagOffsetX;
@property int tagOffsetY;
@end

@implementation ReplaceRuleRepeat

-(void)constructRule:(WildCardMeta*)wcMeta parent:(UIView*)parent vv:(WildCardUIView*)vv layer:(id)layer depth:(int)depth result:(id)result{
    self.createdRepeatView = [[NSMutableArray alloc] init];
    
    id layers = layer[@"layers"];
    NSDictionary* triggerMap = layer[@"trigger"];
    
    NSDictionary* arrayContent = [layer objectForKey:@"arrayContent"];
    NSString* arrayContentTargetNode = [arrayContent objectForKey:@"targetNode"];
    NSString* arrayContentTargetNodeSurfix = [arrayContent objectForKey:@"targetNodeSurfix"];
    NSString* arrayContentTargetNodePrefix = [arrayContent objectForKey:@"targetNodePrefix"];
    NSString* arrayContentTargetNodeSelected = [arrayContent objectForKey:@"targetNodeSelected"];
    
    id shouldContinueChild = [@[] mutableCopy];
    if(arrayContentTargetNode)
        [shouldContinueChild addObject:arrayContentTargetNode];
    if(arrayContentTargetNodeSurfix)
        [shouldContinueChild addObject:arrayContentTargetNodeSurfix];
    if(arrayContentTargetNodePrefix)
        [shouldContinueChild addObject:arrayContentTargetNodePrefix];
    if(arrayContentTargetNodeSelected)
        [shouldContinueChild addObject:arrayContentTargetNodeSelected];
    
    result[@"shouldContinueChild"] = shouldContinueChild;
    
    NSString* repeatType = [arrayContent objectForKey:@"repeatType"];
    float margin = 0;
    if([arrayContent objectForKey:@"margin"] != nil)
        margin = [[arrayContent objectForKey:@"margin"] floatValue];
    margin = [WildCardConstructor convertSketchToPixel:margin];
    
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
        
        //container.pagingEnabled = YES;
        
        [container setShowsHorizontalScrollIndicator:NO];
        [container setShowsVerticalScrollIndicator:NO];
        container.backgroundColor = [UIColor clearColor];
        WildCardCollectionViewAdapter* adapter = [[WildCardCollectionViewAdapter alloc] init];
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
            for(int i=0;i<[adapter.data count];i++)
            {
                if(i==position)
                    adapter.data[i][WC_SELECTED] = @"Y";
                else
                    adapter.data[i][WC_SELECTED] = @"N";
            }
            
            [wcMeta doAllActionOfTrigger:WILDCARD_VIEW_PAGER_CHANGED node:vv.name];
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
        
        UICollectionView *container = [[UICollectionView alloc] initWithFrame:containerRect collectionViewLayout:flowLayout];
        [container registerClass:[UICollectionViewCell class] forCellWithReuseIdentifier:@"0"];
        [container registerClass:[UICollectionViewCell class] forCellWithReuseIdentifier:@"1"];
        [container registerClass:[UICollectionViewCell class] forCellWithReuseIdentifier:@"2"];
        [container registerClass:[UICollectionViewCell class] forCellWithReuseIdentifier:@"3"];
        
        [container setShowsHorizontalScrollIndicator:NO];
        [container setShowsVerticalScrollIndicator:NO];
        container.backgroundColor = [UIColor clearColor];
        WildCardCollectionViewAdapter* adapter = [[WildCardCollectionViewAdapter alloc] init];
        adapter.repeatType = repeatType;
        adapter.margin = margin;
        adapter.meta = wcMeta;
        adapter.depth = depth;
        self.adapterForRetain = adapter;
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
        container.contentInset = UIEdgeInsetsMake(minTop, minLeft, 0, 0);
        
        arrayContentContainer = self.createdContainer = container;
        
        vv.userInteractionEnabled = YES;
        [WildCardConstructor userInteractionEnableToParentPath:vv depth:depth];
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
    
    if(arrayContentContainer != nil)
        [vv addSubview:arrayContentContainer];
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
    NSString* targetNodeSelectedIf = [arrayContent objectForKey:@"targetNodeSelectedIf"];
    NSString* targetNodeSurfixIf = [arrayContent objectForKey:@"targetNodeSurfixIf"];
    NSString* targetNodePrefixIf = [arrayContent objectForKey:@"targetNodePrefixIf"];
    
    NSString* targetJsonString = [arrayContent objectForKey:@"targetJson"];
    NSString* repeatType = [arrayContent objectForKey:@"repeatType"];
    float margin = [[arrayContent objectForKey:@"margin"] floatValue];
    margin = [WildCardUtil convertSketchToPixel:margin];
    BOOL innerLine = [@"Y" isEqualToString:[arrayContent objectForKey:@"innerLine"]];
    
    NSArray* targetDataJson = (NSArray*) [MappingSyntaxInterpreter
                                          getJsonWithPath:opt : targetJsonString];
    
    NSArray* childLayers = [layer objectForKey:@"layers"];
    NSDictionary* targetLayer = nil;
    NSDictionary* targetLayerSurfix = nil;
    NSDictionary* targetLayerPrefix = nil;
    NSDictionary* targetLayerSelected = nil;
    
    for(int i=0;i<[targetDataJson count];i++)
    {
        if(i == 0)
        {
            if(![[targetDataJson[i] class] isSubclassOfClass:[NSDictionary class]]
               || targetDataJson[i][WC_INDEX] != nil)
                break;
        }
        targetDataJson[i][WC_INDEX] = [NSString stringWithFormat:@"%d", i];
        targetDataJson[i][WC_LENGTH] = [NSString stringWithFormat:@"%lu", [targetDataJson count]];
    }
    
    
    targetLayer = [self getReferenceBlock:targetNode :childLayers];
    targetLayerPrefix = [self getReferenceBlock:targetNodePrefix :childLayers];
    targetLayerSurfix = [self getReferenceBlock:targetNodeSurfix :childLayers];
    targetLayerSelected = [self getReferenceBlock:targetNodeSelected :childLayers];
    
    if([REPEAT_TYPE_BOTTOM isEqualToString:repeatType] || [REPEAT_TYPE_RIGHT isEqualToString:repeatType])
    {
        int i;
        for(i=0;i<[targetDataJson count];i++)
        {
            WildCardUIView* thisNode = nil;
            NSDictionary* thisLayer = targetLayer;
            int thisType = CREATED_VIEW_TYPE_NORMAL;
            NSMutableDictionary* thisData = [targetDataJson objectAtIndex:i];
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
                
                BOOL horizontal = [REPEAT_TYPE_RIGHT isEqualToString:repeatType];
                if(i > 0) {
                    WildCardUIView* prevView = (WildCardUIView*)((CreatedViewInfo*)[repeatRule.createdRepeatView objectAtIndex:i-1]).view;
                    [meta addNextChain:prevView next:thisNode margin:margin horizontal:horizontal depth:containerDepth];
                } else {
                    if(horizontal)
                        thisNode.frame = CGRectMake([(WildCardUIView*)[thisNode superview] paddingLeft] , thisNode.frame.origin.y, thisNode.frame.size.width, thisNode.frame.size.height);
                    else
                        thisNode.frame = CGRectMake(thisNode.frame.origin.x, [(WildCardUIView*)[thisNode superview] paddingTop] , thisNode.frame.size.width, thisNode.frame.size.height);
                }
            }
            
            thisNode.hidden = NO;
            [WildCardConstructor userInteractionEnableToParentPath:repeatRule.createdContainer depth:10];
            thisNode.userInteractionEnabled = YES;
            [WildCardConstructor applyRule:thisNode withData:[targetDataJson objectAtIndex:i]];
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
        [gv setInnerLine:innerLine];
        
        gv.cloudJsonGetter = ^NSDictionary *(int position) {
            if(targetNodeSelected != nil && [MappingSyntaxInterpreter ifexpression:targetNodeSelectedIf data: targetDataJson[position]])
                return targetLayerSelected;
            else if(targetLayerPrefix != nil && [MappingSyntaxInterpreter ifexpression:targetNodePrefixIf data: targetDataJson[position]])
                return targetLayerPrefix;
            else if(targetLayerSurfix != nil && [MappingSyntaxInterpreter ifexpression:targetNodeSurfixIf data: targetDataJson[position]])
                return targetLayerSurfix;
            return targetLayer;
        };
        
        gv.typeGetter = ^NSString *(int position) {
            if(targetNodeSelected != nil && [MappingSyntaxInterpreter ifexpression:targetNodeSelectedIf data: targetDataJson[position]])
                return @"3";
            else if(targetLayerPrefix != nil && [MappingSyntaxInterpreter ifexpression:targetNodePrefixIf data: targetDataJson[position]])
                return @"2";
            else if(targetLayerSurfix != nil && [MappingSyntaxInterpreter ifexpression:targetNodeSurfixIf data: targetDataJson[position]])
                return @"1";
            return @"0";
        };
        
        //gv.lineColor = [UIColor redColor];
        //gv.lineWidth = 1;
        //gv.outerWidth = 1;
        
        [gv reloadData];
    }
    else if([REPEAT_TYPE_VIEWPAGER isEqualToString:repeatType])
    {
        UICollectionView *cv = (UICollectionView *)repeatRule.createdContainer;
        WildCardCollectionViewAdapter* adapter = (WildCardCollectionViewAdapter*)repeatRule.adapterForRetain;
        
        adapter.data = targetDataJson;
        
        BOOL atLeastOneSelected = false;
        for(int i=0;i<[targetDataJson count];i++)
        {
            if([@"Y" isEqualToString:targetDataJson[i][WC_SELECTED]])
            {
                atLeastOneSelected = true;
                break;
            }
        }
        if(!atLeastOneSelected && [targetDataJson count] > 0)
            targetDataJson[0][WC_SELECTED] = @"Y";
        
        adapter.cloudJsonGetter = ^NSDictionary *(int position) {
            if(targetLayerPrefix != nil && position == 0)
                return targetLayerPrefix;
            else if(targetLayerSurfix != nil && position == [targetDataJson count]-1)
                return targetLayerSurfix;
            return targetLayer;
        };
        
        adapter.typeGetter = ^NSString *(int position) {
            if(targetLayerPrefix != nil && position == 0)
                return @"0";
            else if(targetLayerSurfix != nil && position == [targetDataJson count]-1)
                return @"1";
            return @"2";
        };
        
        [cv reloadData];
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
            return targetLayer;
        };
        
        adapter.typeGetter = ^NSString *(int position) {
            if(targetNodeSelected != nil && [MappingSyntaxInterpreter ifexpression:targetNodeSelectedIf data: targetDataJson[position]])
                return @"3";
            else if(targetLayerPrefix != nil && [MappingSyntaxInterpreter ifexpression:targetNodePrefixIf data: targetDataJson[position]])
                return @"0";
            else if(targetLayerSurfix != nil && [MappingSyntaxInterpreter ifexpression:targetNodeSurfixIf data: targetDataJson[position]])
                return @"1";
            return @"2";
        };
        
        [cv reloadData];
    } else if([REPEAT_TYPE_TAG isEqualToString:repeatType]) {
        int i;
        float offsetX = self.tagOffsetX;
        float offsetY = self.tagOffsetY;
        float containerWidth = [self getLayerWidth:self.replaceJsonLayer];
        float containerHeight = [self getLayerHeight:self.replaceJsonLayer ];
        int dpMargin = [WildCardConstructor convertSketchToPixel:margin];
        for(i=0;i<[targetDataJson count];i++)
        {
            WildCardUIView* thisNode = nil;
            NSDictionary* thisLayer = targetLayer;
            int thisType = CREATED_VIEW_TYPE_NORMAL;
            NSMutableDictionary* thisData = [targetDataJson objectAtIndex:i];
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
            [WildCardConstructor applyRule:thisNode withData:[targetDataJson objectAtIndex:i]];
            
            int padding = 0;
            if(arrayContent[@"tagPadding"])
                padding = [WildCardConstructor convertSketchToPixel:[arrayContent[@"tagPadding"] intValue]];
            float thisWidth = padding + [self measureTagWidth:thisNode] + padding;
            [self fitTagWidth:thisNode :thisWidth];
            
            float thisHeight = [self getLayerHeight:thisLayer];
            offsetX += dpMargin;

            if(offsetX + thisWidth < containerWidth)
                offsetX += thisWidth;
            else {
                if(offsetY + thisHeight  + dpMargin < containerHeight) {
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

-(void)fitTagWidth:(UIView*)vv :(int)width {
    vv.frame = CGRectMake(vv.frame.origin.x, vv.frame.origin.y, width, vv.frame.size.height);
    if([vv isMemberOfClass:[UILabel class]])
        ((UILabel*)vv).textAlignment = UITextAlignmentCenter;
    for(int i=0;i<[[vv subviews] count];i++){
        UIView* child = [vv subviews][i];
        [self fitTagWidth:child:width];
    }
}

-(float)measureTagWidth:(UIView*)vv {
    float textWidth = 0;
    if([vv isKindOfClass:[UILabel class]]) {
        UILabel* tv = (UILabel*)vv;
        UIFont* font = tv.font;
        NSDictionary *attributes = @{NSFontAttributeName: font};
        CGRect size = [tv.text boundingRectWithSize:CGSizeMake(CGFLOAT_MAX, 100) options:NSStringDrawingUsesLineFragmentOrigin attributes:attributes context:nil];
        textWidth = size.size.width;
    }
    
    for(int i=0;i<[[vv subviews] count];i++){
        UIView* child = [vv subviews][i];
        float thisTextWidth = [self measureTagWidth:child];
        if(thisTextWidth > textWidth)
            textWidth = thisTextWidth;
    }

    return textWidth;
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

@end

@implementation CreatedViewInfo

-(id)initWithView:(UIView*)v type:(int)type{
    self = [super init];
    self.view = v;
    self.type = type;
    return self;
}
@end
