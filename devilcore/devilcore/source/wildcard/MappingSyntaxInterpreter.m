//
//  MappingSyntaxInterpreter.m
//  CloudJsonViewer
//
//  Created by Mu Young Ko on 2018. 6. 19..
//  Copyright © 2018년 Mu Young Ko. All rights reserved.
//

#import "MappingSyntaxInterpreter.h"
#import "WildCardFunction.h"

#define trim( str ) [str stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceCharacterSet] ]

@implementation MappingSyntaxInterpreter

+(JSValue*) getJsonWithPath:(JSValue*)s : (NSString*) path
{
    NSArray* target = [path componentsSeparatedByString: @">"];
    return [MappingSyntaxInterpreter getJsonFromString:s :target : 0];
}

+(JSValue*) getJsonFromString:(JSValue*) s : (NSArray*) target : (int) index
{
    if(s == nil || [s isUndefined])
        return nil;
    
    if([target count] <= index)
        return s;
    
    NSString *nowKey = [target objectAtIndex:index];
    if([s isObject])
    {
        JSValue* p = s[nowKey];
        return [MappingSyntaxInterpreter getJsonFromString:p:target:(index+1)];
    }
    else if([s isArray])
    {
        int arrayIndex = [nowKey intValue];
        JSValue* p = s[arrayIndex];
        if([MappingSyntaxInterpreter isNumber:nowKey])
            return [MappingSyntaxInterpreter getJsonFromString:p:target:(index+1)];
        else
            return nil;
    }
    return nil;
}

+ (BOOL) isNumber:(NSString*)s
{
    NSCharacterSet* nonNumbers = [[NSCharacterSet decimalDigitCharacterSet] invertedSet];
    NSRange r = [s rangeOfCharacterFromSet: nonNumbers];
    return r.location == NSNotFound && s.length > 0;
}

+(NSString*) interpret:(NSString*) tomb : (JSValue*) data
{
    //2022 02 23 tomb가 null이면 data를 json stringify하여 반환한다.
    if(tomb == nil)
        return @"";
    
    tomb = trim(tomb);
    if([@"true" isEqualToString:tomb] || [@"false" isEqualToString:tomb]) {
        return tomb;
    }
    else if([tomb hasPrefix:@"'"])
    {
        return [tomb stringByReplacingOccurrencesOfString:@"'" withString:@""];
    }
    else if([tomb hasPrefix:@"/"])
    {
        NSArray* rs = [[tomb substringFromIndex:1] componentsSeparatedByString:@"+"];
        NSString* text = @"";
        for(int i=0;i<[rs count];i++)
        {
            NSString* r = rs[i];
            r = [r stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]];
            if([r hasPrefix:@"'"])
            {
                NSString* surfix = [r stringByReplacingOccurrencesOfString:@"'" withString:@""];
                // when surfix is %, it should be invisible prefix is not number
                if([surfix isEqualToString:@"%"])
                {
                    if( [MappingSyntaxInterpreter isNumber:text] )
                    {
                        text = [text stringByAppendingString:surfix];
                    }
                }
                else
                {
                    text = [text stringByAppendingString:surfix];
                }
            }
            else
            {
                if([r rangeOfString:@"("].length > 0 ){
                    text = [text stringByAppendingString:[MappingSyntaxInterpreter getfunctionValue:r :data]];
                }
                else
                {
                    JSValue* ss = [MappingSyntaxInterpreter getJsonWithPath:data :r];
                    NSString* s = @"";
                    if(ss != nil)
                        s = [ss toString];
                    
                    text = [text stringByAppendingString:s];
                }
            }
        }
        return text;
    }
    else
    {
        NSScanner *scanner = [NSScanner scannerWithString:tomb];
        BOOL isNumeric = [scanner scanInteger:NULL] && [scanner isAtEnd];
        NSString *text = nil;
        if(isNumeric) {
            return tomb;
        } else if([tomb rangeOfString:@"("].length > 0 ){
            text = [MappingSyntaxInterpreter getfunctionValue:tomb :data];
        }
        else
        {
            JSValue* o = [MappingSyntaxInterpreter getJsonWithPath:data :tomb];
            text = [o toString];
        }
        return text;
    }
    
}

+(NSString*) getfunctionValue:(NSString*) text : (NSDictionary*) data
{
    return [[WildCardFunctionManager sharedInstance] getValueWithFunction:text data:data];
}


+(BOOL) ifexpression:(NSString*)ifexpression data:(JSValue*) data
{
    return [MappingSyntaxInterpreter ifexpressionRecur:ifexpression data:data defaultValue:NO];
}

+(BOOL) ifexpression:(NSString*)ifexpression data:(JSValue*) data defaultValue:(BOOL)value
{
    return [MappingSyntaxInterpreter ifexpressionRecur:ifexpression  data:data defaultValue:value];
}

