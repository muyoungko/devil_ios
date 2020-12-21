//
//  JevilCtx.h
//  devilcore
//
//  Created by Mu Young Ko on 2020/12/15.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>
#import "WildCardMeta.h"

NS_ASSUME_NONNULL_BEGIN

@interface JevilCtx : NSObject

+(JevilCtx*)sharedInstance;
-(NSString*)code:(NSString*)code viewController:(UIViewController*)viewController data:(id)data meta:(WildCardMeta*)meta;

@property (nonatomic, retain) UIViewController* vc;

@end

NS_ASSUME_NONNULL_END
