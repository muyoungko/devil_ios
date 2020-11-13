//
//  WildCardViewPagerLeftAction.h
//  library
//
//  Created by Mu Young Ko on 2018. 10. 31..
//  Copyright © 2018년 sbs cnbc. All rights reserved.
//

#import "WildCardAction.h"

NS_ASSUME_NONNULL_BEGIN

@interface WildCardViewPagerLeftAction : WildCardAction

@property (nonatomic, retain) NSString* node;

@end


@interface WildCardViewPagerScrollAction : WildCardAction

@property (nonatomic, retain) NSString* node;
@property (nonatomic, retain) NSString* toScrollIndexArgument;

@end

NS_ASSUME_NONNULL_END
