//
//  DevilAlertDialog.h
//  devilcore
//
//  Created by Mu Young Ko on 2021/09/27.
//

#import <Foundation/Foundation.h>
#import "WildCardConstructor.h"
#import "DevilBlockDialog.h"

NS_ASSUME_NONNULL_BEGIN

@interface DevilAlertDialog : NSObject<WildCardConstructorInstanceDelegate>
@property (nonatomic, retain) DevilBlockDialog* dialog;
+(DevilAlertDialog*)sharedInstance;
+(BOOL)showAlertTemplate:(NSString*)msg :(void (^)(BOOL yes))callback;
+(BOOL)showAlertTemplateParam:(id)param :(void (^)(BOOL yes))callback;
+(BOOL)showConfirmTemplate:(NSString*)msg :(NSString*)yes :(NSString*)no :(void (^)(BOOL yes))callback;

@end

NS_ASSUME_NONNULL_END
