//
//  JevilHealth.h
//  devilcore
//
//  Created by Mu Young Ko on 2022/09/03.
//

@import JavaScriptCore;
#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@protocol JevilHealth <JSExport>

+ (void)requestPermission:(NSDictionary*)param:(JSValue *)callback;
+ (void)requestHealthData:(NSDictionary*)param :(JSValue *)callback;

@end

@interface JevilHealth : NSObject <JevilHealth>

@end


NS_ASSUME_NONNULL_END
