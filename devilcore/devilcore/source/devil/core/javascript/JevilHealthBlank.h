//
//  JevilHealthBlank.h
//  devilcore
//
//  Created by Mu Young Ko on 2022/09/29.
//
@import JavaScriptCore;

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@protocol JevilHealthBlank <JSExport>
+ (void)requestPermission:(NSDictionary*)param:(JSValue *)callback;
+ (void)requestHealthData:(NSDictionary*)param :(JSValue *)callback;
@end

@interface JevilHealthBlank : NSObject <JevilHealthBlank>

@end


NS_ASSUME_NONNULL_END
