//
//  DevilGalleryController.h
//  devilcore
//
//  Created by Mu Young Ko on 2021/11/22.
//

#import <devilcore/devilcore.h>
@import UIKit;

NS_ASSUME_NONNULL_BEGIN

@interface DevilGalleryController : DevilBaseController<UICollectionViewDelegate, UICollectionViewDataSource>

@property (weak, nonatomic) IBOutlet UICollectionView *list;
@property (nonatomic, retain) id param;
@property (nonatomic, retain) id<DevilCameraControllerDelegate> delegate;

@end

NS_ASSUME_NONNULL_END
