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
#import "WildCardUICollectionView.h"
#import "DevilExceptionHandler.h"
#import "DevilLang.h"

@interface WildCardCollectionViewAdapter()

@property (nonatomic, retain) WildCardUICollectionView* c;
@property (nonatomic, retain) NSTimer *timer;
@property int lastDataCount;
@property BOOL readyToCallScrollEnd;


@end

@implementation WildCardCollectionViewAdapter


- (instancetype)init
{
    self = [super init];
    if (self) {
        self.cachedViewByType = [[NSMutableDictionary alloc] init];
        self.visibleDataByIndexPath = [[NSMutableDictionary alloc] init];
        self.visibleDataStringByIndexPath = [[NSMutableDictionary alloc] init];
        self.lastDataCount = 0;
        self.readyToCallScrollEnd = NO;
        viewPagerSelectedIndex = 0;
        _pageControl = nil;
        _selectedIndex = 0;
    }
    return self;
}


- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section
{
    self.c = (WildCardUICollectionView*)collectionView;
    if(section == 0){
        return [self getCount];
    } else {
        return 1;
    }
}

- (NSInteger)numberOfSectionsInCollectionView:(UICollectionView *)collectionView{
    return 2;
}

- (CGFloat)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout*)collectionViewLayout minimumLineSpacingForSectionAtIndex:(NSInteger)section
{
    return _margin;
}

- (CGFloat)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout*)collectionViewLayout minimumInteritemSpacingForSectionAtIndex:(NSInteger)section
{
    return _margin;
}

-(void)addViewPagerSelected:(ViewPagerSelected)func
{
    if(viewPagerSelectedIndex<10)
        viewPagerSelected[viewPagerSelectedIndex++] = func;
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
    if(_infinite)
        return [_data[@"length"] toInt32];
    return [_data[@"length"] toInt32];
}

-(int)getIndex
{
    return _selectedIndex % [self getCount];
}



- (CGSize)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout*)collectionViewLayout sizeForItemAtIndexPath:(NSIndexPath *)indexPath
{
    if(indexPath.section == 0) {
        int position = (int)[indexPath row];
        if(_infinite)
            position = position % [self getCount];
        if(position >= [self getCount])
            return CGSizeMake(collectionView.frame.size.width, 0);
        
        NSDictionary *cloudJson = _cloudJsonGetter(position);
        
        if([REPEAT_TYPE_VLIST isEqualToString:self.repeatType]){
            float h = [WildCardUtil measureHeight:cloudJson data:_data[position]];
            float w = [WildCardUtil measureWidth:cloudJson data:_data[position]];
            if(w > collectionView.frame.size.width * 0.6)
                w = collectionView.frame.size.width;
            return CGSizeMake(w, h);
        } else {
            float w = [WildCardUtil measureWidth:cloudJson data:_data[position]];
            return CGSizeMake(w, collectionView.frame.size.height);
        }
    } else {
        if([REPEAT_TYPE_VLIST isEqualToString:self.repeatType]){
            float h = self.clipToPadding;
            return CGSizeMake(collectionView.frame.size.width, h);
        } else {
            float w = self.clipToPadding;
            return CGSizeMake(w, collectionView.frame.size.height);
        }
    }
}


