//
//  JevilAction.h
//  devilcore
//
//  Created by Mu Young Ko on 2020/12/06.
//

#import <Foundation/Foundation.h>
#import "WildCardMeta.h"

NS_ASSUME_NONNULL_BEGIN

@interface JevilAction : NSObject

+(void)actoin:(NSString*)functionName args:(id)args viewController:(UIViewController*)vc meta:(WildCardMeta*)meta;

@end

NS_ASSUME_NONNULL_END
