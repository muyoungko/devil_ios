//
//  WildCardGridView.h
//  CloudJsonViewer
//
//  Created by Mu Young Ko on 2018. 6. 21..
//  Copyright © 2018년 Mu Young Ko. All rights reserved.
//

#import <UIKit/UIKit.h>


@class WildCardMeta;


typedef NSString* (^ TypeGetter)(int);
typedef NSDictionary* (^ CloudJsonGetter)(int);

@interface WildCardGridView : UIView
@property (retain, nonatomic) UIColor* lineColor;


@property (nonatomic, retain) NSMutableDictionary* cachedFreeViewByType;
@property (nonatomic, retain) NSMutableDictionary* typeByUsedView;

@property (nonatomic, retain) NSMutableArray* lineViews;

@property int col;
@property int row;

@property TypeGetter typeGetter;
@property CloudJsonGetter cloudJsonGetter;
@property (nonatomic, retain) NSArray* data;
@property (nonatomic, retain) WildCardMeta* meta;
@property int depth;

- (id)init;
- (id)initWithFrame:(CGRect)frame;
- (CGRect) reloadData;
- (void)setInnerLine:(BOOL)line;
- (void)setOuterLine:(BOOL)line;

@end

