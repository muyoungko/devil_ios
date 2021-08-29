//
//  DevilBeacon.h
//  devilcore
//
//  Created by Mu Young Ko on 2021/08/27.
//

#import <Foundation/Foundation.h>
#import <CoreBluetooth/CoreBluetooth.h>
#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

@protocol DevilBeaconDelegate<NSObject>

@optional
- (void)onComplete:(id)res;
- (void)onFound:(id)res;

@end

@interface DevilBeacon : NSObject<CBCentralManagerDelegate, CBPeripheralDelegate>

+ (DevilBeacon*)sharedInstance;
- (void)scan:(id)param complete:(void (^)(id res))completeCallback found:(void (^)(id res))foundCallback;
- (void)stop;

@end

NS_ASSUME_NONNULL_END
