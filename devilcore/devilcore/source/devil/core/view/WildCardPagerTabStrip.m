//
//  XLButtonBarView.m
//  XLPagerTabStrip ( https://github.com/xmartlabs/XLPagerTabStrip )
//
//  Copyright (c) 2015 Xmartlabs ( http://xmartlabs.com )
//
//
// Permission is hereby granted, free of charge, to any person obtaining a copy
// of this software and associated documentation files (the "Software"), to deal
// in the Software without restriction, including without limitation the rights
// to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
// copies of the Software, and to permit persons to whom the Software is
// furnished to do so, subject to the following conditions:
//
// The above copyright notice and this permission notice shall be included in
// all copies or substantial portions of the Software.
//
// THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
// IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
// FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
// AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
// LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
// OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN
// THE SOFTWARE.

#import "WildCardPagerTabStrip.h"
#import "MappingSyntaxInterpreter.h"
#import "WildCardCollectionViewAdapter.h"
#import "WildCardUITapGestureRecognizer.h"

@interface WildCardPagerTabStrip ()

@property UIView * selectedBar;
@property NSUInteger selectedOptionIndex;
@property int currentIndex;
@property BOOL isProgressiveIndicator;
@property (nonatomic) NSArray *cachedCellWidths;
@property (nonatomic) BOOL isViewAppearing;
@property (nonatomic) BOOL isViewRotating;

@end

@implementation WildCardPagerTabStrip



- (instancetype)initWithCoder:(NSCoder *)coder
{
    self = [super initWithCoder:coder];
    if (self) {
        [self initializeXLButtonBarView];
    }
    return self;
}

- (instancetype)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        [self initializeXLButtonBarView];
    }
    return self;
}

- (instancetype)initWithFrame:(CGRect)frame collectionViewLayout:(UICollectionViewLayout *)layout
{
    self = [super initWithFrame:frame collectionViewLayout:layout];
    if (self) {
        [self initializeXLButtonBarView];
    }
    return self;
}


-(void)initializeXLButtonBarView
{
    _selectedOptionIndex = 0;
    _selectedBarHeight = 5;
    _currentIndex = 0;
    if ([self.selectedBar superview] == nil){
        [self addSubview:self.selectedBar];
    }
    
    self.selectedBar.backgroundColor = [UIColor clearColor];
    self.autoresizingMask = UIViewAutoresizingFlexibleWidth;
    
    [self registerClass:[WildCardPagerTabStripCell class] forCellWithReuseIdentifier:@"Cell"];
    
    self.delegate = self;
    self.dataSource = self;
}


-(void)moveToIndex:(NSUInteger)index animated:(BOOL)animated swipeDirection:(XLPagerTabStripDirection)swipeDirection pagerScroll:(XLPagerScroll)pagerScroll
{
    self.selectedOptionIndex = index;
    [self updateSelectedBarPositionWithAnimation:animated swipeDirection:swipeDirection pagerScroll:pagerScroll];
}

