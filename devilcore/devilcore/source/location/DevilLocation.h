//
//  DevilLocation.h
//  devilcore
//
//  Created by Mu Young Ko on 2021/05/22.
//

#import <Foundation/Foundation.h>
#import <CoreLocation/CoreLocation.h>

NS_ASSUME_NONNULL_BEGIN


@interface DevilLocation : NSObject

+ (DevilLocation*)sharedInstance;

- (void)getCurrentLocation:(void (^)(id result))callback;
- (void)getCurrentPlace:(void (^)(id result))callback;
- (void)search:(NSString*)keyword :(void (^)(id result))callback;
- (void)searchKoreanDongWithKakao:(NSString*)keyword :(void (^)(id result))callback;

@end

NS_ASSUME_NONNULL_END
