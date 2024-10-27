//
//  WildCardUICollectionView.m
//  devilcore
//
//  Created by Mu Young Ko on 2021/07/17.
//

#import "ReplaceRuleRepeat.h"
#import "WildCardUICollectionView.h"
#import "WildCardCollectionViewAdapter.h"

@interface WildCardUICollectionView()<UICollectionViewDragDelegate, UICollectionViewDropDelegate>

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
    else {
        WildCardCollectionViewAdapter* adapter = ((WildCardCollectionViewAdapter*)self.delegate);
        if(index >= [adapter getCount])
            index = [adapter getCount] - 1;
        if(index >= 0) {
            
            @try{
                [self scrollToItemAtIndexPath:[NSIndexPath indexPathForRow:index inSection:0] atScrollPosition:UICollectionViewScrollPositionTop animated:ani];
            }@catch(NSException* e) {
                [self asyncScrollTo:index :ani];
            }

        }
    }
}
    
-(void)scrollToCore:(NSNumber*)index{
    
    if([REPEAT_TYPE_HLIST isEqualToString:self.repeatType])
        [self scrollToItemAtIndexPath:[NSIndexPath indexPathForRow:[index intValue] inSection:0] atScrollPosition:UICollectionViewScrollPositionCenteredHorizontally animated:self.reservedAni];
    else {
        [self scrollToItemAtIndexPath:[NSIndexPath indexPathForRow:[index intValue] inSection:0] atScrollPosition:UICollectionViewScrollPositionTop animated:self.reservedAni];
    }
    
//    if(self.delegate) {
//        WildCardCollectionViewAdapter* adapter = (WildCardCollectionViewAdapter*)self.delegate;
//        if(adapter.scrolledCallback)
//            adapter.scrolledCallback(self);
//    }
}

- (void)reloadData{
    [super reloadData];
    
}

-(void)dragEnable:(BOOL)enable{
    if (@available(iOS 11.0, *)) {
        self.dragInteractionEnabled = enable;
        if(enable){
            self.dragDelegate = self;
            self.dropDelegate = self;
        }
    }
}


#pragma mark - UICollectionViewDragDelegate

- (NSArray<UIDragItem *> *)collectionView:(UICollectionView *)collectionView itemsForBeginningDragSession:(id<UIDragSession>)session atIndexPath:(NSIndexPath *)indexPath {
    int index = (int)indexPath.row;
    __block WildCardCollectionViewAdapter* adapter = (WildCardCollectionViewAdapter*)self.delegate;
    if(adapter.dragAndDropRangeFrom == -1 || (adapter.dragAndDropRangeFrom <= index && index < adapter.dragAndDropRangeTo))
        ;
    else
        return @[];
    id item = [NSString stringWithFormat:@"%d", index];
    NSItemProvider *itemProvider = [[NSItemProvider alloc] initWithObject:item];
    UIDragItem *dragItem = [[UIDragItem alloc] initWithItemProvider:itemProvider];
    dragItem.localObject = item;  // 로컬 데이터를 지정하여 드롭에서 참조 가능
    return @[dragItem];
}

#pragma mark - UICollectionViewDropDelegate

- (void)collectionView:(UICollectionView *)collectionView performDropWithCoordinator:(id<UICollectionViewDropCoordinator>)coordinator {
    
    __block WildCardCollectionViewAdapter* adapter = (WildCardCollectionViewAdapter*)self.delegate;
    int len = [adapter.data[@"length"] toInt32];
    NSIndexPath *destinationIndexPath = coordinator.destinationIndexPath ?: [NSIndexPath indexPathForItem:len-1 inSection:0];

    
    UIDragItem* dragItem = coordinator.session.items[0];
    __block int fromIndex = [dragItem.localObject intValue];
    __block int toIndex = (int)coordinator.destinationIndexPath.row;

    if(adapter.dragAndDropRangeFrom == -1 || (adapter.dragAndDropRangeFrom <= toIndex && toIndex < adapter.dragAndDropRangeTo))
        ;
    else
        return;
    
    __block id<UICollectionViewDropItem> dropItem = coordinator.items[0];
    NSIndexPath *sourceIndexPath = dropItem.sourceIndexPath;
    
    [collectionView performBatchUpdates:^{
        
    } completion:^(BOOL finished) {
        
        JSValue* from = adapter.data[fromIndex];
        [adapter.data invokeMethod:@"splice" withArguments:@[@(fromIndex), @1]];
        [adapter.data invokeMethod:@"splice" withArguments:@[@(toIndex), @0, from]];
        
        int64_t delayInSeconds = 1;
        dispatch_time_t delay = dispatch_time(DISPATCH_TIME_NOW, delayInSeconds * NSEC_PER_SEC);
        dispatch_after(delay, dispatch_get_main_queue(), ^{
            if(adapter.dragAndDropCallback) {
                adapter.dragAndDropCallback(fromIndex, toIndex);
                adapter.dragAndDropCallback = nil;
            }
        });
    }];
    [coordinator dropItem:dropItem.dragItem toItemAtIndexPath:destinationIndexPath];
    [collectionView moveItemAtIndexPath:sourceIndexPath toIndexPath:destinationIndexPath];
}

- (UICollectionViewDropProposal *)collectionView:(UICollectionView *)collectionView dropSessionDidUpdate:(id<UIDropSession>)session withDestinationIndexPath:(NSIndexPath *)destinationIndexPath {
    if (session.localDragSession) {
        // 같은 앱 내에서의 드래그 앤 드롭이면 .move
        return [[UICollectionViewDropProposal alloc] initWithDropOperation:UIDropOperationMove intent:UICollectionViewDropIntentInsertAtDestinationIndexPath];
    } else {
        // 외부 데이터의 드롭이면 .copy
        return [[UICollectionViewDropProposal alloc] initWithDropOperation:UIDropOperationCopy];
    }
    return nil;
}

@end