- (void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath
{
    
}


- (__kindof UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath
{
    if(indexPath.section == 0) {
        int position = (int)[indexPath row];
        
        if(_infinite)
            position = position % [self getCount];
        
        if(position >= [self getCount])
            return [collectionView dequeueReusableCellWithReuseIdentifier:@"0" forIndexPath:indexPath];
        
        JSValue* item = _data[position];
        NSString* type = _typeGetter(position);
        UICollectionViewCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:type forIndexPath:indexPath];
        cell.tag = position;
        UIView* childUIView = cell;
        if ([[[UIDevice currentDevice] systemVersion] floatValue] >= 14.0) {
            childUIView = cell;
        } else {
            childUIView = [[cell subviews] objectAtIndex:0];
        }
        
        @try{
            if([[childUIView subviews] count] == 0)
            {
                NSDictionary *cloudJson = _cloudJsonGetter(position);
                WildCardUIView* v = [WildCardConstructor constructLayer:childUIView withLayer:cloudJson withParentMeta:_meta depth:_depth instanceDelegate:_meta.wildCardConstructorInstanceDelegate];
                //v.userInteractionEnabled = YES;
                
                if([REPEAT_TYPE_VLIST isEqualToString:self.repeatType] || [REPEAT_TYPE_BOTTOM isEqualToString:self.repeatType])
                    v.frame = CGRectMake(v.frame.origin.x, 0, v.frame.size.width, v.frame.size.height);
                else if([REPEAT_TYPE_GRID isEqualToString:self.repeatType] || [REPEAT_TYPE_VIEWPAGER isEqualToString:self.repeatType])
                    v.frame = CGRectMake(0, 0, v.frame.size.width, v.frame.size.height);
                else
                    v.frame = CGRectMake(0, v.frame.origin.y, v.frame.size.width, v.frame.size.height);
                
                v.tag = CELL_UNDER_WILDCARD;
            }
            
            WildCardUIView *v = [[childUIView subviews] objectAtIndex:0];
            [WildCardConstructor applyRule:v withData:item];
            
            if(self.readyToCallScrollEnd && self.lastItemCallback != nil && [indexPath row] == [self getCount]-1) {
                self.readyToCallScrollEnd = NO;
                self.lastItemCallback(nil);
            }
            
            if(indexPath.section == 0) {
                self.visibleDataByIndexPath[[NSNumber numberWithInt:(int)indexPath.row]] = self.data[position];
                self.visibleDataStringByIndexPath[[NSNumber numberWithInt:(int)position]] = [NSString stringWithFormat:@"%@", [self.data[position] toDictionary]];
                
                self.lastDataCount = [self getCount];
            }
            
            if(self.cellUpdateCallback)
                self.cellUpdateCallback(position);
        }@catch(NSException* e){
            [DevilExceptionHandler handle:e];
        }
        
        return cell;
    } else {
        UICollectionViewCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:@"FOOTER" forIndexPath:indexPath];
        return cell;
    }
}

/**
 data의 각 아이템 주소가 바뀐경우 무조건 변경되어야함
 */
- (BOOL)shouldReload {
    
    id index_path_list = [self.collectionView indexPathsForVisibleItems];
    
    BOOL allVisibleSame = [index_path_list count] > 0 ? YES : NO;
    BOOL atLeastOneCompared = NO;
    for(NSIndexPath* index in index_path_list) {
        if(index.section > 0)
            continue;
        
        atLeastOneCompared = YES;
        if(index.row < [self getCount]) {
            NSNumber* key = [NSNumber numberWithInt:(int)index.row];
            /**
             데이터를 문자로 변환해서 검사해야 변경 증분을 알수가 있다
             */
            id alreadyString = self.visibleDataStringByIndexPath[key];
            id alreadyItem = self.visibleDataByIndexPath[key];
            if(!alreadyString) {
                allVisibleSame = NO;
                break;
            }
            
            NSString* a = alreadyString;
            NSString* b = [NSString stringWithFormat:@"%@", [self.data[(int)index.row] toDictionary]];
            if(![a isEqualToString:b]) {
                allVisibleSame = NO;
                break;
            }
            
            NSString* aa = [NSString stringWithFormat:@"%u", alreadyItem];
            NSString* bb = [NSString stringWithFormat:@"%u", self.data[(int)index.row]];
            if(![aa isEqualToString:bb]) {
                allVisibleSame = NO;
                break;
            }
        } else {
            allVisibleSame = NO;
            break;
        }
    }
    
    BOOL r = allVisibleSame && atLeastOneCompared ? NO : YES;
    if(self.lastDataCount != [self.data[@"length"] toInt32])
        r = YES;
    
    return r;
}

- (BOOL)accessibilityScroll:(UIAccessibilityScrollDirection)direction
{
    if(direction == UIAccessibilityScrollDirectionUp){
        [self.c asyncScrollTo:0:true];
        [self accessibilityDecrement];
        NSLog(@"Accessibility Scroll Captured YES");
        return YES;
    } else if(direction == UIAccessibilityScrollDirectionDown){
        [self.c asyncScrollTo:[self getCount]-1:true];
        [self accessibilityIncrement];
        NSLog(@"Accessibility Scroll Captured YES");
        return YES;
    } else {
        NSLog(@"Accessibility Scroll Captured NO");
        return NO;
    }
}
    
