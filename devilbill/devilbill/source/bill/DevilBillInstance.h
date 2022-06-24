//
//  DevilBill.h
//  devilbill
//
//  Created by Mu Young Ko on 2022/06/24.
//

#import <Foundation/Foundation.h>
#import <StoreKit/StoreKit.h>

NS_ASSUME_NONNULL_BEGIN

@interface DevilBillInstance : NSObject<SKProductsRequestDelegate, SKPaymentTransactionObserver>

+(DevilBillInstance*)sharedInstance;
- (void)requestProduct:(NSArray*)skus callback:(void (^)(id res))callback;

@end

NS_ASSUME_NONNULL_END
