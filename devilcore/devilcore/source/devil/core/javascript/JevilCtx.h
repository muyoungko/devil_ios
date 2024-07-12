//
//  JevilCtx.h
//  devilcore
//
//  Created by Mu Young Ko on 2020/12/15.
//

@import JavaScriptCore;

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>
#import "WildCardMeta.h"
#import "DevilSelectDialog.h"

NS_ASSUME_NONNULL_BEGIN

@interface JevilCtx : NSObject

@property (nonatomic, retain) JSContext* jscontext;

-(NSString*)code:(NSString*)code viewController:(UIViewController*)vc data:(JSValue*)data meta:(WildCardMeta*)meta;
-(NSString*)code:(NSString*)code viewController:(UIViewController*)viewController data:(JSValue*)data meta:(WildCardMeta*)meta hide:(BOOL)hide;
-(JSValue*)createJsValue:(NSDictionary*)dic;
@end

NS_ASSUME_NONNULL_END
