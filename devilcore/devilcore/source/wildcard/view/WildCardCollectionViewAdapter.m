//
//  WildCardCollectionViewAdapter.m
//  CloudJsonViewer
//
//  Created by Mu Young Ko on 2018. 6. 20..
//  Copyright © 2018년 Mu Young Ko. All rights reserved.
//

#import "WildCardCollectionViewAdapter.h"
#import "WildCardConstructor.h"
#import "ReplaceRuleRepeat.h"
#import "MappingSyntaxInterpreter.h"
#import "WildCardUtil.h"

@implementation WildCardCollectionViewAdapter


- (instancetype)init
{
    self = [super init];
    if (self) {
        self.cachedViewByType = [[NSMutableDictionary alloc] init];
        viewPagerSelectedIndex = 0;
        _pageControl = nil;
        _selectedIndex = 0;
    }
    return self;
}


- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section
{
    if(_data == nil)
        return 0;
    return [_data count];
}



- (CGFloat)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout*)collectionViewLayout minimumLineSpacingForSectionAtIndex:(NSInteger)section
{
    return _margin;
}

- (CGFloat)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout*)collectionViewLayout minimumInteritemSpacingForSectionAtIndex:(NSInteger)section
{
    return _margin;
}

- (void)scrollViewDidScroll:(UIScrollView *)scrollView
{
    //NSLog(@"scrollViewDidScroll");
}

-(void)addViewPagerSelected:(ViewPagerSelected)func
{
    if(viewPagerSelectedIndex<10)
        viewPagerSelected[viewPagerSelectedIndex++] = func;
}

- (void)scrollViewDidEndScrollingAnimation:(UIScrollView *)scrollView
{
    
}

- (void)scrollViewWillBeginDragging:(UIScrollView *)scrollView{
    
}


- (void)scrollViewWillEndDragging:(UIScrollView *)scrollView withVelocity:(CGPoint)velocity targetContentOffset:(inout CGPoint *)targetContentOffset
{
    
    float w = scrollView.frame.size.width;
    float offset = targetContentOffset->x;
    
    //뷰페이저
    float start = self.viewPagerStartPaddingX;
    float contentWidth = self.viewPagerContentWidth;
    if(self.collectionView){
        targetContentOffset->x = scrollView.contentOffset.x;
        int newIndex = _selectedIndex;
        if(velocity.x > 0.5 || velocity.x < -0.5){
            int sindex = (scrollView.contentOffset.x - start + contentWidth/2) / contentWidth;
            int direction = velocity.x > 0.0 ? 1 : -1;
            int tobeIndex = sindex+direction;
            if(tobeIndex < 0 )
                tobeIndex = 0;
            else if(tobeIndex > [_data count] -1 )
                tobeIndex = [_data count] -1;
            newIndex = tobeIndex;
            float tobe = -start + contentWidth*(tobeIndex);
            [UIView animateWithDuration:0.3 delay:0 options:UIViewAnimationOptionAllowUserInteraction animations:^{
                scrollView.contentOffset = CGPointMake(tobe, 0);
                [scrollView layoutIfNeeded];
            } completion:nil];
        }
        else
        {
            int sindex = (offset - start + contentWidth/2) / contentWidth;
            newIndex = sindex;
            [self.collectionView scrollToItemAtIndexPath:[NSIndexPath indexPathForRow:sindex inSection:0] atScrollPosition:UICollectionViewScrollPositionCenteredHorizontally animated:YES];
        }
        
        _selectedIndex = newIndex;
        NSLog(@"scrollViewWillEndDragging %d", _selectedIndex);
        for(int i=0;i<viewPagerSelectedIndex;i++)
        {
            @try{
                viewPagerSelected[i](_selectedIndex);
            }@catch(NSException* e)
            {
                NSLog(@"%@" , e);
            }
        }
    }
}

-(void)scrollToIndex:(int)index view:(UICollectionView*)c
{
    NSIndexPath* path = [NSIndexPath indexPathForRow:index inSection:0];
    [c scrollToItemAtIndexPath:path atScrollPosition:UICollectionViewScrollPositionCenteredVertically | UICollectionViewScrollPositionCenteredHorizontally animated:YES];
    _selectedIndex = index;
    
    for(int i=0;i<viewPagerSelectedIndex;i++)
    {
        @try{
            viewPagerSelected[i](index);
        }@catch(NSException* e)
        {
            NSLog(@"%@" , e);
        }
    }
}

-(int)getCount
{
    if(_data == nil)
        return 0;
    return [_data count];
}

