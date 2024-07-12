//
//  WildCardFunction.m
//  CloudJsonViewer
//
//  Created by Mu Young Ko on 2018. 9. 21..
//  Copyright © 2018년 Mu Young Ko. All rights reserved.
//

#import "WildCardFunction.h"
#import "MappingSyntaxInterpreter.h"
#import "ReplaceRuleRepeat.h"

@implementation WildCardFunctionManager
+ (id)sharedInstance {
    static WildCardFunctionManager *sharedInstance = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        sharedInstance = [[self alloc] init];
    });
    return sharedInstance;
}
- (id) init {
    id r = [super init];
    _functions = [[NSMutableDictionary alloc] init];
    
    NSString* (^comma)(NSArray*, NSDictionary*) = ^(NSArray* args, NSDictionary* data) {
        if(args == nil || [args count] == 0)
            return @"";
        NSString* arg = [args objectAtIndex:0];
    
        NSObject* g = [MappingSyntaxInterpreter getJsonWithPath:data :arg];
        if(g == nil)
            return @"";
        if([g isKindOfClass:[NSNumber class]])
            g = [(NSNumber*)g stringValue];
        
        if(![g isKindOfClass:[NSString class]])
            return @"";
        
        NSString* a = (NSString*)g;
        
        if([a length] > 0)
        {
            int bufLen = (int)([a length] + ([a length]-1)/3);
            char buffer[bufLen+1];
            int bufferIndex = bufLen -1;
            int rLen = 1;
            for (int i = (int)([a length] - 1); i >= 0; i--) {
                
                buffer[bufferIndex--] = [a characterAtIndex:i];
                
                if ((rLen % 3) == 0 && i != 0 && bufferIndex > 0)
                    buffer[bufferIndex--] = ',';
                rLen++;
            };
            
            buffer[bufLen] = 0;
            
            if(bufLen == 1)
                a = [NSString stringWithFormat:@"%c", buffer[0]];
            else
                a = [NSString stringWithFormat:@"%s", buffer];
        }
        return a;
    };
    [_functions setObject:comma forKey:@"comma"];
    
    NSString* (^len)(NSArray*, NSDictionary*) = ^(NSArray* args, NSDictionary* data) {
        if(args == nil || [args count] == 0)
            return @"";
        NSString* arg = [args objectAtIndex:0];
        
        NSObject* g = [MappingSyntaxInterpreter getJsonWithPath:data:arg];
        if(g == nil)
            return @"0";
        if(![[g class] isSubclassOfClass:[NSArray class]])
            return @"";
        NSArray* ar = (NSArray*)g;
        return [NSString stringWithFormat:@"%lu", [ar count]];
    };
    [_functions setObject:len forKey:@"len"];
    
    
    NSString* (^enc)(NSArray*, NSDictionary*) = ^(NSArray* args, NSDictionary* data) {
        if(args == nil || [args count] < 1)
            return @"";
        NSString* arg = [args objectAtIndex:0];
        
        NSString* encode = nil;
        if([args count] >= 2)
            encode = [args objectAtIndex:1];
        
        NSObject* g = [MappingSyntaxInterpreter getJsonWithPath:data:arg];
        if(![[g class] isSubclassOfClass:[NSString class]])
            return @"";
        NSString* s = (NSString*)g;
        
        if(encode == nil)
        {
            s = [s stringByAddingPercentEncodingWithAllowedCharacters:[NSCharacterSet URLHostAllowedCharacterSet]];
        }
        else
        {
            //TODO euc-kr
            s = [s stringByAddingPercentEncodingWithAllowedCharacters:[NSCharacterSet URLHostAllowedCharacterSet]];
        }
        return s;
    };
    [_functions setObject:enc forKey:@"enc"];
    
    NSString* (^selected_index)(NSArray*, NSDictionary*) = ^(NSArray* args, NSDictionary* data) {
        NSMutableArray* list = (NSMutableArray*)[MappingSyntaxInterpreter getJsonWithPath:data:[args objectAtIndex:0]];
        if(list == nil || ![[list class] isKindOfClass:[NSArray class]])
            return @"0";
        
        for(int i=0;i<[list count];i++)
        {
            if([@"Y" isEqualToString:list[i][WC_SELECTED]])
            {
                return [NSString stringWithFormat:@"%d",i];
            }
        }
        return @"0";
    };
    [_functions setObject:selected_index forKey:@"selected_index"];
    
    
    NSString* (^count)(NSArray*, NSDictionary*) = ^(NSArray* args, NSDictionary* data) {
        if(args == nil || [args count] == 0)
            return @"";
        NSString* ifExpression = [args objectAtIndex:0];
        NSString* arrJsonPath = [args objectAtIndex:1];
        
        ifExpression = [ifExpression stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]];
        
        arrJsonPath = [arrJsonPath stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]];
        
        NSObject* g = [MappingSyntaxInterpreter getJsonWithPath:data:arrJsonPath];
        if(![[g class] isSubclassOfClass:[NSArray class]])
            return @"";
        NSArray* ar = (NSArray*)g;
        int r = 0;
        for(int i=0;i<[ar count];i++)
        {
            if([MappingSyntaxInterpreter ifexpression:ifExpression data:ar[i]])
                r++;
        }
        return [NSString stringWithFormat:@"%d", r];
    };
    [_functions setObject:count forKey:@"count"];
    
    
    NSString* (^this_index)(NSArray*, NSDictionary*) = ^(NSArray* args, NSDictionary* data) {
        NSString* index = data[WC_INDEX];
        return index;
    };
    [_functions setObject:this_index forKey:@"this_index"];
    
    
    return r;
}

