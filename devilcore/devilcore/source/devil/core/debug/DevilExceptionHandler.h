//
//  DevilExceptionHandler.h
//  devilcore
//
//  Created by Mu Young Ko on 2020/12/21.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

@interface DevilExceptionHandler : NSObject
+(void)handle:(UIViewController*)vc data:(id)data e:(NSException*)e; 
@end

NS_ASSUME_NONNULL_END