-(int)getIndex
{
    return _selectedIndex;
}


-(float) mesureWidth:(NSMutableDictionary*)cloudJson data:(NSMutableDictionary*)data
{
    float w = [cloudJson[@"frame"][@"w"] floatValue];
    if(w == -2)
    {
        w = 0;
        //TODO 가변 텍스트에 의한 가변 높이는 성능상 이슈로 아직 구현 못함
        if(cloudJson[@"arrayContent"] != nil && [cloudJson[@"arrayContent"][@"repeatType"] isEqualToString:REPEAT_TYPE_RIGHT])
        {
            NSMutableDictionary* arrayContent = cloudJson[@"arrayContent"];
            NSString* repeatType = arrayContent[@"repeatType"];
            NSString* targetNode = [arrayContent objectForKey:@"targetNode"];
            NSArray* childLayers = [cloudJson objectForKey:@"layers"];
            NSDictionary* targetLayer = nil;
            NSDictionary* targetLayerSurfix = nil;
            NSDictionary* targetLayerPrefix = nil;
            NSDictionary* targetLayerSelected = nil;
            NSString* targetNodeSurfix = [arrayContent objectForKey:@"targetNodeSurfix"];
            NSString* targetNodePrefix = [arrayContent objectForKey:@"targetNodePrefix"];
            NSString* targetNodeSelected = [arrayContent objectForKey:@"targetNodeSelected"];
            NSString* targetNodeSelectedIf = [arrayContent objectForKey:@"targetNodeSelectedIf"];
            NSString* targetJsonString = [arrayContent objectForKey:@"targetJson"];
            NSArray* targetDataJson = (NSArray*) [MappingSyntaxInterpreter
                                                  getJsonWithPath:data : targetJsonString];
            long targetDataJsonLen = [targetDataJson count];
            
            for(int i=0;i<[childLayers count];i++)
            {
                NSDictionary* childLayer = [childLayers objectAtIndex:i];
                if([targetNode isEqualToString:[childLayer objectForKey:@"name"]])
                {
                    targetLayer = childLayer;
                }
                else if(targetNodePrefix == nil && [targetNodePrefix isEqualToString:[childLayer objectForKey:@"name"]])
                {
                    targetLayerPrefix = childLayer;
                }
                else if(targetNodeSurfix != nil && [targetNodeSurfix isEqualToString:[childLayer objectForKey:@"name"]])
                {
                    targetLayerSurfix = childLayer;
                }
                else if(targetNodeSelected != nil && [targetNodeSelected isEqualToString:[childLayer objectForKey:@"name"]])
                {
                    targetLayerSelected = childLayer;
                }
            }
            if([repeatType isEqualToString:REPEAT_TYPE_RIGHT])
            {
                float thisW = [[[targetLayer objectForKey:@"frame"] objectForKey:@"w"] floatValue];
                w = targetDataJsonLen * thisW;
            }
        }
        else
        {
            NSMutableArray* arr = cloudJson[@"layers"];
            NSMutableDictionary* rects = [@{} mutableCopy];
            for(int i=0;i<[arr count];i++)
            {
                BOOL hidden = false;
                if(arr[i][@"hiddenCondition"] != nil)
                    hidden = [MappingSyntaxInterpreter ifexpression:arr[i][@"hiddenCondition"] data:data];
                
                if(!hidden)
                {
                    NSString* name = arr[i][@"name"];
                    if(arr[i][@"textContent"] != nil)
                    {
                        NSString* text = [MappingSyntaxInterpreter interpret:arr[i][@"textContent"] : data];
                        NSDictionary* textSpec = [arr[i] objectForKey:@"textSpec"];
                        float textSize = [WildCardConstructor convertTextSize:[[textSpec objectForKey:@"textSize"] floatValue]];
                        
                        UIFont* font = nil;
                        if([[textSpec objectForKey:@"bold"] boolValue])
                            font = [UIFont boldSystemFontOfSize:textSize];
                        else
                            font = [UIFont systemFontOfSize:textSize];
                        
                        NSDictionary *attributes = @{NSFontAttributeName: font};
                        CGRect size = [text boundingRectWithSize:CGSizeMake(CGFLOAT_MAX, 100) options:NSStringDrawingUsesLineFragmentOrigin attributes:attributes context:nil];
                        w = size.size.width + [self getPaddingLeftRightConverted:arr[i]];
                        rects[name] = [NSValue valueWithCGRect:CGRectMake(0,0,w,0)];
                    }
                    else
                    {
                        float thisx = [arr[i][@"frame"][@"x"] floatValue];
                        float thisw = [self mesureWidth:arr[i] data:data];
                        rects[name] = [NSValue valueWithCGRect:CGRectMake(thisx, 0, thisw, 0)];
                        if(thisx + thisw > w)
                            w = thisx + thisw;
                    }
                }
            }
            
            //hNextTo로 인해 w가 늘어나는 경우를 탐지한다.
            //TODO : 줄어드는 경우는 탐지 못한다. hNextTo가 줄줄이 이어지는 경우도 탐지 못한다.
            for(int i=0;i<[arr count];i++) {
                NSString* hNextTo = arr[i][@"hNextTo"];
                if(hNextTo){
                    NSString* name = arr[i][@"name"];
                    float hNextToMargin = [arr[i][@"hNextToMargin"] floatValue];
                    float thisx = 0;
                    if(rects[hNextTo])
                        thisx = [rects[hNextTo] CGRectValue].origin.x + [rects[hNextTo] CGRectValue].size.width;
                    thisx += [WildCardConstructor convertSketchToPixel:hNextToMargin];
                    float thisw = [rects[name] CGRectValue].size.width;
                    if(thisx + thisw > w)
                        w = thisx + thisw;
                }
            }
        }
    }
    else
    {
        w = [WildCardConstructor convertSketchToPixel:w];
    }
    return w + [self getPaddingLeftRightConverted:cloudJson];
}

