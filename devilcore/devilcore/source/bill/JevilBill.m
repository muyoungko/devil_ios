//
//  JevilBill.m
//  devilbill
//
//  Created by Mu Young Ko on 2022/06/24.
//

#import "JevilBill.h"
#import "DevilBillInstance.h"
#import "DEvilDebugView.h"

@implementation JevilBill

+ (void)requestProduct:(NSDictionary*)param:(JSValue *)callback {
    [[DevilBillInstance sharedInstance] requestProduct:param callback:^(id  _Nonnull res) {
        [[DevilDebugView sharedInstance] log:DEVIL_LOG_BILL title:@"requestProduct" log:res];
        [callback callWithArguments:@[res]];
    }];
}

+ (void)purchase:(NSDictionary*)param :(JSValue *)callback {
    [[DevilBillInstance sharedInstance] purchase:param[@"sku"] callback:^(id  _Nonnull res) {
        [callback callWithArguments:@[res]];
    }];
}

+ (void)consume:(NSDictionary*)param :(JSValue *)callback {
    [callback callWithArguments:@[@{@"r":@TRUE}]];
    //    [[DevilBillInstance sharedInstance] consume:param[@"sku"] callback:^(id  _Nonnull res) {
    //        [callback callWithArguments:@[res]];
    //    }];
}

+ (void)restorePurchase:(JSValue *)callback {
    [[DevilBillInstance sharedInstance] restorePurchase:^(id  _Nonnull res) {
        [callback callWithArguments:@[res]];
    }];
}


@end