-(void)moveFromIndex:(NSInteger)fromIndex toIndex:(NSInteger)toIndex withProgressPercentage:(CGFloat)progressPercentage pagerScroll:(XLPagerScroll)pagerScroll
{
    // First, calculate and set the frame of the 'selectedBar'
    
    self.selectedOptionIndex = (progressPercentage > 0.5 ) ? toIndex : fromIndex;
    
    CGRect fromFrame = [self layoutAttributesForItemAtIndexPath:[NSIndexPath indexPathForItem:fromIndex inSection:0]].frame;
    NSInteger numberOfItems = [self.dataSource collectionView:self numberOfItemsInSection:0];
    CGRect toFrame;
    if (toIndex < 0 || toIndex > numberOfItems - 1){
        if (toIndex < 0) {
            UICollectionViewLayoutAttributes * cellAtts = [self layoutAttributesForItemAtIndexPath:[NSIndexPath indexPathForItem:0 inSection:0]];
            toFrame = CGRectOffset(cellAtts.frame, -cellAtts.frame.size.width, 0);
        }
        else{
            UICollectionViewLayoutAttributes * cellAtts = [self layoutAttributesForItemAtIndexPath:[NSIndexPath indexPathForItem:(numberOfItems - 1) inSection:0]];
            toFrame = CGRectOffset(cellAtts.frame, cellAtts.frame.size.width, 0);
        }
    }
    else{
        toFrame = [self layoutAttributesForItemAtIndexPath:[NSIndexPath indexPathForItem:toIndex inSection:0]].frame;
    }
    CGRect targetFrame = fromFrame;
    targetFrame.size.height = self.selectedBar.frame.size.height;
    targetFrame.size.width += (toFrame.size.width - fromFrame.size.width) * progressPercentage;
    targetFrame.origin.x += (toFrame.origin.x - fromFrame.origin.x) * progressPercentage;
    
    self.selectedBar.frame = CGRectMake(targetFrame.origin.x, self.selectedBar.frame.origin.y, targetFrame.size.width, self.selectedBar.frame.size.height);
    
    // Next, calculate and set the contentOffset of the UICollectionView
    // (so it scrolls the selectedBar into the appriopriate place given the self.selectedBarAlignment)
    
    float targetContentOffset = 0;
    // Only bother calculating the contentOffset if there are sufficient tabs that the bar can actually scroll!
    if (self.contentSize.width > self.frame.size.width)
    {
        CGFloat toContentOffset = [self contentOffsetForCellWithFrame:toFrame index:toIndex];
        CGFloat fromContentOffset = [self contentOffsetForCellWithFrame:fromFrame index:fromIndex];
        
        targetContentOffset = fromContentOffset + ((toContentOffset - fromContentOffset) * progressPercentage);
    }
    
    // If there is a large difference between the current contentOffset and the contentOffset we're about to set
    // then the change might be visually jarring so animate it.  (This will likely occur if the user manually
    // scrolled the XLButtonBarView and then subsequently scrolled the UIPageViewController)
    // Alternatively if the fromIndex and toIndex are the same then this is the last call to this method in the
    // progression so as a precaution always animate this contentOffest change
    BOOL animated = (ABS(self.contentOffset.x - targetContentOffset) > 30) || (fromIndex == toIndex);
    [self setContentOffset:CGPointMake(targetContentOffset, 0) animated:animated];
}


-(void)updateSelectedBarPositionWithAnimation:(BOOL)animation swipeDirection:(XLPagerTabStripDirection __unused)swipeDirection pagerScroll:(XLPagerScroll)pagerScroll
{
    CGRect selectedBarFrame = self.selectedBar.frame;
    
    NSIndexPath *selectedCellIndexPath = [NSIndexPath indexPathForItem:self.selectedOptionIndex inSection:0];
    UICollectionViewLayoutAttributes *attributes = [self layoutAttributesForItemAtIndexPath:selectedCellIndexPath];
    CGRect selectedCellFrame = attributes.frame;
    
    [self updateContentOffsetAnimated:animation pagerScroll:pagerScroll toFrame:selectedCellFrame toIndex:selectedCellIndexPath.row];
    
    selectedBarFrame.size.width = selectedCellFrame.size.width;
    selectedBarFrame.origin.x = selectedCellFrame.origin.x;
    
    if (animation){
        [UIView animateWithDuration:0.3 animations:^{
            self.selectedBar.frame = selectedBarFrame;
        }];
    }
    else{
        self.selectedBar.frame = selectedBarFrame;
    }
}



#pragma mark - Helpers

- (void)updateContentOffsetAnimated:(BOOL)animated pagerScroll:(XLPagerScroll)pageScroller toFrame:(CGRect)selectedCellFrame toIndex:(NSUInteger)toIndex
{
    if (pageScroller != XLPagerScrollNO)
    {
        if (pageScroller == XLPagerScrollOnlyIfOutOfScreen)
        {
            if  ((selectedCellFrame.origin.x  >= self.contentOffset.x)
                 && (selectedCellFrame.origin.x < (self.contentOffset.x + self.frame.size.width - self.contentInset.left))){
                return;
            }
        }
        
        CGFloat targetContentOffset = 0;
        // Only bother calculating the contentOffset if there are sufficient tabs that the bar can actually scroll!
        if (self.contentSize.width > self.frame.size.width)
        {
            targetContentOffset = [self contentOffsetForCellWithFrame:selectedCellFrame index:toIndex];
        }
        
        [self setContentOffset:CGPointMake(targetContentOffset, 0) animated:animated];
    }
}

