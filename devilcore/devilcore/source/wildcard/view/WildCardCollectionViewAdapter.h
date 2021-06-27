//
//  WildCardCollectionViewAdapter.h
//  CloudJsonViewer
//
//  Created by Mu Young Ko on 2018. 6. 20..
//  Copyright © 2018년 Mu Young Ko. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>

//typedef void (^ IteratorBlock)(id, int);

typedef NSString* (^ TypeGetter)(int);
typedef NSDictionary* (^ CloudJsonGetter)(int);
typedef void (^ ViewPagerSelected)(int);

@class WildCardMeta;
@class WildCardLCAnimatedPageControl;

@interface WildCardCollectionViewAdapter : NSObject<UIScrollViewDelegate,
    UICollectionViewDelegate ,
    UICollectionViewDataSource,
    UICollectionViewDelegateFlowLayout>
{
    ViewPagerSelected viewPagerSelected[10];
    int viewPagerSelectedIndex;
}
@property float margin;
@property int selectedIndex;
@property TypeGetter typeGetter;
@property CloudJsonGetter cloudJsonGetter;
@property (nonatomic, retain) NSArray* data;
@property (nonatomic, retain) UIPageControl* pageControl;

@property (nonatomic, retain) NSMutableDictionary* cachedViewByType;
@property (nonatomic, retain) NSString* repeatType;

@property void (^lastItemCallback)(id res);
@property void (^draggedCallback)(id res);

-(void)addViewPagerSelected:(ViewPagerSelected)func;

-(int)getIndex;
-(int)getCount;
-(void)scrollToIndex:(int)index view:(UICollectionView*)c;

@property (nonatomic, retain) WildCardMeta* meta;
@property int depth;

@property (nonatomic, weak) UICollectionView* collectionView;
@property float viewPagerStartPaddingX;
@property float viewPagerContentWidth;
@property float clipToPadding;

@end


