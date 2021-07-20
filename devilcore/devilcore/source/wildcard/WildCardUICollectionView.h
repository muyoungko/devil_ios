//
//  WildCardUICollectionView.h
//  devilcore
//
//  Created by Mu Young Ko on 2021/07/17.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

@interface WildCardUICollectionView : UICollectionView

-(void)asyncScrollTo:(int)index :(BOOL)ani;

@end

NS_ASSUME_NONNULL_END
