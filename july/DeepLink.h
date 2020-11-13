//
//  DeepLink.h
//  bnbhost
//
//  Created by Mu Young Ko on 2020/06/27.
//  Copyright © 2020 july. All rights reserved.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN


@interface DeepLink : NSObject

+(DeepLink*)sharedInstance;

-(void)reserveDeepLink:(NSString*)url;
-(void)consumeDeepLink;

@end

NS_ASSUME_NONNULL_END
