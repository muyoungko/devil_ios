//
//  DevilHealth.h
//  template1
//
//  Created by Mu Young Ko on 2022/09/02.
//  Copyright © 2022 july. All rights reserved.
//

#import <UIKit/UIKit.h>
@import HealthKit;

NS_ASSUME_NONNULL_BEGIN

@interface DevilHealthInstance : NSObject

@property (nonatomic, retain) HKHealthStore* healthStore;

+ (DevilHealthInstance*)sharedInstance;
-(void)requestPermission:(id)param callback:(void (^)(id res))callback;
-(void)requestHealthData:(id)param callback:(void (^)(id res))callback;

@end

NS_ASSUME_NONNULL_END
