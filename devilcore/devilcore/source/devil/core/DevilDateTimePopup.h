//
//  DevilDateTimePopup.h
//  devilcore
//
//  Created by Mu Young Ko on 2021/06/20.
//

#import <Foundation/Foundation.h>
@import UIKit;

NS_ASSUME_NONNULL_BEGIN

@interface DevilDateTimePopup : NSObject

@property (nonatomic, retain) UIViewController* vc;

-(id)initWithViewController:(UIViewController*)vc;
-(void)popup:param onselect:(void (^)(id res))callback;

@end

NS_ASSUME_NONNULL_END
