//
//  MappingSyntaxInterpreter.h
//  CloudJsonViewer
//
//  Created by Mu Young Ko on 2018. 6. 19..
//  Copyright © 2018년 Mu Young Ko. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface MappingSyntaxInterpreter : NSObject

+(NSObject*) getJsonWithPath:(NSObject*)s : (NSString*) path;
+(NSObject*) getJsonFromString:(NSObject*) s : (NSArray*) target : (int) index;
+(NSString*) interpret:(NSString*) tomb : (NSDictionary*) data;
+(NSString*) getfunctionValue:(NSString*) text : (NSDictionary*) data;


+(BOOL) ifexpression:(NSString*)ifexpression data:(NSDictionary*) data;

+(BOOL) ifexpression:(NSString*)ifexpression data:(NSDictionary*) data defaultValue:(BOOL)value;

+(BOOL) ifexpressionRecur:(NSString*)ifexpression data:(NSDictionary*) data defaultValue:(BOOL)defaultIfLeftNull;

+(BOOL) ifexpressionUnit:(NSString*)ifexpression data:(NSDictionary*)data defaultValue:(BOOL)defaultIfLeftNull;

+(NSArray*)devideSyntax:(NSString*)str;

+(NSString*)getArgument:(NSString*)func;
@end
