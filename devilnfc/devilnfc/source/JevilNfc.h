//
//  JevilNfc.h
//  devilnfc
//
//  Created by Mu Young Ko on 2022/09/23.
//

#import <Foundation/Foundation.h>
@import JavaScriptCore;

NS_ASSUME_NONNULL_BEGIN

@protocol JevilNfc <JSExport>

+ (void)start:(NSDictionary*)param :(JSValue*)callback;
+ (void)stop;

@end

@interface JevilNfc : NSObject <JevilNfc>

@end


NS_ASSUME_NONNULL_END