- (CGFloat)contentOffsetForCellWithFrame:(CGRect)cellFrame index:(NSUInteger)index
{
    UIEdgeInsets sectionInset = ((UICollectionViewFlowLayout *)self.collectionViewLayout).sectionInset;
    
    CGFloat alignmentOffset = 0;
    
    switch (self.selectedBarAlignment)
    {
        case XLSelectedBarAlignmentLeft:
        {
            alignmentOffset = sectionInset.left;
            break;
        }
        case XLSelectedBarAlignmentRight:
        {
            alignmentOffset = self.frame.size.width - sectionInset.right - cellFrame.size.width;
            break;
        }
        case XLSelectedBarAlignmentCenter:
        {
            alignmentOffset = (self.frame.size.width - cellFrame.size.width) * 0.5;
            break;
        }
        case XLSelectedBarAlignmentProgressive:
        {
            CGFloat cellHalfWidth = cellFrame.size.width * 0.5;
            CGFloat leftAlignmentOffest = sectionInset.left + cellHalfWidth;
            CGFloat rightAlignmentOffset = self.frame.size.width - sectionInset.right - cellHalfWidth;
            NSInteger numberOfItems = [self.dataSource collectionView:self numberOfItemsInSection:0];
            CGFloat progress = index / (CGFloat)(numberOfItems - 1);
            alignmentOffset = leftAlignmentOffest + ((rightAlignmentOffset - leftAlignmentOffest) * progress) - cellHalfWidth;
            break;
        }
    }
    
    CGFloat contentOffset = cellFrame.origin.x - alignmentOffset;
    
    // Ensure that the contentOffset wouldn't scroll the UICollectioView passed the beginning
    contentOffset = MAX(0, contentOffset);
    // Ensure that the contentOffset wouldn't scroll the UICollectioView passed the end
    contentOffset = MIN(self.contentSize.width - self.frame.size.width, contentOffset);
    
    return contentOffset;
}

- (void)setViewPager:(UICollectionView *)viewPager{
    
    if(_viewPager == nil){
        _viewPager = viewPager;
        WildCardCollectionViewAdapter* adapter = ((WildCardCollectionViewAdapter*)self.viewPager.delegate);
        [adapter addViewPagerSelected:^(int position) {
            [self moveToViewControllerAtIndex:position];
        }];
    } else
        _viewPager = viewPager;
}

- (void)setSelectedBarHeight:(CGFloat)selectedBarHeight
{
    _selectedBarHeight = selectedBarHeight;
    _selectedBar.frame = CGRectMake(_selectedBar.frame.origin.x, self.frame.size.height - _selectedBarHeight, _selectedBar.frame.size.width, _selectedBarHeight);
}

- (UIView *)selectedBar
{
    if (!_selectedBar) {
        _selectedBar = [[UIView alloc] initWithFrame:CGRectMake(0, self.frame.size.height - _selectedBarHeight, 0, _selectedBarHeight)];
        _selectedBar.layer.zPosition = 9999;
        _selectedBar.backgroundColor = [UIColor blackColor];
    }
    return _selectedBar;
}


- (CGSize)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout*)collectionViewLayout sizeForItemAtIndexPath:(NSIndexPath *)indexPath
{
    if (self.cachedCellWidths.count > indexPath.row)
    {
        NSNumber *cellWidthValue = self.cachedCellWidths[indexPath.row];
        CGFloat cellWidth = [cellWidthValue floatValue];
        return CGSizeMake(cellWidth, collectionView.frame.size.height);
    }
    return CGSizeZero;
}

- (void)moveToViewControllerAtIndex:(int)index{
    self.currentIndex = index;
    [self moveToIndex:index animated:YES swipeDirection:XLPagerTabStripDirectionNone pagerScroll:XLPagerScrollYES];
    [self reloadData];
    if(self.viewPager){
        [self.viewPager scrollToItemAtIndexPath:[NSIndexPath indexPathForRow:index inSection:0] atScrollPosition:UICollectionViewScrollPositionCenteredHorizontally animated:YES];
    }
}

