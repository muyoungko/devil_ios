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

+ (void)loadAds:(NSDictionary*)param:(JSValue *)callback;
+ (void)showAds:(NSDictionary*)param:(JSValue *)callback;

@end

@interface JevilAds : NSObject <JevilAds>

@end

NS_ASSUME_NONNULL_END
