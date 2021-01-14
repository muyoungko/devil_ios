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
#import "JevilInstance.h"

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
            NSString* msg = [NSString stringWithFormat:@"%@", exception];
            UIAlertController *alertController = [UIAlertController alertControllerWithTitle:msg
                                                                             message:nil
                                                                      preferredStyle:UIAlertControllerStyleAlert];

            [alertController addAction:[UIAlertAction actionWithTitle:@"Ok"
                                                              style:UIAlertActionStyleCancel
                                                            handler:^(UIAlertAction *action) {
                                                                
            }]];
            [[JevilInstance currentInstance].vc presentViewController:alertController animated:YES completion:^{}];
        }];
        
    }
    return self;
}

-(NSString*)code:(NSString*)code viewController:(UIViewController*)vc data:(id)data meta:(WildCardMeta*)meta{
    [JevilInstance currentInstance].vc = vc;
    [JevilInstance currentInstance].meta = meta;
    [JevilInstance currentInstance].data = data;
    [JevilInstance currentInstance].jscontext = self.jscontext;
    
    id config_list = [WildCardConstructor sharedInstance].project[@"config_list"];
    if(config_list != nil && config_list != [NSNull null]){
        for(id c in config_list){
            NSString* name = c[@"name"];
            NSString* value = c[@"value"];
            self.jscontext[name] = value;
        }
    }
    self.jscontext[@"data"] = data;
    if(meta != nil)
        self.jscontext[@"thisData"] = meta.correspondData;
    
    JSValue* r = [self.jscontext evaluateScript:code];
    JSValue* dataJs = [self.jscontext evaluateScript:@"data"];
    id newData = [dataJs toDictionary];
    id allKey = [newData allKeys];
    for(id k in allKey) {
        data[k] = newData[k]; 
    }
    
    if(meta != nil){
        //TODO thisData의 sync를 맞춰야함
    }
        
    return [r toString];
}
@end