- (void)setList:(NSMutableArray *)list{
    _list = list;
    
    self.cachedCellWidths = nil;
    if([list count] > 0){
        int firstWidth = self.cachedCellWidths[0];
        self.selectedBar.hidden = NO;
        [self updateSelectedBarPositionWithAnimation:NO swipeDirection:XLPagerTabStripDirectionNone pagerScroll:XLPagerScrollNO];
    } else {
        self.selectedBar.hidden = YES;
    }
}



#pragma merk - UICollectionViewDataSource

-(NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section
{
    if(self.list)
        return [self.list count];
    else
        return 0;
}

- (void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath{
    [self moveToViewControllerAtIndex:(int)indexPath.row];
}

-(void)onClickListener:(WildCardUITapGestureRecognizer *)recognizer
{
    [self moveToViewControllerAtIndex:(int)recognizer.tag];
}


- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath
{
    WildCardPagerTabStripCell * cell = [collectionView dequeueReusableCellWithReuseIdentifier:@"Cell" forIndexPath:indexPath];
    NSAssert([cell isKindOfClass:[WildCardPagerTabStripCell class]], @"UICollectionViewCell should be or extend WildCardPagerTabStripCell");
    
    WildCardPagerTabStripCell * buttonBarCell = (WildCardPagerTabStripCell *)cell;
    
    id item = self.list[[indexPath row]];
    NSString* text = [MappingSyntaxInterpreter interpret:self.jsonPath:item];
    [buttonBarCell.label setText:text];
    
    if([indexPath row] == _currentIndex){
        buttonBarCell.label.font = [UIFont systemFontOfSize:self.selectedTextSize];
        buttonBarCell.label.textColor = self.selectedTextColor;
    } else {
        buttonBarCell.label.font = [UIFont systemFontOfSize:self.textSize];
        buttonBarCell.label.textColor = self.textColor;
    }
    
    buttonBarCell.label.userInteractionEnabled = YES;
    WildCardUITapGestureRecognizer *singleFingerTap =
    [[WildCardUITapGestureRecognizer alloc] initWithTarget:self action:@selector(onClickListener:)];
    singleFingerTap.tag = (int)indexPath.row;
    [buttonBarCell.label addGestureRecognizer:singleFingerTap];
    
    return buttonBarCell;
}

- (NSArray *)cachedCellWidths
{
    if (!_cachedCellWidths)
    {
        // First calculate the minimum width required by each cell
        
        UICollectionViewFlowLayout *flowLayout = (id)self.collectionViewLayout;
        NSUInteger numberOfCells = [self.list count];
        
        NSMutableArray *minimumCellWidths = [[NSMutableArray alloc] init];
        
        CGFloat collectionViewContentWidth = 0;
        
        for (int i=0;i<[self.list count];i++)
        {
            UILabel *label = [[UILabel alloc] init];
            label.translatesAutoresizingMaskIntoConstraints = NO;
            label.font = [UIFont systemFontOfSize:self.textSize];
            label.text = self.list[i][self.jsonPath];
            CGSize labelSize = [label intrinsicContentSize];
            
            CGFloat minimumCellWidth = labelSize.width + (self.leftRightMargin * 2);
            NSNumber *minimumCellWidthValue = [NSNumber numberWithFloat:minimumCellWidth];
            [minimumCellWidths addObject:minimumCellWidthValue];
        
            collectionViewContentWidth += minimumCellWidth;
        
        }
        
        // To get an acurate collectionViewContentWidth account for the spacing between cells
        CGFloat cellSpacingTotal = ((numberOfCells-1) * flowLayout.minimumInteritemSpacing);
        collectionViewContentWidth += cellSpacingTotal;
        
        CGFloat collectionViewAvailableVisibleWidth = self.frame.size.width - flowLayout.sectionInset.left - flowLayout.sectionInset.right;
        
        // Do we need to stetch any of the cell widths to fill the screen width?
        if (!self.shouldCellsFillAvailableWidth || collectionViewAvailableVisibleWidth < collectionViewContentWidth)
        {
            // The collection view's content width is larger that the visible width available so it needs to scroll
            // OR shouldCellsFillAvailableWidth == NO...
            // No need to stretch any of the cells, we can just use the minimumCellWidths for the cell widths.
            _cachedCellWidths = minimumCellWidths;
        }
        else
        {
            // The collection view's content width is smaller that the visible width available so it won't ever scroll
            // AND shouldCellsFillAvailableWidth == YES so we want to stretch the cells to fill the width.
            // We now need to calculate how much to stretch each tab...
            
            // In an ideal world the cell's would all have an equal width, however the cell labels vary in length
            // so some of the longer labelled cells might not need to stetch where as the shorter labelled cells do.
            // In order to determine what needs to stretch and what doesn't we have to recurse through suggestedStetchedCellWidth
            // values (the value decreases with each recursive call) until we find a value that works.
            // The first value to try is the largest (for the case where all the cell widths are equal)
            CGFloat stetchedCellWidthIfAllEqual = (collectionViewAvailableVisibleWidth - cellSpacingTotal) / numberOfCells;
            
            CGFloat generalMiniumCellWidth = [self calculateStretchedCellWidths:minimumCellWidths suggestedStetchedCellWidth:stetchedCellWidthIfAllEqual previousNumberOfLargeCells:0];
            
            NSMutableArray *stetchedCellWidths = [[NSMutableArray alloc] init];
            
            for (NSNumber *minimumCellWidthValue in minimumCellWidths)
            {
                CGFloat minimumCellWidth = minimumCellWidthValue.floatValue;
                CGFloat cellWidth = (minimumCellWidth > generalMiniumCellWidth) ? minimumCellWidth : generalMiniumCellWidth;
                NSNumber *cellWidthValue = [NSNumber numberWithFloat:cellWidth];
                [stetchedCellWidths addObject:cellWidthValue];
            }
            
            _cachedCellWidths = stetchedCellWidths;
        }
    }
    return _cachedCellWidths;
}

- (CGFloat)calculateStretchedCellWidths:(NSArray *)minimumCellWidths suggestedStetchedCellWidth:(CGFloat)suggestedStetchedCellWidth previousNumberOfLargeCells:(NSUInteger)previousNumberOfLargeCells
{
    // Recursively attempt to calculate the stetched cell width
    
    NSUInteger numberOfLargeCells = 0;
    CGFloat totalWidthOfLargeCells = 0;
    
    for (NSNumber *minimumCellWidthValue in minimumCellWidths)
    {
        CGFloat minimumCellWidth = minimumCellWidthValue.floatValue;
        if (minimumCellWidth > suggestedStetchedCellWidth) {
            totalWidthOfLargeCells += minimumCellWidth;
            numberOfLargeCells++;
        }
    }
    
    // Is the suggested width any good?
    if (numberOfLargeCells > previousNumberOfLargeCells)
    {
        // The suggestedStetchedCellWidth is no good :-( ... calculate a new suggested width
        UICollectionViewFlowLayout *flowLayout = (id)self.collectionViewLayout;
        CGFloat collectionViewAvailableVisibleWidth = self.frame.size.width - flowLayout.sectionInset.left - flowLayout.sectionInset.right;
        NSUInteger numberOfCells = minimumCellWidths.count;
        CGFloat cellSpacingTotal = ((numberOfCells-1) * flowLayout.minimumInteritemSpacing);
        
        NSUInteger numberOfSmallCells = numberOfCells - numberOfLargeCells;
        CGFloat newSuggestedStetchedCellWidth =  (collectionViewAvailableVisibleWidth - totalWidthOfLargeCells - cellSpacingTotal) / numberOfSmallCells;
        
        return [self calculateStretchedCellWidths:minimumCellWidths suggestedStetchedCellWidth:newSuggestedStetchedCellWidth previousNumberOfLargeCells:numberOfLargeCells];
    } 
    
    // The suggestion is good
    return suggestedStetchedCellWidth;
}

@end
