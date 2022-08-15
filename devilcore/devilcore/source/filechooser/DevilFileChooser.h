//
//  DevilFileChooser.h
//  devilcore
//
//  Created by Mu Young Ko on 2022/08/15.
//

#import <Foundation/Foundation.h>
@import UIKit;

NS_ASSUME_NONNULL_BEGIN

@interface DevilFileChooser : NSObject

+ (DevilFileChooser*)sharedInstance;
-(void)fileChooser:(UIViewController*)vc param:(id)param callback:(void (^)(id res))callback;

@end

NS_ASSUME_NONNULL_END
