//
//  WildCardCollectionViewAdapter.h
//  CloudJsonViewer
//
//  Created by Mu Young Ko on 2018. 6. 20..
//  Copyright © 2018년 Mu Young Ko. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>
#define CELL_UNDER_WILDCARD 273123

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
@property (nonatomic, retain) NSMutableDictionary* visibleDataByIndexPath;
@property (nonatomic, retain) NSMutableDictionary* visibleDataStringByIndexPath;
@property (nonatomic, retain) NSString* repeatType;

@property void (^lastItemCallback)(id res);
@property void (^draggedCallback)(id res);
@property void (^scrolledCallback)(id res);
@property void (^viewPagerSelectedCallback)(int index);

@property BOOL autoSwipeViewPager;
-(void)autoSwipe:(BOOL)s;
-(void)addViewPagerSelected:(ViewPagerSelected)func;

-(int)getIndex;
-(int)getCount;
-(void)scrollToIndex:(int)index view:(UICollectionView*)c;
-(BOOL)shouldReload;

@property (nonatomic, retain) WildCardMeta* meta;
@property int depth;

@property (nonatomic, weak) UICollectionView* collectionView;
@property float viewPagerStartPaddingX;
@property float viewPagerContentWidth;
@property float clipToPadding;

@end


