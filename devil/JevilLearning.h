//
//  JevilLearning.h
//  devil
//
//  Created by Mu Young Ko on 2022/01/10.
//  Copyright © 2022 Mu Young Ko. All rights reserved.
//

@import JavaScriptCore;

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@protocol JevilLearning<JSExport>
 
+ (void)success;
+ (NSString*)getText:(NSString*)node;
+ (NSString*)getImage:(NSString*)node;
+ (void)click:(NSString*)node;
+ (void)waitAlert:(NSString*)alertText :(int)sec :(JSValue*)callback;
+ (void)reload:(JSValue*)callback;

@end

@interface JevilLearning : NSObject <JevilLearning>

@end

NS_ASSUME_NONNULL_END
