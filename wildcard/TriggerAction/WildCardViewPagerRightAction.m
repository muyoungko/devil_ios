//
//  WildCardViewPagerRightAction.m
//  library
//
//  Created by Mu Young Ko on 2018. 10. 31..
//  Copyright © 2018년 sbs cnbc. All rights reserved.
//

#import "WildCardViewPagerRightAction.h"
#import "WildCardMeta.h"
#import "WildCardUIView.h"
#import "WildCardCollectionViewAdapter.h"

@implementation WildCardViewPagerRightAction

-(void)act:(WildCardTrigger *)trigger
{
    [super act:trigger];
    WildCardUIView* vv = super.meta.generatedViews[_node];
    UICollectionView* c = [vv subviews][0];
    WildCardCollectionViewAdapter* adapter = (WildCardCollectionViewAdapter*)c.delegate;
    
    int count = [adapter getCount];
    int index = [adapter getIndex];
    index ++;
    if(index < count)
        [adapter scrollToIndex:index view:c];
}

@end
