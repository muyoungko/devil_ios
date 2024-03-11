//
//  DevilLang.m
//  devilcore
//
//  Created by Mu Young Ko on 2022/02/09.
//

#import "DevilLang.h"
#import "WildCardConstructor.h"
#import "JevilInstance.h"
#import "DevilController.h"

@interface DevilLang()
@end

@implementation DevilLang

static NSMutableDictionary* lang;
static NSString* currentLang;
NSRegularExpression *regex;

+(DevilLang*)sharedInstance {
    static DevilLang *sharedInstance = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        sharedInstance = [[self alloc] init];
    });
    return sharedInstance;
}

+(void)setCurrentLang:(NSString*)lang{
    currentLang = lang;
    NSString* key = [NSString stringWithFormat:@"LANG_%@", [WildCardConstructor sharedInstance].project_id];
    [[NSUserDefaults standardUserDefaults] setObject:lang forKey:key];
    [[NSUserDefaults standardUserDefaults] synchronize];
}

+(NSString*)getCurrentLang{
    return currentLang;
}

+(void)loadDefault {
    NSBundle *bundle = [NSBundle bundleForClass:[self class]];
    NSString *filepath = [bundle pathForResource:@"lang" ofType:@"json"];
    NSError *error;
    NSString *fileContents = [NSString stringWithContentsOfFile:filepath encoding:NSUTF8StringEncoding error:&error];
    
    NSData *jsonData = [fileContents dataUsingEncoding:NSUTF8StringEncoding];
    NSError *e;
    id dic = [NSJSONSerialization JSONObjectWithData:jsonData options:nil error:&e];
    id ks = [dic allKeys];
    
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

+(void)parseLanguage:(id)language :(BOOL)collect_prod {
    
    NSString* key = [NSString stringWithFormat:@"LANG_%@", [WildCardConstructor sharedInstance].project_id];
    NSString* savedLang = [[NSUserDefaults standardUserDefaults] objectForKey:key];
    if(savedLang)
        currentLang = savedLang;
    else
        currentLang = [[[NSLocale preferredLanguages] firstObject] substringToIndex:2];
    
    lang = [@{} mutableCopy];
    [DevilLang loadDefault];

    [DevilLang sharedInstance].multiLanguage = [language count] > 0;
    [DevilLang sharedInstance].collectLanguage = [[[NSBundle mainBundle] bundleIdentifier] isEqualToString:@"kr.co.july.CloudJsonViewer"] || collect_prod;
    [DevilLang sharedInstance].sent = [[NSMutableDictionary alloc] init];
    [DevilLang sharedInstance].sentWait = [[NSMutableDictionary alloc] init];
    
    id ks = [language allKeys];
    NSString *regexToReplaceRawLinks = @"[\t\n\r ]";
    NSError *error;
    regex = [NSRegularExpression regularExpressionWithPattern:regexToReplaceRawLinks
                                                                           options:NSRegularExpressionCaseInsensitive
                                                                            error:&error];
    
    [DevilLang loadDefault];
    for(id key in ks) {
        id value = language[key];
        
        NSString *trimKey = [regex stringByReplacingMatchesInString:key
                                                                   options:0
                                                                     range:NSMakeRange(0, [key length])
                                                              withTemplate:@""];
        
        lang[trimKey] = value;
    }
}

+(NSString*)trans:(NSString*)name {
    return [DevilLang trans:name:nil];
}
+(NSString*)trans:(NSString*)name :(NSString*)node {
    if(![DevilLang sharedInstance].multiLanguage)
        return name;
    
    NSString* oname = name;
    name = [regex stringByReplacingMatchesInString:name options:0
                                                          range:NSMakeRange(0, [name length])
                                                   withTemplate:@""];
    
    id r = lang[name];
    if(r == nil) {
        [[DevilLang sharedInstance] sendLanguageKey:oname :node];
        return oname;
    }
    
    NSString* r2 = r[[DevilLang getCurrentLang]];
    if(r2 == nil || [r2 isEqualToString:@""] || [[r2 class] isEqual:[NSNull class]])
        return oname;
    
    return r2;
}

-(void)sendLanguageKey:(NSString*)key :(NSString*)node {
    if(![DevilLang sharedInstance].collectLanguage)
        return;
    
    if([DevilLang sharedInstance].sent[key])
        return;
    
    if(!key)
        return;
    
    id param = [@{} mutableCopy];
    param[@"project_id"] = ((DevilController*)[JevilInstance currentInstance].vc).projectId;
    param[@"screen_id"] = ((DevilController*)[JevilInstance currentInstance].vc).screenId;
    if(node)
        param[@"node"] = node;
    [DevilLang sharedInstance].sentWait[key] = param;
}

-(void) flush {
    if(![DevilLang sharedInstance].collectLanguage)
        return;
    
    if([[DevilLang sharedInstance].sentWait count] == 0)
        return;
    
    id param = [@{} mutableCopy];
    param[@"list"] = [@[] mutableCopy];
    
    id ks = [[DevilLang sharedInstance].sentWait allKeys];
    for(id key in ks) {
        id value = [DevilLang sharedInstance].sentWait[key];
        id a = [@{
            @"key":key,
            @"project_id":[NSNumber numberWithInt:[value[@"project_id"] intValue]],
            @"screen_id":[NSNumber numberWithInt:[value[@"screen_id"] intValue]],
        } mutableCopy];
        
        if(value[@"node"])
            a[@"node"] = value[@"screen_id"];
        [param[@"list"] addObject: a];
    }
    
    NSString* tokenKey = @"x-access-token_1605234988599";
    NSString* token = [[NSUserDefaults standardUserDefaults] objectForKey:tokenKey];
    if(token) {
        [[WildCardConstructor sharedInstance].delegate onNetworkRequestPost:@"https://console-api.deavil.com/api/language/candidate" header:@{
            @"x-access-token" : token
        } json:param success:^(NSMutableDictionary *res) {
            if(res && [res[@"r"] boolValue]) {
                
                id ks = [[DevilLang sharedInstance].sentWait allKeys];
                for(id key in ks)
                    [DevilLang sharedInstance].sent[key] = key;
                
                [[DevilLang sharedInstance].sentWait removeAllObjects];
            }
        }];
    }
}

-(void)clear {
    [lang removeAllObjects];
    [DevilLang sharedInstance].sent = [[NSMutableDictionary alloc] init];
    [DevilLang sharedInstance].sentWait = [[NSMutableDictionary alloc] init];
}

@end
