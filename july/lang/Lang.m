//
//  Lang.m
//  gribjt
//
//  Created by Mu Young Ko on 2019. 8. 21..
//  Copyright © 2019년 Grib. All rights reserved.
//

#import "Lang.h"

@implementation Lang


static NSMutableDictionary* lang;
NSRegularExpression *regex;

+(void)setCurrentLang:(NSString*)lang{
    [[NSUserDefaults standardUserDefaults] setObject:lang forKey:@"LANG"];
    [[NSUserDefaults standardUserDefaults] synchronize];
}

+(NSString*)getCurrentLang{
    NSString* r = [[NSUserDefaults standardUserDefaults] objectForKey:@"LANG"];
    if(r == nil)
        r = [[[NSLocale preferredLanguages] firstObject] substringToIndex:2];
    
    return r;
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
    //[2단계] 로그인 후 메인화면에서 [개통ID 등록] 버튼을 눌러 개통ID를 입력해 주세요.,
    name = [regex stringByReplacingMatchesInString:name
                                                        options:0
                                                          range:NSMakeRange(0, [name length])
                                                   withTemplate:@""];
    id r = lang[name];
    if(r == nil)
        return oname;
    
    NSString* r2 = r[[Lang getCurrentLang]];
    if(r2 == nil || [[r2 class] isEqual:[NSNull class]])
        return oname;
    return r2;
}

@end
