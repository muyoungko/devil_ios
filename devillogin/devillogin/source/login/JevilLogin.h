//
//  Jevil.h
//  devilcore
//
//  Created by Mu Young Ko on 2020/12/15.
//

@import JavaScriptCore;

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@protocol JevilLogin <JSExport>

+ (void)loginKakao:(JSValue *)callback;
+ (void)loginFacebook:(JSValue *)callback;
+ (void)loginGoogle:(JSValue *)callback;

@end

@interface JevilLogin : NSObject <JevilLogin>

@end

NS_ASSUME_NONNULL_END
