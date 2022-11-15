//
//  JevilAnimation.h
//  devilcore
//
//  Created by Mu Young Ko on 2022/11/14.
//

#import <Foundation/Foundation.h>
@import JavaScriptCore;

NS_ASSUME_NONNULL_BEGIN

@protocol JevilAnimation <JSExport>
+ (void)start:(NSString*)node:(NSDictionary*)param;
+ (void)stop:(NSString*)node;
@end

@interface JevilAnimation : NSObject <JevilAnimation>

@end

NS_ASSUME_NONNULL_END
