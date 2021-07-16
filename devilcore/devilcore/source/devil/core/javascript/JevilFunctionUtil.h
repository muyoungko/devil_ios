//
//  JevilFunctionUtil.h
//  devilcore
//
//  Created by Mu Young Ko on 2021/07/16.
//

#import <Foundation/Foundation.h>

@import JavaScriptCore;

NS_ASSUME_NONNULL_BEGIN

@interface JevilFunctionUtil : NSObject

+(JevilFunctionUtil*)sharedInstance;
-(void)registFunction:(JSValue*)function;
-(void)callFunction:(JSValue*)function params:(id)params;
-(void)clear;

@end

NS_ASSUME_NONNULL_END
