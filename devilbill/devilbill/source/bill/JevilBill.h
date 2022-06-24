//
//  JevilBill.h
//  devilbill
//
//  Created by Mu Young Ko on 2022/06/24.
//

@import JavaScriptCore;

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@protocol JevilBill <JSExport>

+ (void)loadItemList:(NSDictionary*)param:(JSValue *)callback;
+ (void)loadItemPurchasedList:(NSDictionary*)param:(JSValue *)callback;
+ (void)loadSubscribeList:(NSDictionary*)param : (JSValue *)callback;
+ (void)loadSubscribePurchasedList:(NSDictionary*)param : (JSValue *)callback;

@end

@interface JevilBill : NSObject <JevilBill>

@end

NS_ASSUME_NONNULL_END