-(void)autoSwipe:(BOOL)s{
    if(s) {
        if(!self.timer)
            self.timer = [NSTimer scheduledTimerWithTimeInterval:3 target:self selector:@selector(swipe) userInfo:nil repeats:YES];
    } else {
        if(self.timer)
            [self.timer invalidate];
        self.timer = nil;
    }
        
}

- (void)swipe {
    int count = [self getCount];
    int index = [self getIndex];
    index ++;
    if(index >= count)
        index = 0;
    
    UIResponder* responder = [self.collectionView nextResponder];
    BOOL active = NO;
    while (responder != nil) {
        if ([responder isKindOfClass:[UIViewController class]]) {
            UIViewController* vc = (UIViewController*)responder;
            if(vc.navigationController.topViewController == vc) {
                active = YES;
            }
        }
        responder = [responder nextResponder];
    }
    
    if(active)
        [self scrollToIndex:index view:self.collectionView];
}




//사용자에의한 콜
- (void)scrollViewWillBeginDragging:(UIScrollView *)scrollView {
    if(self.scrolledCallback)
        self.scrolledCallback(scrollView);
    self.readyToCallScrollEnd = YES;
}

//프로그램에 의한 스크롤 콜
- (void)scrollViewDidScroll:(UIScrollView *)scrollView
{
    if(self.scrolledCallback)
        self.scrolledCallback(scrollView);
    
}

//프로그램에 의한 스크롤 콜
- (void)scrollViewDidEndScrollingAnimation:(UIScrollView *)scrollView
{
    //NSLog(@"scrollViewDidEndScrollingAnimation");
//    if(self.draggedCallback != nil) {
//        self.draggedCallback(nil);
//    }
}

/**
 사용자에의 한 콜, fling할때
 */
- (void)scrollViewDidEndDecelerating:(UIScrollView *)scrollView{
    //NSLog(@"scrollViewDidEndDecelerating");
    if(self.draggedCallback != nil) {
        self.draggedCallback(nil);
    }
}

/**
 사용자에의한 콜 스크롤로  fling하지 않고 조용히 놓기
 */
- (void)scrollViewDidEndDragging:(UIScrollView *)scrollView willDecelerate:(BOOL)decelerate {
    //NSLog(@"scrollViewDidEndDragging");
    if(!decelerate) {
        if(self.draggedCallback != nil) {
            self.draggedCallback(nil);
        }
    }
}

/**
 사용자에의한 콜
 */
- (void)scrollViewWillEndDragging:(UIScrollView *)scrollView withVelocity:(CGPoint)velocity targetContentOffset:(inout CGPoint *)targetContentOffset
{
    
    float w = scrollView.frame.size.width;
    float offset = targetContentOffset->x;
    
    //뷰페이저
    float start = self.viewPagerStartPaddingX;
    float contentWidth = self.viewPagerContentWidth;
    if(self.collectionView && [self.repeatType isEqualToString:REPEAT_TYPE_VIEWPAGER]){
        targetContentOffset->x = scrollView.contentOffset.x;
        int newIndex = _selectedIndex;
        if(velocity.x > 0.5 || velocity.x < -0.5){
            int sindex = (scrollView.contentOffset.x - start + contentWidth/2) / contentWidth;
            int direction = velocity.x > 0.0 ? 1 : -1;
            int tobeIndex = sindex+direction;
            if(tobeIndex < 0 )
                tobeIndex = 0;
            else if(!_infinite && tobeIndex > [self getCount] -1 )
                tobeIndex = [self getCount] -1;
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
                viewPagerSelected[i](_selectedIndex % [self getCount]);
                
                if(self.viewPagerSelectedCallback)
                    self.viewPagerSelectedCallback(_selectedIndex % [self getCount]);
                
            }@catch(NSException* e)
            {
                NSLog(@"%@" , e);
            }
        }
    }
}



@end
 
