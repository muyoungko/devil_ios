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
-(void)removeMarker:(NSString*)strKey;
-(void)addCircle:(id)param;
-(void)removeCircle:(NSString*)strKey;

-(void)callbackMarkerClick :(void (^)(id markerJson))callback;
-(void)callbackMapClick :(void (^)(id))callback;
-(void)callbackCamera :(void (^)(id))callback;
-(void)callbackDragStart :(void (^)(id))callback;
-(void)callbackDragEnd :(void (^)(id))callback;

@end

NS_ASSUME_NONNULL_END
