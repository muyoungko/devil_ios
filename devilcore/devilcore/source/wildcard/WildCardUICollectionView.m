//
//  WildCardUICollectionView.m
//  devilcore
//
//  Created by Mu Young Ko on 2021/07/17.
//

#import "ReplaceRuleRepeat.h"
#import "WildCardUICollectionView.h"
#import "WildCardCollectionViewAdapter.h"

@interface WildCardUICollectionView()

@property BOOL reservedAni;

@end

@implementation WildCardUICollectionView

/*
// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect {
    // Drawing code
}
*/

-(void)asyncScrollTo:(int)index :(BOOL)ani{
    self.reservedAni = ani;
    [self performSelector:@selector(scrollToCore:) withObject:[NSNumber numberWithInt:index] afterDelay:0.0f];
}

-(void)scrollTo:(int)index :(BOOL)ani{
    if([REPEAT_TYPE_HLIST isEqualToString:self.repeatType])
        [self scrollToItemAtIndexPath:[NSIndexPath indexPathForRow:index inSection:0] atScrollPosition:UICollectionViewScrollPositionCenteredHorizontally animated:ani];
    else
        [self scrollToItemAtIndexPath:[NSIndexPath indexPathForRow:index inSection:0] atScrollPosition:UICollectionViewScrollPositionCenteredVertically animated:ani];
}
    
-(void)scrollToCore:(NSNumber*)index{
    
    if([REPEAT_TYPE_HLIST isEqualToString:self.repeatType])
        [self scrollToItemAtIndexPath:[NSIndexPath indexPathForRow:[index intValue] inSection:0] atScrollPosition:UICollectionViewScrollPositionCenteredHorizontally animated:self.reservedAni];
    else
        [self scrollToItemAtIndexPath:[NSIndexPath indexPathForRow:[index intValue] inSection:0] atScrollPosition:UICollectionViewScrollPositionCenteredVertically animated:self.reservedAni];
    
//    if(self.delegate) {
//        WildCardCollectionViewAdapter* adapter = (WildCardCollectionViewAdapter*)self.delegate;
//        if(adapter.scrolledCallback)
//            adapter.scrolledCallback(self);
//    }
}

- (void)reloadData{
    [super reloadData];
    
}
@end
