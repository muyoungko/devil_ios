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
-(void)popup:param isDate:(BOOL)isDate onselect:(void (^)(id res))callback;

@end

NS_ASSUME_NONNULL_END
