//
//  MappingSyntaxInterpreter.h
//  CloudJsonViewer
//
//  Created by Mu Young Ko on 2018. 6. 19..
//  Copyright © 2018년 Mu Young Ko. All rights reserved.
//

#import <Foundation/Foundation.h>
@import JavaScriptCore;

@interface MappingSyntaxInterpreter : NSObject

+(JSValue*) getJsonWithPath:(JSValue*)s : (NSString*) path;
+(JSValue*) getJsonFromString:(JSValue*) s : (NSArray*) target : (int) index;
+(NSString*) interpret:(NSString*) tomb : (JSValue*) data;
+(NSString*) getfunctionValue:(NSString*) text : (JSValue*) data;


+(BOOL) ifexpression:(NSString*)ifexpression data:(JSValue*) data;

+(BOOL) ifexpression:(NSString*)ifexpression data:(JSValue*) data defaultValue:(BOOL)value;

+(BOOL) ifexpressionRecur:(NSString*)ifexpression data:(JSValue*) data defaultValue:(BOOL)defaultIfLeftNull;

+(BOOL) ifexpressionUnit:(NSString*)ifexpression data:(JSValue*)data defaultValue:(BOOL)defaultIfLeftNull;

+(NSArray*)devideSyntax:(NSString*)str;

+(NSString*)getArgument:(NSString*)func;
@end
