//
//  WildCardGridView.m
//  CloudJsonViewer
//
//  Created by Mu Young Ko on 2018. 6. 21..
//  Copyright © 2018년 Mu Young Ko. All rights reserved.
//

#import "WildCardGridView.h"
#import "WildCardConstructor.h"

#define LEN 15

@interface WildCardGridView()
{
    BOOL lineRow[LEN][LEN];
    BOOL lineCol[LEN][LEN];
    CGColorRef lineRowColor[LEN][LEN];
    CGColorRef lineColColor[LEN][LEN];
    
    BOOL innerLine;
    BOOL outerLine;
    int lineWidth;
    int outerWidth;
    
    float colW;
    float rowH;
}
@end

@implementation WildCardGridView


- (id)init
{
    self = [super init];
    if (self) {
        self.cachedFreeViewByType = [[NSMutableDictionary alloc] init];
        self.typeByUsedView = [[NSMutableDictionary alloc] init];
        self.lineViews = [[NSMutableArray alloc] init];
        lineWidth = 0;
        outerWidth = 0;
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
        lineWidth = 0;
        outerWidth = 0;
        self.lineColor = [UIColor colorWithRed:0.9f green:0.9f blue:0.9f alpha:1.0f];
    }
    return self;
}

- (void)setInnerLine:(BOOL)line
{
    if(line)
        lineWidth = 1;
    else
        lineWidth = 0;
    innerLine = line;
}

- (void)setOuterLine:(BOOL)line
{
    if(line)
        outerWidth = 1;
    else
        outerWidth = 0;
    outerLine = line;
}

- (void)clearLineInfo {
    for(int i=0;i<_row+1;i++) {
        for(int j=0;j<_col+1;j++) {
            lineCol[i][j] = lineRow[i][j] = false;
        }
    }
}

- (CGRect) reloadData
{
    int len = (int)[_data[@"length"] toInt32];
    int selfWidth = self.frame.size.width;
    float w = selfWidth / _col;
    _row = len / _col +  (len%_col > 0 ? 1 : 0);
    colW = 0;
    rowH = 0;
    
    if(innerLine || outerLine)
        [self clearLineInfo];
        
    for(UIView* line in _lineViews)
    {
        [line removeFromSuperview];
    }
    [_lineViews removeAllObjects];
    
    int i=0;
    for(i=0;i<len;i++)
    {
        JSValue* item = _data[i];
        
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
        
        if(colW == 0)
        {
            colW = thisView.frame.size.width;
            rowH = thisView.frame.size.height;
        }
        
        [WildCardConstructor applyRule:(WildCardUIView*)thisView withData:item];
        
        [self lineCheck:(WildCardUIView*)thisView : i];
    }
    
    id shouldRemove = [@[] mutableCopy];
    for(;i<[[self subviews] count];i++) {
        UIView* remove = [self subviews][i];
        [shouldRemove addObject:remove];
        [self lineCheck:nil : i];
    }
    for(id remove in shouldRemove)
        [remove removeFromSuperview];
    
    self.frame = CGRectMake(self.frame.origin.x,
                            self.frame.origin.y,
                            self.frame.size.width,
                            rowH*_row);

    for(int i=0;i<_row+1;i++){
        for(int j=0;j<_col;j++){
            if(lineRow[i][j])
                [self drawLineRow:i:j];
        }
    }
    
    for(int i=0;i<_row;i++){
        for(int j=0;j<_col+1;j++){
            if(lineCol[i][j])
                [self drawLineCol:i:j];
        }
    }
    
    return self.frame;
}

-(void)drawLineRow:(int)row:(int)col {
    UIView* line = [[UIView alloc] init];
    line.backgroundColor = [[UIColor alloc] initWithCGColor:lineRowColor[row][col]];
    line.frame = CGRectMake(colW*col, rowH*row, colW, lineWidth);
    [self addSubview:line];
    [_lineViews addObject:line];
}

-(void)drawLineCol:(int)row:(int)col {
    UIView* line = [[UIView alloc] init];
    line.backgroundColor = [[UIColor alloc] initWithCGColor:lineColColor[row][col]];
    line.frame = CGRectMake(colW*col, rowH*row, lineWidth, rowH);
    [self addSubview:line];
    [_lineViews addObject:line];
}

-(void)lineCheck:(WildCardUIView*)v :(int)i {
    
    if(!innerLine && !outerLine) {
        return;
    }
    
    int rowIndex = i / _col;
    int colIndex = i % _col;
    
    //TODO outer에 대해 체크 해야함
    if(v == nil) {
        lineRow[rowIndex][colIndex] = true;
        lineRow[rowIndex+1][colIndex] = false;
        lineCol[rowIndex][colIndex] = rowIndex == 0?false:true;
        lineCol[rowIndex][colIndex+1] = false;
    } else {
        lineRow[rowIndex][colIndex] = true;
        lineRow[rowIndex+1][colIndex] = true;
        lineCol[rowIndex][colIndex] = true;
        lineCol[rowIndex][colIndex+1] = true;
    }
    
    bool cellLine = (v.layer.borderWidth > 0 || v.tags[@"hideBorder"]) && v.layer.borderColor;// 셀 라인인 경우
    CGColorRef c;
    if(cellLine) {
        c = v.layer.borderColor;
        v.layer.borderWidth = 0;
        v.tags[@"hideBorder"] = @TRUE;
    } else
        c = [self.lineColor CGColor];
    
    if(cellLine || rowIndex == 0)
        lineRowColor[rowIndex][colIndex] = c;
    lineRowColor[rowIndex+1][colIndex] = c;
    
    if(cellLine || colIndex == 0)
        lineColColor[rowIndex][colIndex] = c;
    lineColColor[rowIndex][colIndex+1] = c;
}

@end
