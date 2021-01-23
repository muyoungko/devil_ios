//
//  WildCardPagerTabStripMaker.h
//  devilcore
//
//  Created by Mu Young Ko on 2021/01/23.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>
#import "WildCardPagerTabStrip.h"
#import "ReplaceRule.h"

NS_ASSUME_NONNULL_BEGIN

@interface WildCardPagerTabStripMaker : NSObject

+(WildCardPagerTabStrip*)construct:(id)layer :(UIView*)vv;
+(void)update:(ReplaceRule*)rule :(id)opt;

@end

NS_ASSUME_NONNULL_END
