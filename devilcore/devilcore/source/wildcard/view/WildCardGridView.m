//
//  WildCardGridView.m
//  CloudJsonViewer
//
//  Created by Mu Young Ko on 2018. 6. 21..
//  Copyright © 2018년 Mu Young Ko. All rights reserved.
//

#import "WildCardGridView.h"
#import "WildCardConstructor.h"


@implementation WildCardGridView


- (id)init
{
    self = [super init];
    if (self) {
        self.cachedFreeViewByType = [[NSMutableDictionary alloc] init];
        self.typeByUsedView = [[NSMutableDictionary alloc] init];
        self.lineViews = [[NSMutableArray alloc] init];
        self.lineWidth = 0;
        self.outerWidth = 0;
        self.lineColor = [UIColor colorWithRed:0.9f green:0.9f blue:0.9f alpha:1.0f];
    }
    return self;
}

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        self.cachedFreeViewByType = [[NSMutableDictionary alloc] init];
        self.typeByUsedView = [[NSMutableDictionary alloc] init];
        self.lineViews = [[NSMutableArray alloc] init];
        self.lineWidth = 0;
        self.outerWidth = 0;
        self.lineColor = [UIColor colorWithRed:0.9f green:0.9f blue:0.9f alpha:1.0f];
    }
    return self;
}

- (void)setInnerLine:(BOOL)line
{
    if(line)
        self.lineWidth = 1;
    else
        self.lineWidth = 0;
}

- (CGRect) reloadData
{
    int len = (int)[_data count];
    int selfWidth = self.frame.size.width;
    float w = selfWidth / _col;
    _row = 0;
    float rowW = 0;
    float rowH = 0;
    
    for(UIView* line in _lineViews)
    {
        [line removeFromSuperview];
    }
    [_lineViews removeAllObjects];
    
    int i=0;
    for(i=0;i<len;i++)
    {
        NSMutableDictionary* item = [_data objectAtIndex:i];
        
        NSDictionary* cloudJson = _cloudJsonGetter(i);
        NSString* thisType = _typeGetter(i);
        UIView* thisView = nil;
        if(i < [[self subviews] count])
        {
            UIView* thisChildView = [[self subviews] objectAtIndex:i];
            NSString* objectKey = [NSString stringWithFormat:@"%p", thisChildView];
            NSString* thisChildViewType = [_typeByUsedView objectForKey:objectKey];
            if([thisChildViewType isEqualToString:thisType])
            {
                thisView = thisChildView;
            }
            else
            {
                NSMutableArray* cacheList = [_cachedFreeViewByType objectForKey:thisChildViewType];
                if(cacheList == nil)
                {
                    cacheList = [[NSMutableArray alloc] init];
                    [_cachedFreeViewByType setObject:cacheList forKey:thisChildViewType];
                }
                [cacheList addObject:thisChildView];
                [thisChildView removeFromSuperview];
            }
        }
        
        //first col
        if(i % _col == 0)
        {
            _row++;
        }
        
        if(thisView == nil)
        {
            NSMutableArray* cacheList = [_cachedFreeViewByType objectForKey:thisType];
            if(cacheList == nil)
            {
                cacheList = [[NSMutableArray alloc] init];
                [_cachedFreeViewByType setObject:cacheList forKey:thisType];
            }
            
            if([cacheList count] > 0)
            {
                thisView = [cacheList objectAtIndex:0];
                [cacheList removeObjectAtIndex:0];
            }
            else {
                thisView = [WildCardConstructor constructLayer:nil withLayer:cloudJson withParentMeta:_meta depth:_depth  instanceDelegate:_meta.wildCardConstructorInstanceDelegate];
                NSString* objectKey = [NSString stringWithFormat:@"%p", thisView];
                [_typeByUsedView setObject:thisType forKey:objectKey];
            }
            [self insertSubview:thisView atIndex:i];
        }
        
        float x = i%_col * w;
        float y = i/_col * rowH;
        float thisW = w;
        if(i % _col == _col-1)
            thisW = selfWidth - w*(_col-1);
        thisView.frame = CGRectMake(x, y, thisW, thisView.frame.size.height);
        
        if(rowW == 0)
        {
            rowW = thisView.frame.size.width;
            rowH = thisView.frame.size.height;
        }
        
        [WildCardConstructor applyRule:(WildCardUIView*)thisView withData:item];
    }
    
    for(;i<[[self subviews] count];i++) {
        UIView* remove = [self subviews][i];
        [remove removeFromSuperview];
    }
    
    self.frame = CGRectMake(self.frame.origin.x,
                            self.frame.origin.y,
                            self.frame.size.width,
                            rowH*_row);

    if(_lineWidth > 0)
    {
        for(int i=1;i<_col;i++)
        {
            UIView* line = [[UIView alloc] init];
            line.backgroundColor = _lineColor;
            line.frame = CGRectMake(rowW*i, 0 , _lineWidth, self.frame.size.height);
            [self addSubview:line];
            [_lineViews addObject:line];
        }
        
        for(int i=1;i<_row;i++)
        {
            UIView* line = [[UIView alloc] init];
            line.backgroundColor = _lineColor;
            line.frame = CGRectMake(0, rowH*i, self.frame.size.width, _lineWidth);
            [self addSubview:line];
            [_lineViews addObject:line];
        }
    }
    
    if(_outerWidth > 0)
    {
        {
            UIView* line = [[UIView alloc]  initWithFrame:CGRectMake(0,0,self.frame.size.width, _lineWidth)];
            line.backgroundColor = _lineColor;
            [self addSubview:line];
            [_lineViews addObject:line];
        }
        {
            UIView* line = [[UIView alloc]  initWithFrame:CGRectMake(0,0,_lineWidth, self.frame.size.height)];
            line.backgroundColor = _lineColor;
            [self addSubview:line];
            [_lineViews addObject:line];
        }
        {
            UIView* line = [[UIView alloc]  initWithFrame:CGRectMake(self.frame.size.width - _lineWidth, 0, _lineWidth , self.frame.size.height)];
            line.backgroundColor = _lineColor;
            [self addSubview:line];
            [_lineViews addObject:line];
        }
        {
            UIView* line = [[UIView alloc]  initWithFrame:CGRectMake(0, self.frame.size.height - _lineWidth, self.frame.size.width, _lineWidth)];
            line.backgroundColor = _lineColor;
            [self addSubview:line];
            [_lineViews addObject:line];
        }
    }
        
    
    
    
    return self.frame;
}

@end
