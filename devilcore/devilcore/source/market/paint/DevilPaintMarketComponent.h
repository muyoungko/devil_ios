//
//  DevilPaintMarketComponent.h
//  devilcore
//
//  Created by Mu Young Ko on 2024/02/07.
//

#import <devilcore/devilcore.h>

NS_ASSUME_NONNULL_BEGIN

@interface DevilPaintMarketComponent : MarketComponent

-(void)saveImage:(void (^)(id res))callback;
-(BOOL)isEmpty;
-(void)clear;

@end

NS_ASSUME_NONNULL_END
