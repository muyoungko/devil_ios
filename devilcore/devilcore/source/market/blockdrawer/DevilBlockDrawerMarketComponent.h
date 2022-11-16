//
//  DevilBlockDrawerMarketComponent.h
//  devilcore
//
//  Created by Mu Young Ko on 2022/11/15.
//

#import <devilcore/devilcore.h>

NS_ASSUME_NONNULL_BEGIN

@interface DevilBlockDrawerMarketComponent : MarketComponent
{
    int naviStatus;
    int pointerId;
    float touchStartX;
    float touchStartY;
    double touchTime;
    float uiMenuStartX;
    float uiMenuStartY;
}

- (void)naviUp;
- (void)naviUpPreview:(int)preview_size;
- (void)naviDown;
- (void)callback:(NSString*)command :(void (^)(id res))callback;
@end

NS_ASSUME_NONNULL_END
