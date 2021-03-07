//
//  WifiManager.h
//  devilcore
//
//  Created by Mu Young Ko on 2021/02/14.
//

@import CoreLocation;

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@interface WifiManager : NSObject<CLLocationManagerDelegate>

-(void)connect:(NSString*)ssid :(void (^)(id res)) callback;
-(void)getWifList:(void (^)(id res)) callback;
-(void)dismiss;

@end

NS_ASSUME_NONNULL_END
