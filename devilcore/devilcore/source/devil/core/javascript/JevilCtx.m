//
//  JevilCtx.m
//  devilcore
//
//  Created by Mu Young Ko on 2020/12/15.
//

@import JavaScriptCore;

#import "JevilCtx.h"
#import "Jevil.h"
#import "JevilAnimation.h"
#import "JevilHealthBlank.h"
#import "WildCardConstructor.h"
#import "JevilInstance.h"
#import "JevilUtil.h"
#import "DevilSdk.h"
#import "DevilLang.h"
#import "DevilController.h"

@interface JevilCtx ()

@property BOOL dataInitialized;

@end


@implementation JevilCtx

- (instancetype)init
{
    self = [super init];
    if (self) {
        self.jscontext = [[JSContext alloc] init];
        self.jscontext[@"Jevil"] = [Jevil class];
        self.jscontext[@"JevilAnimation"] = [JevilAnimation class];
        id customJevil = [[DevilSdk sharedInstance] getCustomJevil];
        for(int i=0;i<[customJevil count];i++) {
            NSString* jevilName = NSStringFromClass(customJevil[i]);
            self.jscontext[jevilName] = customJevil[i];
        }
        if([self.jscontext[@"JevilHealth"] toObject] == nil)
           self.jscontext[@"JevilHealth"] = [JevilHealthBlank class];
        
        [self.jscontext setExceptionHandler:^(JSContext *context, JSValue *exception) {
            NSLog(@"%@",exception);
            id line = [exception objectForKeyedSubscript:@"line"];
            if([line isUndefined])
                return;
            NSString* msg = [NSString stringWithFormat:@"line %@, %@",line, exception];
            UIAlertController *alertController = [UIAlertController alertControllerWithTitle:msg
                                                                             message:nil
                                                                      preferredStyle:UIAlertControllerStyleAlert];

            [alertController addAction:[UIAlertAction actionWithTitle:trans(@"OK")
                                                              style:UIAlertActionStyleCancel
                                                            handler:^(UIAlertAction *action) {
                                                                
            }]];
            [[JevilInstance currentInstance].vc presentViewController:alertController animated:YES completion:^{}];
            
            [self sendLogIf:@{@"exception":msg}];
        }];
        
    }
    return self;
}

-(void)sendLogIf:(id)a {
    if(![[[NSBundle mainBundle] bundleIdentifier] isEqualToString:@"kr.co.july.CloudJsonViewer"]) {
        id param = [a mutableCopy];
        param[@"package"] = [[NSBundle mainBundle] bundleIdentifier];
        param[@"project_id"] = [Jevil get:@"PROJECT_ID"];
        param[@"screen"] = ((DevilController*)[JevilInstance currentInstance].vc).screenName;
        param[@"os_version"] = [[UIDevice currentDevice] systemVersion];
        param[@"os"] = @"ios";
        [[WildCardConstructor sharedInstance].delegate onNetworkRequestPost:@"https://console-api.deavil.com/api/report/abnormal" header:@{} json:param success:^(NSMutableDictionary *responseJsonObject) {
            
        }];
    }
}

-(NSString*)code:(NSString*)code viewController:(UIViewController*)vc data:(JSValue*)data meta:(WildCardMeta*)meta {
    return [self code:code viewController:vc data:data meta:meta hide:false];
}

-(NSString*)code:(NSString*)code viewController:(UIViewController*)vc data:(JSValue*)data meta:(WildCardMeta*)meta hide:(BOOL)hide{
    if(!hide) {
        [JevilInstance currentInstance].vc = vc;
        [JevilInstance currentInstance].meta = meta;
        [JevilInstance currentInstance].data = data;
        [JevilInstance currentInstance].jevil = self;
        [JevilInstance currentInstance].jscontext = self.jscontext;
    }
    
    if(!self.dataInitialized) {
        self.jscontext[@"data"] = data;
        self.dataInitialized = true;
    }
    
    if(meta != nil) {
        //TODO scope 고려가 안되어있음
        self.jscontext[@"thisData"] = meta.correspondData;
    }
    
    JSValue* r = [self.jscontext evaluateScript:code];
    return [r toString];
    
//    JSValue* dataJs = [self.jscontext evaluateScript:@"data"];
//    id newData = [dataJs toDictionary];
//    [JevilUtil sync:newData :data];
    
}

-(JSValue*)createJsValue:(NSDictionary*)dic {
    return [JSValue valueWithObject:dic inContext:self.jscontext];
}

@end
