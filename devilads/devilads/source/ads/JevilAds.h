//
//  JevilAds.h
//  devilads
//
//  Created by Mu Young Ko on 2022/06/25.
//

@import JavaScriptCore;

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@protocol JevilAds <JSExport>

+ (void)test:(NSDictionary*)param:(JSValue *)callback;

@end

@interface JevilAds : NSObject <JevilAds>

@end

NS_ASSUME_NONNULL_END
