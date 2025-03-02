//
//  DevilBle.h
//  devilcore
//
//  Created by Mu Young Ko on 2022/05/22.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@interface DevilBle : NSObject

@property (nonatomic,retain) id currentInfo;

+ (DevilBle*)sharedInstance;
- (void)list:(id)param :(void (^)(id res))callback;
- (void)stopScan;
- (void)connect:(NSString*)udid :(void (^)(id res))callback;
- (void)disconnect:(NSString*)udid :(void (^)(id res))callback;
- (void)send:(id)param :(void (^)(id res))callback;
- (void)read:(id)param :(void (^)(id res))callback;
- (void)callback:(NSString*)command :(void (^)(id res))callback;
- (void)destroy;
- (void)bleRelease;

@end

NS_ASSUME_NONNULL_END
