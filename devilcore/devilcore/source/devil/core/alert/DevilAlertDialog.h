//
//  DevilAlertDialog.h
//  devilcore
//
//  Created by Mu Young Ko on 2021/09/27.
//

#import <Foundation/Foundation.h>
#import "WildCardConstructor.h"

NS_ASSUME_NONNULL_BEGIN

@interface DevilAlertDialog : NSObject<WildCardConstructorInstanceDelegate>

+(DevilAlertDialog*)sharedInstance;
+(BOOL)showAlertTemplate:(NSString*)msg :(void (^)(BOOL yes))callback;
+(BOOL)showConfirmTemplate:(NSString*)msg :(NSString*)yes :(NSString*)no :(void (^)(BOOL yes))callback;

@end

NS_ASSUME_NONNULL_END
