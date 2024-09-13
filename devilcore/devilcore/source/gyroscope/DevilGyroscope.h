//
//  DevilGyroscope.h
//  devilcore
//
//  Created by Mu Young Ko on 2024/09/12.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@interface DevilGyroscopeValue : NSObject
+(DevilGyroscopeValue*)new:(NSTimeInterval)t :(float)x :(float)y :(float)z;
@property NSTimeInterval t;
@property float x;
@property float y;
@property float z;
@end


@interface DevilGyroscope : NSObject

+ (DevilGyroscope*)sharedInstance;
-(void)startGyroscope:(id)param callback:(void (^)(id res))callback;
-(NSArray*)getData:(id)param;
-(void)getZipData:(id)param callback:(void (^)(id res))callback;
-(void)stopGyroscope;

@end

NS_ASSUME_NONNULL_END
