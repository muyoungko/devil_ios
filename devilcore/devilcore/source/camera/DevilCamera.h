//
//  DevilCamera.h
//  devilcore
//
//  Created by Mu Young Ko on 2021/04/11.
//

#import <Foundation/Foundation.h>
@import UIKit;

NS_ASSUME_NONNULL_BEGIN

@interface DevilCamera : NSObject
+(void)camera:(UIViewController*)vc param:(id)param callback:(void (^)(id res))callback;
@end

NS_ASSUME_NONNULL_END
