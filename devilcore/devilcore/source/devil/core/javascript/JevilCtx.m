//
//  JevilCtx.m
//  devilcore
//
//  Created by Mu Young Ko on 2020/12/15.
//

@import JavaScriptCore;

#import "JevilCtx.h"
#import "Jevil.h"
#import "WildCardConstructor.h"

@interface JevilCtx ()

@property (nonatomic, retain) JSContext* jscontext;

@end


@implementation JevilCtx

+(Jevil*)sharedInstance{
    static JevilCtx *sharedInstance = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        sharedInstance = [[JevilCtx alloc] init];
    });
    return sharedInstance;
}

- (instancetype)init
{
    self = [super init];
    if (self) {
        self.jscontext = [[JSContext alloc] init];
        self.jscontext[@"Jevil"] = [Jevil class];
        [self.jscontext setExceptionHandler:^(JSContext *context, JSValue *exception) {
            NSLog(@"%@",exception); 
        }];
        
        
    }
    return self;
}

-(NSString*)code:(NSString*)code viewController:(UIViewController*)vc data:(id)data meta:(WildCardMeta*)meta{
    [JevilCtx sharedInstance].vc = vc;
    self.jscontext[@"data"] = data;
    
    id config_list = [WildCardConstructor sharedInstance].project[@"config_list"];
    for(id c in config_list){
        NSString* name = c[@"name"];
        NSString* value = c[@"value"];
        self.jscontext[name] = value;
    }
    self.jscontext[@"data"] = data;
    
    JSValue* r = [self.jscontext evaluateScript:code];
    JSValue* dataJs = [self.jscontext evaluateScript:@"data"];
    id newData = [dataJs toDictionary];
    id allKey = [newData allKeys];
    for(id k in allKey) {
        data[k] = newData[k]; 
    }
    return [r toString];
}
@end
