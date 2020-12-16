//
//  JevilCtx.m
//  devilcore
//
//  Created by Mu Young Ko on 2020/12/15.
//

@import JavaScriptCore;

#import "JevilCtx.h"
#import "Jevil.h"

@interface JevilCtx ()

@property (nonatomic, retain) JSContext* jscontext;

@end


@implementation JevilCtx

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

-(NSString*)code:(NSString*)code viewController:(UIViewController*)viewController data:(id)data meta:(WildCardMeta*)meta{
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
