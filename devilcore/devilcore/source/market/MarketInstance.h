//
//  MarketInstance.h
//  devilcore
//
//  Created by Mu Young Ko on 2021/07/12.
//

#import <Foundation/Foundation.h>
#import "MarketComponent.h"

NS_ASSUME_NONNULL_BEGIN

@interface MarketInstance : NSObject

+(MarketComponent*)create:(id)market meta:(id)meta vv:(id)vv;

@end

NS_ASSUME_NONNULL_END
