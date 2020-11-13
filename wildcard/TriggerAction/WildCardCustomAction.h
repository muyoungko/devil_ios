//
//  WildCardCustomAction.h
//  library
//
//  Created by Mu Young Ko on 2018. 10. 31..
//  Copyright © 2018년 sbs cnbc. All rights reserved.
//

#import "WildCardAction.h"

NS_ASSUME_NONNULL_BEGIN

@interface WildCardCustomAction : WildCardAction

@property (nonatomic, retain) NSString* function;
@property (nonatomic, retain) NSArray* args;

@end


@interface WildCardInstanceCustomAction : WildCardAction

@property (nonatomic, retain) NSString* function;
@property (nonatomic, retain) NSArray* args;

@end

NS_ASSUME_NONNULL_END
