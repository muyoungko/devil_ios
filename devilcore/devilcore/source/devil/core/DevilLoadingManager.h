//
//  DevilLoadingManager.h
//  devilcore
//
//  Created by Mu Young Ko on 2025/01/05.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@interface DevilLoadingManager : NSObject
-(id)initWithLottieJson:(NSData*)data;
-(void)startLoading;
-(void)stopLoading;
@end

NS_ASSUME_NONNULL_END
