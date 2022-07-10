//
//  JevilBill.m
//  devilbill
//
//  Created by Mu Young Ko on 2022/06/24.
//

#import "JevilBill.h"
#import "DevilBillInstance.h"

@implementation JevilBill

+ (void)requestProduct:(NSDictionary*)param:(JSValue *)callback {
    [[DevilBillInstance sharedInstance] requestProduct:param[@"skus"] callback:^(id  _Nonnull res) {
        [callback callWithArguments:@[res]];
    }];
}

+ (void)purchase:(NSDictionary*)param :(JSValue *)callback {
    [[DevilBillInstance sharedInstance] purchase:param[@"sku"] callback:^(id  _Nonnull res) {
        [callback callWithArguments:@[res]];
    }];
}


@end
