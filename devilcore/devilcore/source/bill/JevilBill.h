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

+ (void)purchase:(NSDictionary*)sku :(JSValue *)callback;
+ (void)requestProduct:(NSDictionary*)param:(JSValue *)callback;

@end

@interface JevilBill : NSObject <JevilBill>

@end

NS_ASSUME_NONNULL_END
