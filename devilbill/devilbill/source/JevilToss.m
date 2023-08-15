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
    NSString* name = param[@"name"];
    NSString* email = param[@"email"];
    NSString* phone = param[@"phone"];

    [DevilTossPayments payOn:[JevilInstance currentInstance].vc customerKey:customerId orderId:orderId orderName:orderName amount:amount name:name email:email phone:phone completion:^(id _Nullable res) {
        [callback callWithArguments:@[res]];
    }];
}

@end