- (BOOL)getBoolWithFunction:(NSString*)functionString data: (JSValue*)data defaultValue:(BOOL)defaultValue
{
    NSArray* sp = [functionString componentsSeparatedByString:@"("];
    NSString* functionName = [sp objectAtIndex:0];
    functionName = [functionName stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]];
    NSRange s = [functionString rangeOfString:@"("];
    NSRange e = [functionString rangeOfString:@")" options:NSBackwardsSearch];
    
    NSString* argument = [functionString substringWithRange:NSMakeRange(s.location+1, e.location- s.location-1)];
    NSArray* args = [argument componentsSeparatedByString:@","];
    
    static dispatch_once_t boolFunctionToken;
    dispatch_once(&boolFunctionToken, ^{
        _boolFunctions = [[NSMutableDictionary alloc] init];
        
        BOOL (^empty)(NSArray*, JSValue*) = ^(NSArray* args, JSValue* data) {
            NSString* value = [MappingSyntaxInterpreter interpret:args[0]:data];
            if(value == nil || [value isEqualToString:@"<null>"] || [value isEqualToString:@""] || [value isEqualToString:@"{\n}"] || [value isEqualToString:@"(\n)"])
                return YES;
            else
                return NO;
        };
        [_boolFunctions setObject:empty forKey:@"empty"];
        
        BOOL (^number)(NSArray*, JSValue*) = ^(NSArray* args, JSValue* data) {
            NSString* value = [MappingSyntaxInterpreter interpret:[args objectAtIndex:0]:data];
            if(value == nil || [value isEqualToString:@""])
                return defaultValue;
            else
            {
                NSCharacterSet* notDigits = [[NSCharacterSet decimalDigitCharacterSet] invertedSet];
                if ([value rangeOfCharacterFromSet:notDigits].location == NSNotFound)
                    return YES;
                else
                    return NO;
            }
        };
        [_boolFunctions setObject:number forKey:@"number"];
        
        
        BOOL (^last_index)(NSArray*, JSValue*) = ^(NSArray* args, JSValue* data) {
            
            int index = [data[WC_INDEX] toInt32];
            int length = [data[WC_LENGTH] toInt32];
            
            if( length-1 == index)
                return YES;
            else
                return NO;
        };
        [_boolFunctions setObject:last_index forKey:@"last_index"];

    });
    
    BOOL (^function)(NSArray*, JSValue*) = [_boolFunctions objectForKey:functionName];
    
    BOOL r = defaultValue;
    if(function == nil)
    {
        return r;
    }
    else{
        BOOL r = function(args, data);
        return r;
    }
}


- (NSString*)getValueWithFunction:(NSString*)functionString data: (JSValue*)data
{
    NSArray* sp = [functionString componentsSeparatedByString:@"("];
    NSString* functionName = [sp objectAtIndex:0];
    NSString* argument = [[sp objectAtIndex:1] stringByReplacingOccurrencesOfString:@")" withString:@""];
    NSArray* args = [argument componentsSeparatedByString:@","];
    
    NSString* (^function)(NSArray*, JSValue*) = [_functions objectForKey:functionName];
    NSString *r = @"";
    if(function == nil)
    {
        return r;
    }
    else{
        NSString* r = function(args, data);
        return r;
    }
}


+ (void) logCharacterSet:(NSCharacterSet*)characterSet
{
    unichar unicharBuffer[20];
    int index = 0;
    
    for (unichar uc = 0; uc < (0xFFFF); uc ++)
    {
        if ([characterSet characterIsMember:uc])
        {
            unicharBuffer[index] = uc;
            
            index ++;
            
            if (index == 20)
            {
                NSString * characters = [NSString stringWithCharacters:unicharBuffer length:index];
                NSLog(@"%@", characters);
                
                index = 0;
            }
        }
    }
    
    if (index != 0)
    {
        NSString * characters = [NSString stringWithCharacters:unicharBuffer length:index];
        NSLog(@"%@", characters);
    }
}
@end