+(NSArray*)devideSyntax:(NSString*)str
{
    NSMutableArray *r = [[NSMutableArray alloc] init];
    
    str = [str stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]];
    
    if([str hasPrefix:@"("])
        str = [str substringWithRange:NSMakeRange(1, [str length]-2)];
    
    if([str hasPrefix:@"("])
        str = [str substringWithRange:NSMakeRange(1, [str length]-2)];
    
    if([str hasPrefix:@"("])
        str = [str substringWithRange:NSMakeRange(1, [str length]-2)];
    
    int depth = 0;
    int cursor = 0;
    unichar previous = 0;
    for(int i=0;i<[str length];i++)
    {
        unichar c = [str characterAtIndex:i];
        switch(c)
        {
            case '(':
                depth ++;
                break;
            case ')':
                depth --;
                break;
            case '&':
                if(depth == 0)
                {
                    if(previous != '&') {
                        NSString* a = [str substringWithRange: NSMakeRange(cursor, i-cursor)];
                        a = [a stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]];
                        if(![a isEqualToString:@""])
                            [r addObject:a];
                        cursor = i;
                    }
                }
                break;
            case '|':
                if(depth == 0)
                {
                    if(previous != '|') {
                        NSString* a = [str substringWithRange: NSMakeRange(cursor, i-cursor)];
                        a = [a stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]];
                        if(![a isEqualToString:@""])
                            [r addObject:a];
                        cursor = i;
                    }
                }
                break;
                
        }
        previous = c;
    }
    
    NSString* a = [str substringWithRange: NSMakeRange(cursor, [str length]-cursor)];
    a = [a stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]];
    if(![a isEqualToString:@""])
        [r addObject:a];
    
    return r;
}

+(BOOL) ifexpressionRecur:(NSString*)ifexpression data:(JSValue*)data  defaultValue:(BOOL)defaultIfLeftNull
{
    BOOL r = true;
    
    NSArray* units = [MappingSyntaxInterpreter devideSyntax:ifexpression];
    if(units != nil && [units count] == 1)
    {
        r = [MappingSyntaxInterpreter ifexpressionUnit:[units objectAtIndex:0] data:data defaultValue:defaultIfLeftNull];
    }
    else
    {
        for (int i = 0; units != nil && i < [units count]; i++) {
            if (i > 0) {
                NSString* unit = [units objectAtIndex:i];
                if([unit hasPrefix:@"&&"])
                {
                    if(!r)
                        break;
                    r = r && [MappingSyntaxInterpreter ifexpressionUnit:[unit substringFromIndex:2] data:data defaultValue:defaultIfLeftNull];
                } else if([unit hasPrefix:@"||"]) {
                    if(r)
                        break;
                    r = r || [MappingSyntaxInterpreter ifexpressionUnit:[unit substringFromIndex:2] data:data defaultValue:defaultIfLeftNull];
                }
            } else {
                r = [MappingSyntaxInterpreter ifexpressionUnit:units[i] data:data defaultValue:defaultIfLeftNull];
            }
        }
    }
    return r;
}


+(BOOL) ifexpressionUnit:(NSString*)ifexpression data:(JSValue*)data defaultValue:(BOOL)defaultIfLeftNull
{
    BOOL r = false;
    BOOL reverse = false;
    if(ifexpression == nil || [ifexpression isEqual:@""])
        r = defaultIfLeftNull;
    else{
        if([ifexpression hasPrefix:@"!"]) {
            ifexpression = [ifexpression stringByReplacingOccurrencesOfString:@"!" withString:@""];
            reverse = true;
        }
        NSRange range = [ifexpression rangeOfString:@"!="];
        int index = (int)range.location;
        if(index > 0 && range.length > 0)
        {
            NSString* left = [ifexpression substringToIndex:index];
            NSString* right = [ifexpression substringFromIndex:index+2];
            
            NSString* targetValue = [MappingSyntaxInterpreter interpret:left:data];
            NSString* compareStr = [MappingSyntaxInterpreter interpret:right:data];
            
            if(targetValue == nil)
                r = YES;
            else
                r = ![targetValue isEqualToString:compareStr];
        }
        else
        {
            NSRange range = [ifexpression rangeOfString:@"=="];
            int index = (int)range.location;
            if(index >= 0  && range.length > 0)
            {
                NSString* left = [ifexpression substringToIndex:index];
                NSString* right = [ifexpression substringFromIndex:index+2];
                
                NSString* targetValue = [MappingSyntaxInterpreter interpret:left:data];
                NSString* compareStr = [MappingSyntaxInterpreter interpret:right:data];
                
                if(targetValue == nil)
                    r = NO;
                else
                    r = [targetValue isEqualToString:compareStr];
            }
            // this means function
            else {
                r = [[WildCardFunctionManager sharedInstance] getBoolWithFunction:ifexpression data:data defaultValue:defaultIfLeftNull];
            }
        }
        
    }
    
    if(reverse)
        r = !r;
    return r;
}

+(NSString*)getArgument:(NSString*)func
{
    NSString* r =  nil;
    int s = (int)[func rangeOfString:@"("].location;
    int e = (int)[func rangeOfString:@")"].location;
    r = [func substringWithRange:NSMakeRange(s, e-s)];
    
    return r;
}

@end
