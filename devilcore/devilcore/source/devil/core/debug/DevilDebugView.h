//
//  DevilDebugView.h
//  devilcore
//
//  Created by Mu Young Ko on 2021/01/14.
//

#import <UIKit/UIKit.h>
#import "DevilController.h"

NS_ASSUME_NONNULL_BEGIN

@interface DevilDebugView : UIView

+ (void)constructDebugViewIf:(DevilController*)vc;

@end

NS_ASSUME_NONNULL_END
