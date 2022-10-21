//
//  DevilPinLayer.h
//  devilcore
//
//  Created by Mu Young Ko on 2022/09/08.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

@interface DevilPinLayer : UIView

@property (nonatomic, retain) id pinList;
@property float zoomScale;
- (void)highlight:(NSString*)key;
- (void)syncPinWithAnimation:(NSString*)key;
- (void)syncPin;
- (void)updateZoom:(float)zoomScale;
- (void)updatePinDirection:(NSString*)key;

@end

NS_ASSUME_NONNULL_END
