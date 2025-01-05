//
//  DevilDynamicAsset.h
//  devilcore
//
//  Created by Mu Young Ko on 2024/12/26.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@interface DevilDynamicAsset : NSObject
+ (DevilDynamicAsset*)sharedInstance;
- (void)download:(id)key_list callback:(void (^)(bool success))callback;
- (UIFont*)getFont:(NSString*)key fontSize:(float)size;

@end

NS_ASSUME_NONNULL_END
