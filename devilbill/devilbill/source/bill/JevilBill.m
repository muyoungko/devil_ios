//
//  JevilBill.m
//  devilbill
//
//  Created by Mu Young Ko on 2022/06/24.
//

#import "JevilBill.h"
#import "DevilBillInstance.h"

@implementation JevilBill

+ (void)getProduct:(NSDictionary*)param:(JSValue *)callback {
    [[DevilBillInstance sharedInstance] requestProduct:param[@"skus"] callback:^(id  _Nonnull res) {
        [callback callWithArguments:@[res]];
    }];
}

+ (void)loadItemList:(NSDictionary*)param:(JSValue *)callback{
//    Bill
}
+ (void)loadItemPurchasedList:(NSDictionary*)param:(JSValue *)callback{
    
}
+ (void)loadSubscribeList:(NSDictionary*)param : (JSValue *)callback{
    
}
+ (void)loadSubscribePurchasedList:(NSDictionary*)param : (JSValue *)callback{
    [DevilBillInstance sharedInstance];
}

@end
