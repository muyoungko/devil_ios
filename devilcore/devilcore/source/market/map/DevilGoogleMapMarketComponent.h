//
//  DevilGoogleMapMarketComponent.h
//  devilcore
//
//  Created by Mu Young Ko on 2023/10/04.
//

#import <devilcore/devilcore.h>

NS_ASSUME_NONNULL_BEGIN

@interface DevilGoogleMapMarketComponent : MarketComponent
-(void)camera:(id)param;
-(void)addMarker:(id)param;
-(void)updateMarker:(id)param;
-(void)removeMarker:(id)param;
-(void)addCircle:(id)param;
-(void)removeCircle:(id)param;
-(void)callback:(id)param;

@end

NS_ASSUME_NONNULL_END
