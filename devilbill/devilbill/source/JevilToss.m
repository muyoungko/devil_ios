//
//  JevilToss.m
//  devilbill
//
//  Created by Mu Young Ko on 2023/08/14.
//

#import "JevilToss.h"
#import <devilbill/devilbill-Swift.h>
@import devilcore;

@implementation JevilToss

+ (void)order:(id)param :(JSValue *)callback {
    
    NSString* orderId = param[@"order_id"];
    NSString* orderName = param[@"order_name"];
    int amount = [param[@"amount"] intValue];
    NSString* customerId = param[@"customer_id"];

    [DevilTossPayments payOn:[JevilInstance currentInstance].vc customerKey:customerId orderId:orderId orderName:orderName amount:amount completion:^(id _Nullable res) {
        [callback callWithArguments:@[res]];
    }];
}

@end
