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

-(void)callbackMarkerClick :(void (^)(double lat, double longi, NSString* title, NSString* desc))callback;
-(void)callbackMapClick :(void (^)(double lat, double longi))callback;
-(void)callbackCamera :(void (^)(double lat, double longi))callback;
-(void)callbackDragStart :(void (^)(double lat, double longi, NSString* title, NSString* desc))callback;
-(void)callbackDragEnd :(void (^)(double lat, double longi, NSString* title, NSString* desc))callback;

@end

NS_ASSUME_NONNULL_END
