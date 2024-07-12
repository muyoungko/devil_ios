//
//  WildCardFunction.h
//  CloudJsonViewer
//
//  Created by Mu Young Ko on 2018. 9. 21..
//  Copyright © 2018년 Mu Young Ko. All rights reserved.
//

#import <Foundation/Foundation.h>
@import JavaScriptCore;

@interface WildCardFunctionManager : NSObject

+ (id)sharedInstance;
- (NSString*)getValueWithFunction:(NSString*)functionString data: (JSValue*)data;

- (BOOL)getBoolWithFunction:(NSString*)functionString data: (JSValue*)data defaultValue:(BOOL)defaultValue;

@property (retain, nonatomic) NSMutableDictionary* functions;
@property (retain, nonatomic) NSMutableDictionary* boolFunctions;

@end


