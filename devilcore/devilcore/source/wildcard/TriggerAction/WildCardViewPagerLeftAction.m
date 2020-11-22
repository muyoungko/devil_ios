//
//  WildCardViewPagerLeftAction.m
//  library
//
//  Created by Mu Young Ko on 2018. 10. 31..
//  Copyright © 2018년 sbs cnbc. All rights reserved.
//

#import "WildCardViewPagerLeftAction.h"
#import "WildCardMeta.h"
#import "WildCardUIView.h"
#import "WildCardCollectionViewAdapter.h"
#import "MappingSyntaxInterpreter.h"

@implementation WildCardViewPagerLeftAction

-(void)act:(WildCardTrigger *)trigger
{
    [super act:trigger];
    WildCardUIView* vv = super.meta.generatedViews[_node];
    UICollectionView* c = [vv subviews][0];
    WildCardCollectionViewAdapter* adapter = (WildCardCollectionViewAdapter*)c.delegate;
    
    int count = [adapter getCount];
    int index = [adapter getIndex];
    index --;
    if(index >= 0)
        [adapter scrollToIndex:index view:c];
}

@end



@implementation WildCardViewPagerScrollAction

-(void)act:(WildCardTrigger *)trigger
{
    [super act:trigger];
    WildCardUIView* vv = self.meta.generatedViews[_node];
    if(vv == nil)
    {
        WildCardMeta* cursor = self.meta.parentMeta;
        while(cursor != nil)
        {
            vv = cursor.generatedViews[_node];
            if(vv != nil)
                break;
            cursor = cursor.parentMeta;
        }
    }
    UICollectionView* c = [vv subviews][0];
    WildCardCollectionViewAdapter* adapter = (WildCardCollectionViewAdapter*)c.delegate;
    
    
    
    NSString* strIndex = [MappingSyntaxInterpreter interpret:_toScrollIndexArgument :self.meta.correspondData];
    
    int index = [strIndex intValue];
    [adapter scrollToIndex:index view:c];
}

@end
