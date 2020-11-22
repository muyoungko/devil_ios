//
//  WildCardSetTextAction.h
//  library
//
//  Created by Mu Young Ko on 2018. 11. 11..
//  Copyright © 2018년 sbs cnbc. All rights reserved.
//

#import "WildCardAction.h"

NS_ASSUME_NONNULL_BEGIN

@interface WildCardSetTextAction : WildCardAction

@property (nonatomic, retain) NSString* targetNodeName;
@property (nonatomic, retain) NSString* jsonPath;

@end

@interface WildCardSetValueAction : WildCardAction

@property (nonatomic, retain) NSString* toJsonPath;

@property (nonatomic, retain) NSString* targetjsonPath;

@end

NS_ASSUME_NONNULL_END
