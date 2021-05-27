//
//  DevilNaverLoginCallback.h
//  devil
//
//  Created by Mu Young Ko on 2021/05/28.
//  Copyright © 2021 Mu Young Ko. All rights reserved.
//

#import <Foundation/Foundation.h>
@import NaverThirdPartyLogin;

@import devillogin;

NS_ASSUME_NONNULL_BEGIN

@interface DevilNaverLoginCallback : NSObject<DevilNaverLoginDelegate,NaverThirdPartyLoginConnectionDelegate>

@end

NS_ASSUME_NONNULL_END
