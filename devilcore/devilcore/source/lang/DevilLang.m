//
//  DevilLang.m
//  devilcore
//
//  Created by Mu Young Ko on 2022/02/09.
//

#import "DevilLang.h"

@implementation DevilLang

static NSMutableDictionary* lang;
static NSString* currentLang;
NSRegularExpression *regex;

+(void)setCurrentLang:(NSString*)lang{
    currentLang = lang;
    [[NSUserDefaults standardUserDefaults] setObject:lang forKey:@"LANG"];
    [[NSUserDefaults standardUserDefaults] synchronize];
}

+(NSString*)getCurrentLang{
    if(!currentLang) {
        currentLang = [[NSUserDefaults standardUserDefaults] objectForKey:@"LANG"];
        if(currentLang == nil)
            currentLang = [[[NSLocale preferredLanguages] firstObject] substringToIndex:2];
    }
    return currentLang;
}

+(void)load{
    NSString *filepath = [[NSBundle mainBundle] pathForResource:@"lang" ofType:@"json"];
    NSError *error;
    NSString *fileContents = [NSString stringWithContentsOfFile:filepath encoding:NSUTF8StringEncoding error:&error];
    
    NSData *jsonData = [fileContents dataUsingEncoding:NSUTF8StringEncoding];
    NSError *e;
    id dic = [NSJSONSerialization JSONObjectWithData:jsonData options:nil error:&e];
    id ks = [dic allKeys];
    lang = [@{} mutableCopy];
    
    NSString *regexToReplaceRawLinks = @"[\t\n\r ]";
    regex = [NSRegularExpression regularExpressionWithPattern:regexToReplaceRawLinks
                                                                           options:NSRegularExpressionCaseInsensitive
                                                                             error:&error];
    
    for(id k in ks){
        NSString *trimKey = [regex stringByReplacingMatchesInString:k
                                                                   options:0
                                                                     range:NSMakeRange(0, [k length])
                                                              withTemplate:@""];
        lang[trimKey] = dic[k];
    }
}

+(NSString*)trans:(NSString*)name{
    NSString* oname = name;
    name = [regex stringByReplacingMatchesInString:name options:0
                                                          range:NSMakeRange(0, [name length])
                                                   withTemplate:@""];
    id r = lang[name];
    if(r == nil)
        return oname;
    
    NSString* r2 = r[[DevilLang getCurrentLang]];
    if(r2 == nil || [[r2 class] isEqual:[NSNull class]])
        return oname;
    return r2;
}

+(void)parseLanguage:(id)language {
    id ks = [language allKeys];
    NSString *regexToReplaceRawLinks = @"[\t\n\r ]";
    NSError *error;
    regex = [NSRegularExpression regularExpressionWithPattern:regexToReplaceRawLinks
                                                                           options:NSRegularExpressionCaseInsensitive
                                                                             error:&error];
    for(id key in ks) {
        id value = language[key];
        
        NSString *trimKey = [regex stringByReplacingMatchesInString:key
                                                                   options:0
                                                                     range:NSMakeRange(0, [key length])
                                                              withTemplate:@""];
        
        lang[trimKey] = value;
    }
}

@end
