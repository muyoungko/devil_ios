//
//  WildCardPagerTabStrip.h
//  devilcore
//
//  Created by Mu Young Ko on 2021/01/23.
//

#import <UIKit/UIKit.h>
#import "WildCardPagerTabStripCell.h"

typedef NS_ENUM(NSUInteger, XLPagerScroll) {
    XLPagerScrollNO,
    XLPagerScrollYES,
    XLPagerScrollOnlyIfOutOfScreen
};

typedef NS_ENUM(NSUInteger, XLSelectedBarAlignment) {
    XLSelectedBarAlignmentLeft,
    XLSelectedBarAlignmentCenter,
    XLSelectedBarAlignmentRight,
    XLSelectedBarAlignmentProgressive
};

typedef NS_ENUM(NSUInteger, XLPagerTabStripDirection) {
    XLPagerTabStripDirectionLeft,
    XLPagerTabStripDirectionRight,
    XLPagerTabStripDirectionNone
};


NS_ASSUME_NONNULL_BEGIN

@interface WildCardPagerTabStrip : UICollectionView<UICollectionViewDelegate, UICollectionViewDataSource, UIScrollViewDelegate>

@property (copy) void (^changeCurrentIndexProgressiveBlock)(WildCardPagerTabStripCell* oldCell, WildCardPagerTabStripCell *newCell, CGFloat progressPercentage, BOOL indexWasChanged, BOOL fromCellRowAtIndex);
@property (copy) void (^changeCurrentIndexBlock)(WildCardPagerTabStripCell* oldCell, WildCardPagerTabStripCell *newCell, BOOL animated);

@property (readonly, nonatomic) UIView * selectedBar;
@property (nonatomic) CGFloat selectedBarHeight;
@property (nonatomic) XLSelectedBarAlignment selectedBarAlignment;
@property (nonatomic) BOOL shouldCellsFillAvailableWidth;

@property float textSize;
@property UIColor* textColor;
@property float selectedTextSize;
@property UIColor* selectedTextColor;
@property NSUInteger leftRightMargin;

@property (nonatomic, retain) NSMutableArray* list;
@property (nonatomic, retain) NSString* jsonPath;
@property (nonatomic, retain) UICollectionView* viewPager;

-(void)moveToIndex:(NSUInteger)index animated:(BOOL)animated swipeDirection:(XLPagerTabStripDirection)swipeDirection pagerScroll:(XLPagerScroll)pagerScroll;

-(void)moveFromIndex:(NSInteger)fromIndex toIndex:(NSInteger)toIndex withProgressPercentage:(CGFloat)progressPercentage pagerScroll:(XLPagerScroll)pagerScroll;


@end

NS_ASSUME_NONNULL_END