- (float)getPaddingLeftRightConverted:(id)layer{
    float paddingLeft = 0 , paddingRight = 0;
    if([layer objectForKey:@"padding"] != nil) {
        NSDictionary* padding = [layer objectForKey:@"padding"];
        if([padding objectForKey:@"paddingLeft"] != nil) {
            paddingLeft = [[padding objectForKey:@"paddingLeft"] floatValue];
            paddingLeft = [WildCardConstructor convertSketchToPixel:paddingLeft];
        }
        
        if([padding objectForKey:@"paddingRight"] != nil) {
            paddingRight = [[padding objectForKey:@"paddingRight"] floatValue];
            paddingRight = [WildCardConstructor convertSketchToPixel:paddingRight];
        }
    }
    return paddingLeft + paddingRight;
}



- (CGSize)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout*)collectionViewLayout sizeForItemAtIndexPath:(NSIndexPath *)indexPath
{
    int position = (int)[indexPath row];
    NSDictionary *cloudJson = _cloudJsonGetter(position);
    
    if([REPEAT_TYPE_VLIST isEqualToString:self.repeatType]){
        float h = [WildCardUtil mesureHeight:cloudJson data:_data[position]];
        return CGSizeMake(collectionView.frame.size.width, h);
    } else {
        float w = [self mesureWidth:cloudJson data:_data[position]];
        return CGSizeMake(w, collectionView.frame.size.height);
    }
}


- (void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath
{
    
}


- (__kindof UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath
{
    int position = (int)[indexPath row];
    
    NSMutableDictionary* item = [_data objectAtIndex:position];
    NSString* type = _typeGetter(position);
    UICollectionViewCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:type forIndexPath:indexPath];
     
    UIView* childUIView = cell;
    if ([[[UIDevice currentDevice] systemVersion] floatValue] >= 14.0) {
        childUIView = cell;
    } else {
        childUIView = [[cell subviews] objectAtIndex:0];
    }
    if([[childUIView subviews] count] == 0)
    {
        NSDictionary *cloudJson = _cloudJsonGetter(position);
        WildCardUIView* v = [WildCardConstructor constructLayer:childUIView withLayer:cloudJson withParentMeta:_meta depth:_depth instanceDelegate:_meta.wildCardConstructorInstanceDelegate];
        v.userInteractionEnabled = YES;
        
        if([REPEAT_TYPE_VLIST isEqualToString:self.repeatType] || [REPEAT_TYPE_BOTTOM isEqualToString:self.repeatType])
            v.frame = CGRectMake(v.frame.origin.x, 0, v.frame.size.width, v.frame.size.height);
        else if([REPEAT_TYPE_GRID isEqualToString:self.repeatType] || [REPEAT_TYPE_VIEWPAGER isEqualToString:self.repeatType])
                v.frame = CGRectMake(0, 0, v.frame.size.width, v.frame.size.height);
        else
            v.frame = CGRectMake(0, v.frame.origin.y, v.frame.size.width, v.frame.size.height);
    }
    
    WildCardUIView *v = [[childUIView subviews] objectAtIndex:0];
    [WildCardConstructor applyRule:v withData:item];
    return cell;
}


@end
