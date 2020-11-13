//
//  WildCardLCAnimatedPageControl.h
//  CloudJsonViewer
//
//  Created by Mu Young Ko on 2018. 10. 18..
//  Copyright © 2018년 Mu Young Ko. All rights reserved.
//

#import <UIKit/UIKit.h>

typedef NS_ENUM(NSInteger, PageStyle){
    LCScaleColorPageStyle,
    LCSquirmPageStyle,
    LCDepthColorPageStyle,
    LCFillColorPageStyle,
};

@interface WildCardLCAnimatedPageControl : UIControl

@property (nonatomic, strong) UIScrollView *sourceScrollView;
@property (nonatomic, assign) NSInteger numberOfPages;
@property (nonatomic, strong) UIColor *pageIndicatorColor;
@property (nonatomic, strong) UIColor *currentPageIndicatorColor;
@property (nonatomic, assign) CGFloat indicatorMultiple;
@property (nonatomic, assign) CGFloat indicatorMargin;
@property (nonatomic, assign) CGFloat indicatorDiameter;
@property (nonatomic, assign) PageStyle pageStyle;
@property (nonatomic, assign, readonly) NSInteger currentPage;

- (void)prepareShow;
- (void)clearIndicators;

@end
