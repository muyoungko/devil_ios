//
//  Jevil.m
//  devilcore
//
//  Created by Mu Young Ko on 2020/12/15.
//


#import "Jevil.h"
#import "WildCardConstructor.h"
#import "DevilController.h"
#import "JevilCtx.h"
#import "JevilAction.h"
#import "DevilSelectDialog.h"
#import "DevilBlockDialog.h"
#import "JevilInstance.h"
#import "WildCardCollectionViewAdapter.h"
#import "DevilDebugView.h"
#import "WifiManager.h"
#import "DevilCamera.h"
#import "DevilBeacon.h"
#import "DevilToast.h"
#import "DevilUtil.h"
#import "WildCardUITextField.h"
#import "DevilSound.h"
#import "DevilBle.h"
#import "DevilSpeech.h"
#import "DevilLocation.h"
#import "DevilLink.h"
#import "DevilWebView.h"
#import "WildCardUITextView.h"
#import "WildCardVideoView.h"
#import "DevilDrawer.h"
#import "DevilDateTimePopup.h"
#import "JevilFunctionUtil.h"
#import "WildCardUICollectionView.h"
#import "DevilSdk.h"
#import "DevilAlertDialog.h"
#import "DevilPlayerController.h"
#import "DevilPhotoController.h"
#import "WildCardTimer.h"
#import "DevilExceptionHandler.h"
#import "WildCardTrigger.h"
#import "DevilRecord.h"
#import <SafariServices/SafariServices.h>
#import "DevilImageMap.h"
#import "DevilFileChooser.h"

@interface Jevil()


@end

@implementation Jevil

+ (BOOL)isLogin{
    return true;
}

+ (void)go:(NSString*)screenName :(id)param{
    NSString* screenId = [[WildCardConstructor sharedInstance] getScreenIdByName:screenName];
    
    DevilController* d = (DevilController*)[[DevilSdk sharedInstance] getRegisteredScreenViewController:screenName];
    if(param != nil) {
        d.startData = param;
    }
    [DevilSdk sharedInstance].currentOrientation = [[WildCardConstructor sharedInstance] supportedOrientation:screenId :[Jevil get:@"ORIENTATION"]];
    d.landscape = [DevilSdk sharedInstance].currentOrientation == UIInterfaceOrientationMaskLandscape;
    
    d.screenId = screenId;
    [[JevilInstance currentInstance].vc.navigationController pushViewController:d animated:YES];
    [[DevilDebugView sharedInstance] log:DEVIL_LOG_SCREEN title:screenName log:param];
}

+ (void)tab:(NSString*)screenName{
    @try {
        UIViewController*vc = [JevilInstance currentInstance].vc;
        id meta = [JevilInstance currentInstance].meta;
        [JevilAction act:@"Jevil.tab" args:@[screenName] viewController:vc meta:meta];
    } @catch (NSException *exception) {
        [Jevil alert:[NSString stringWithFormat:@"%@", exception]];
    }
}

+ (void)replaceScreen:(NSString*)screenName :(id)param{
    NSString* screenId = [[WildCardConstructor sharedInstance] getScreenIdByName:screenName];
    DevilController* d = [[DevilController alloc] init];
    if(param != nil) {
        d.startData = param;
    }
    [DevilSdk sharedInstance].currentOrientation = [[WildCardConstructor sharedInstance] supportedOrientation:screenId :[Jevil get:@"ORIENTATION"]];
    d.landscape = [DevilSdk sharedInstance].currentOrientation == UIInterfaceOrientationMaskLandscape;
    
    d.screenId = screenId;
    UINavigationController* n = [JevilInstance currentInstance].vc.navigationController;
    [n popViewControllerAnimated:NO];
    [n pushViewController:d animated:NO];
    [[DevilDebugView sharedInstance] log:DEVIL_LOG_SCREEN title:screenName log:param];
}

+ (void)rootScreen:(NSString*)screenName :(id)param{
    NSString* screenId = [[WildCardConstructor sharedInstance] getScreenIdByName:screenName];
    DevilController* d = [[DevilController alloc] init];
    if(param != nil) {
        d.startData = param;
    }
    
    [DevilSdk sharedInstance].currentOrientation = [[WildCardConstructor sharedInstance] supportedOrientation:screenId :[Jevil get:@"ORIENTATION"]];
    d.landscape = [DevilSdk sharedInstance].currentOrientation == UIInterfaceOrientationMaskLandscape;
    
    d.screenId = screenId;
    [[JevilInstance currentInstance].vc.navigationController setViewControllers:@[d]];
    [[DevilDebugView sharedInstance] log:DEVIL_LOG_SCREEN title:screenName log:param];
}

+ (void)finish:(id)callbackData {
    id vlist = [[JevilInstance currentInstance].vc.navigationController viewControllers];
    if([vlist count] > 1) {
        UIViewController* toback = vlist[[vlist count]-2];
        if([toback isKindOfClass:[DevilController class]]) {
            DevilController* tobackDevil = (DevilController*)toback;
            [DevilSdk sharedInstance].currentOrientation = [[WildCardConstructor sharedInstance] supportedOrientation:tobackDevil.screenId :[Jevil get:@"ORIENTATION"]];
        }
    }
    if(callbackData){
        [JevilInstance globalInstance].callbackData = callbackData;
    }
    [[JevilInstance currentInstance].vc.navigationController popViewControllerAnimated:YES];
}

+ (void)finishThen:(JSValue *)callback {
    
    id vlist = [[JevilInstance currentInstance].vc.navigationController viewControllers];
    if([vlist count] > 1) {
        UIViewController* toback = vlist[[vlist count]-2];
        if([toback isKindOfClass:[DevilController class]]) {
            DevilController* tobackDevil = (DevilController*)toback;
            [DevilSdk sharedInstance].currentOrientation = [[WildCardConstructor sharedInstance] supportedOrientation:tobackDevil.screenId :[Jevil get:@"ORIENTATION"]];
        }
    }
    
    [JevilInstance globalInstance].callbackFunction = callback;
    [[JevilInstance currentInstance].vc.navigationController popViewControllerAnimated:YES];
}

+ (void)back{
    id vlist = [[JevilInstance currentInstance].vc.navigationController viewControllers];
    if([vlist count] > 1) {
        UIViewController* toback = vlist[[vlist count]-2];
        if([toback isKindOfClass:[DevilController class]]) {
            DevilController* tobackDevil = (DevilController*)toback;
            [DevilSdk sharedInstance].currentOrientation = [[WildCardConstructor sharedInstance] supportedOrientation:tobackDevil.screenId :[Jevil get:@"ORIENTATION"]];
        }
    }
    
    DevilController* dc = (DevilController*)[JevilInstance currentInstance].vc;
    if(dc.onBackPressCallback != nil && dc.onBackPressCallback()) {
        
    } else {
        [Jevil finish:nil];
    }
}

+ (BOOL)isValidNumber:(NSString *)phone
{
    // getting a JSContext
    JSContext *context = [JSContext new];
    
    // enable exception handling
    [context setExceptionHandler:^(JSContext *context, JSValue *value) {
        NSLog(@"%@", value);
    }];
    
    // defining a JavaScript function
    NSString *jsFunctionText =
    @"var isValidNumber = function(phone) {"
    "    var phonePattern = /^[0-9]{3}[ ][0-9]{3}[-][0-9]{4}$/;"
    "    return phone.match(phonePattern) ? true : false;"
    "}";
    [context evaluateScript:jsFunctionText];
    
    // calling a JavaScript function
    JSValue *jsFunction = context[@"isValidNumber"];
    JSValue *value = [jsFunction callWithArguments:@[ phone ]];
    
    return [value toBool];
}

+ (void)toast:(NSString*)msg{
    [[DevilToast makeText:msg] show];
}

+ (void)alert:(NSString*)msg{
    if(![DevilAlertDialog showAlertTemplate:msg :^(BOOL yes) {
        
        }]) {
        UIAlertController *alertController = [UIAlertController alertControllerWithTitle:msg
                                                                                 message:nil
                                                                          preferredStyle:UIAlertControllerStyleAlert];

        [alertController addAction:[UIAlertAction actionWithTitle:trans(@"확인")
                                                          style:UIAlertActionStyleCancel
                                                        handler:^(UIAlertAction *action) {
                                                            
        }]];
            
        [[JevilInstance currentInstance].vc presentViewController:alertController animated:YES completion:^{}];
        ((DevilController*)[JevilInstance currentInstance].vc).activeAlert = alertController;
    }
}

+ (void)alertFinish:(NSString*)msg{
    if(![DevilAlertDialog showAlertTemplate:msg :^(BOOL yes) {
            [[JevilInstance currentInstance].vc.navigationController popViewControllerAnimated:YES];
        }]) {
        UIAlertController *alertController = [UIAlertController alertControllerWithTitle:msg
                                                                                 message:nil
                                                                          preferredStyle:UIAlertControllerStyleAlert];

        [alertController addAction:[UIAlertAction actionWithTitle:trans(@"확인")
                                                          style:UIAlertActionStyleCancel
                                                        handler:^(UIAlertAction *action) {
           [[JevilInstance currentInstance].vc.navigationController popViewControllerAnimated:YES];
        }]];
        [[JevilInstance currentInstance].vc presentViewController:alertController animated:YES completion:^{}];
    }
    
}

+ (void)confirm:(NSString*)msg :(NSString*)yes :(NSString*)no :(JSValue *)callback {
    
    if(![DevilAlertDialog showConfirmTemplate:msg :yes :no :^(BOOL yes) {
        [callback callWithArguments:@[(yes?@YES:@NO)]];
        [[JevilInstance currentInstance] syncData];
    }]) {
        UIAlertController *alertController = [UIAlertController alertControllerWithTitle:nil
                                                                                 message:msg
                                                                          preferredStyle:UIAlertControllerStyleAlert];

        [alertController addAction:[UIAlertAction actionWithTitle:yes
                                                          style:UIAlertActionStyleDefault
                                                        handler:^(UIAlertAction *action) {
            [callback callWithArguments:@[@YES]];
            [[JevilInstance currentInstance] syncData];
                                                            
        }]];
        
        [alertController addAction:[UIAlertAction actionWithTitle:no
                                                          style:UIAlertActionStyleCancel
                                                        handler:^(UIAlertAction *action) {
            [callback callWithArguments:@[@NO]];
            [[JevilInstance currentInstance] syncData];
        }]];
        [[JevilInstance currentInstance].vc presentViewController:alertController animated:YES completion:^{}];
    }
}

+ (void)alertThen:(NSString*)msg :(JSValue *)callback {
    
    if(![DevilAlertDialog showAlertTemplate:msg :^(BOOL yes) {
            [callback callWithArguments:@[]];
            [[JevilInstance currentInstance] syncData];
        }]) {
            UIAlertController *alertController = [UIAlertController alertControllerWithTitle:msg
                                                                                     message:nil
                                                                              preferredStyle:UIAlertControllerStyleAlert];

            [alertController addAction:[UIAlertAction actionWithTitle:trans(@"확인")
                                                              style:UIAlertActionStyleCancel
                                                            handler:^(UIAlertAction *action) {
                [callback callWithArguments:@[]];
                [[JevilInstance currentInstance] syncData];
                                                                
            }]];
            [[JevilInstance currentInstance].vc presentViewController:alertController animated:YES completion:^{}];
    }
}

+ (void)save:(NSString *)key :(NSString *)value{
    if(value == nil) {
        [Jevil remove:key];
    } else {
        key = [NSString stringWithFormat:@"%@_%@", key, [WildCardConstructor sharedInstance].project_id];
        [[NSUserDefaults standardUserDefaults] setObject:value forKey:key];
        [[NSUserDefaults standardUserDefaults] synchronize];
    }
}
+ (void)remove:(NSString *)key{
    key = [NSString stringWithFormat:@"%@_%@", key, [WildCardConstructor sharedInstance].project_id];
    [[NSUserDefaults standardUserDefaults] removeObjectForKey:key];
    [[NSUserDefaults standardUserDefaults] synchronize];
}
+ (NSString*)get:(NSString *)key{
    key = [NSString stringWithFormat:@"%@_%@", key, [WildCardConstructor sharedInstance].project_id];
    NSString* r = [[NSUserDefaults standardUserDefaults] objectForKey:key];
    return r;
}

+ (void)getMany:(NSArray *)paths then:(JSValue *)callback {
    [[JevilFunctionUtil sharedInstance] registFunction:callback];
    __block int len = (int)[paths count];
    
    id result = [@[] mutableCopy];
    id complete = [@[] mutableCopy];
    id httpOk = [@[] mutableCopy];
    for(int i=0;i<len;i++) {
        [result addObject:[@{} mutableCopy]];
        [complete addObject:@FALSE];
        [httpOk addObject:@FALSE];
    }
    
    for(int j=0;j<[paths count];j++) {
        NSString* url = paths[j];
        NSString* originalUrl = url;
        if([url hasPrefix:@"/"])
            url = [NSString stringWithFormat:@"%@%@", [WildCardConstructor sharedInstance].project[@"host"], url];

        id header = [@{} mutableCopy];
        id header_list = [WildCardConstructor sharedInstance].project[@"header_list"];
        for(id h in header_list){
            NSString* content = h[@"content"];
            if([content hasPrefix:@"{"]){
                content = [content stringByReplacingOccurrencesOfString:@"{" withString:@""];
                content = [content stringByReplacingOccurrencesOfString:@"}" withString:@""];
                NSString* value = [Jevil get:content];
                if(value)
                    header[h[@"header"]] = value;
            } else
                header[h[@"header"]] = content;
        }
        
        NSString* x_access_token_key = [NSString stringWithFormat:@"x-access-token"];
        if([Jevil get:x_access_token_key])
            header[@"x-access-token"] = [Jevil get:x_access_token_key];
        
        
        __block int findex = j;
        [[DevilDebugView sharedInstance] log:DEVIL_LOG_REQUEST title:originalUrl log:nil];
        [[WildCardConstructor sharedInstance].delegate onNetworkRequestGet:url header:header success:^(NSMutableDictionary *responseJsonObject) {
            
            if(responseJsonObject != nil)
                result[findex] = responseJsonObject;
            complete[findex] = @TRUE;
            httpOk[findex] = (responseJsonObject != nil && !([responseJsonObject isMemberOfClass:[NSError class]]))?@TRUE:@FALSE ;
            BOOL allComplete = true;
            BOOL allOk = true;
            for(int i=0;i<len;i++) {
                if(complete[i] == @FALSE) {
                    allComplete = false;
                    break;
                }
            }
            
            for(int i=0;i<len;i++) {
                if(httpOk[i] == @FALSE) {
                    allOk = false;
                    break;
                }
            }
            
            if(responseJsonObject == nil)
                responseJsonObject = [@{} mutableCopy];
            else if([responseJsonObject isMemberOfClass:[NSError class]]){
                NSString* error = [NSString stringWithFormat:@"%@", responseJsonObject];
                [[DevilDebugView sharedInstance] log:DEVIL_LOG_RESPONSE title:originalUrl log:@{error:error}];
            } else
                [[DevilDebugView sharedInstance] log:DEVIL_LOG_RESPONSE title:originalUrl log:responseJsonObject];
            
            if(allComplete) {
                id r = [@{} mutableCopy];
                r[@"r"] = allOk?@TRUE:@FALSE;
                r[@"res"] = [@[] mutableCopy];
                
                for(int i=0;i<len;i++)
                    [r[@"res"] addObject:result[i]];
                [[JevilFunctionUtil sharedInstance] callFunction:callback params:@[r]];
                [[JevilInstance currentInstance] syncData];
            }
        }];
    }
}

+ (void)http:(NSString *)method :(NSString *)url :(NSDictionary*)headerObject :(NSDictionary*)body :(JSValue *)callback {
    [[JevilFunctionUtil sharedInstance] registFunction:callback];
    NSString* originalUrl = url;
    if([url hasPrefix:@"/"])
        url = [NSString stringWithFormat:@"%@%@", [WildCardConstructor sharedInstance].project[@"host"], url];

    id header = [@{} mutableCopy];
    if(headerObject)
        header = [headerObject mutableCopy];
    
    id header_list = [WildCardConstructor sharedInstance].project[@"header_list"];
    for(id h in header_list){
        NSString* content = h[@"content"];
        if([content hasPrefix:@"{"]){
            content = [content stringByReplacingOccurrencesOfString:@"{" withString:@""];
            content = [content stringByReplacingOccurrencesOfString:@"}" withString:@""];
            NSString* value = [Jevil get:content];
            if(value)
                header[h[@"header"]] = value;
        } else
            header[h[@"header"]] = content;
    }
    
    NSString* x_access_token_key = [NSString stringWithFormat:@"x-access-token"];
    if([Jevil get:x_access_token_key])
        header[@"x-access-token"] = [Jevil get:x_access_token_key];
    
    if(!body)
        body = @{};
    [[DevilDebugView sharedInstance] log:DEVIL_LOG_REQUEST title:originalUrl log:nil];
    [[WildCardConstructor sharedInstance].delegate onNetworkRequestHttp:method :url :header :[body mutableCopy] :^(NSMutableDictionary *responseJsonObject) {
        if(responseJsonObject == nil)
            responseJsonObject = [@{} mutableCopy];
        else if([responseJsonObject isMemberOfClass:[NSError class]]){
            NSString* error = [NSString stringWithFormat:@"%@", responseJsonObject];
            [[DevilDebugView sharedInstance] log:DEVIL_LOG_RESPONSE title:originalUrl log:@{error:error}];
        } else
            [[DevilDebugView sharedInstance] log:DEVIL_LOG_RESPONSE title:originalUrl log:responseJsonObject];
        
        [[JevilFunctionUtil sharedInstance] callFunction:callback params:@[responseJsonObject]];
        [[JevilInstance currentInstance] syncData];
    }];
}

+ (void)get:(NSString *)url then:(JSValue *)callback {
    [[JevilFunctionUtil sharedInstance] registFunction:callback];
    NSString* originalUrl = url;
    if([url hasPrefix:@"/"])
        url = [NSString stringWithFormat:@"%@%@", [WildCardConstructor sharedInstance].project[@"host"], url];

    id header = [@{} mutableCopy];
    id header_list = [WildCardConstructor sharedInstance].project[@"header_list"];
    for(id h in header_list){
        NSString* content = h[@"content"];
        if([content hasPrefix:@"{"]){
            content = [content stringByReplacingOccurrencesOfString:@"{" withString:@""];
            content = [content stringByReplacingOccurrencesOfString:@"}" withString:@""];
            NSString* value = [Jevil get:content];
            if(value)
                header[h[@"header"]] = value;
        } else
            header[h[@"header"]] = content;
    }
    
    NSString* x_access_token_key = [NSString stringWithFormat:@"x-access-token"];
    if([Jevil get:x_access_token_key])
        header[@"x-access-token"] = [Jevil get:x_access_token_key];
    
    for(int i=0;i<[url length];i++) {
        unichar c = [url characterAtIndex:i];
        if( (unsigned int)c >= 0xAC00 && (unsigned int)c <= 0xD7A3)
        {
            NSString *s = [NSString stringWithFormat:@"%C", c];
            NSString *e = urlencode(s);
            url = [url stringByReplacingOccurrencesOfString:s withString:e];
        }
    }
    
    [[DevilDebugView sharedInstance] log:DEVIL_LOG_REQUEST title:originalUrl log:nil];
    [[WildCardConstructor sharedInstance].delegate onNetworkRequestGet:url header:header success:^(NSMutableDictionary *responseJsonObject) {
        
        if(responseJsonObject == nil)
            responseJsonObject = [@{} mutableCopy];
        else if([responseJsonObject isMemberOfClass:[NSError class]]){
            NSString* error = [NSString stringWithFormat:@"%@", responseJsonObject];
            [[DevilDebugView sharedInstance] log:DEVIL_LOG_RESPONSE title:originalUrl log:@{error:error}];
        } else
            [[DevilDebugView sharedInstance] log:DEVIL_LOG_RESPONSE title:originalUrl log:responseJsonObject];
        
        [[JevilFunctionUtil sharedInstance] callFunction:callback params:@[responseJsonObject]];
        [[JevilInstance currentInstance] syncData];
    }];
}

+ (void)post:(NSString *)url :(id)param then:(JSValue *)callback {

    [[JevilFunctionUtil sharedInstance] registFunction:callback];
    NSString* originalUrl = url;
    if([url hasPrefix:@"/"])
        url = [NSString stringWithFormat:@"%@%@", [WildCardConstructor sharedInstance].project[@"host"], url];

    id header = [@{} mutableCopy];
    id header_list = [WildCardConstructor sharedInstance].project[@"header_list"];
    for(id h in header_list){
        NSString* content = h[@"content"];
        if([content hasPrefix:@"{"]){
            content = [content stringByReplacingOccurrencesOfString:@"{" withString:@""];
            content = [content stringByReplacingOccurrencesOfString:@"}" withString:@""];
            NSString* value = [Jevil get:content];
            if(value)
                header[h[@"header"]] = value;
        } else
            header[h[@"header"]] = content;
    }
    
    NSString* x_access_token_key = [NSString stringWithFormat:@"x-access-token"];
    if([Jevil get:x_access_token_key])
        header[@"x-access-token"] = [Jevil get:x_access_token_key];
    
    [[DevilDebugView sharedInstance] log:DEVIL_LOG_REQUEST title:originalUrl log:param];
    [[WildCardConstructor sharedInstance].delegate onNetworkRequestPost:url header:header json:param success:^(NSMutableDictionary *responseJsonObject) {
        
        if([responseJsonObject isKindOfClass:[NSError class]] || [responseJsonObject isMemberOfClass:[NSError class]]){
            NSString* error = [NSString stringWithFormat:@"%@", responseJsonObject];
            [[DevilDebugView sharedInstance] log:DEVIL_LOG_RESPONSE title:originalUrl log:@{error:error}];
            responseJsonObject = nil;
        } else
            [[DevilDebugView sharedInstance] log:DEVIL_LOG_RESPONSE title:originalUrl log:responseJsonObject];
        
        
        if(responseJsonObject)
            [[JevilFunctionUtil sharedInstance] callFunction:callback params:@[responseJsonObject]];
        else
            [[JevilFunctionUtil sharedInstance] callFunction:callback params:@[]];
        
        [[JevilInstance currentInstance] syncData];
    }];
}

+ (void)put:(NSString *)url :(id)param then:(JSValue *)callback {
    NSString* originalUrl = url;
    if([url hasPrefix:@"/"])
        url = [NSString stringWithFormat:@"%@%@", [WildCardConstructor sharedInstance].project[@"host"], url];

    id header = [@{} mutableCopy];
    id header_list = [WildCardConstructor sharedInstance].project[@"header_list"];
    for(id h in header_list){
        NSString* content = h[@"content"];
        if([content hasPrefix:@"{"]){
            content = [content stringByReplacingOccurrencesOfString:@"{" withString:@""];
            content = [content stringByReplacingOccurrencesOfString:@"}" withString:@""];
            NSString* value = [Jevil get:content];
            if(value)
                header[h[@"header"]] = value;
        } else
            header[h[@"header"]] = content;
    }
    
    NSString* x_access_token_key = [NSString stringWithFormat:@"x-access-token"];
    if([Jevil get:x_access_token_key])
        header[@"x-access-token"] = [Jevil get:x_access_token_key];
    
    [[DevilDebugView sharedInstance] log:DEVIL_LOG_REQUEST title:originalUrl log:param];
    [[WildCardConstructor sharedInstance].delegate onNetworkRequestPut:url header:header json:param success:^(NSMutableDictionary *responseJsonObject) {
        
        if(responseJsonObject == nil)
            responseJsonObject = [@{} mutableCopy];
        else if([responseJsonObject isMemberOfClass:[NSError class]]){
            NSString* error = [NSString stringWithFormat:@"%@", responseJsonObject];
            [[DevilDebugView sharedInstance] log:DEVIL_LOG_RESPONSE title:originalUrl log:@{error:error}];
        } else
            [[DevilDebugView sharedInstance] log:DEVIL_LOG_RESPONSE title:originalUrl log:responseJsonObject];
        
        if(!responseJsonObject)
            responseJsonObject = [@{} mutableCopy];
        [callback callWithArguments:@[responseJsonObject]];
        [[JevilInstance currentInstance] syncData];
    }];
}

+ (void)uploadS3:(NSArray*)paths :(JSValue *)callback{
    [Jevil uploadS3Core:paths :@"/api/media/url/put" :callback];
}

+ (void)uploadS3Secure:(NSArray*)paths :(JSValue *)callback {
    [Jevil uploadS3Core:paths :@"/api/media/url/secure/put" :callback];
}

+ (void)uploadS3Core:(NSArray*)paths :(NSString*)put_url :(JSValue *)callback{
    if([paths count] == 0) {
        [callback callWithArguments:@[@{@"r":@TRUE, @"uploadedFile":@[]}]];
        return;
    }
    
    /**
     혹시 phasset path가 있을수 있으니 일단 컨버팅한다
     */
    [DevilCamera changePhAssetToUrlPath:paths callback:^(id  _Nonnull paths) {
        id header = [@{} mutableCopy];
        id header_list = [WildCardConstructor sharedInstance].project[@"header_list"];
        for(id h in header_list){
            header[h[@"header"]] = h[@"content"];
        }
        NSString* x_access_token_key = [NSString stringWithFormat:@"x-access-token"];
        if([Jevil get:x_access_token_key])
            header[@"x-access-token"] = [Jevil get:x_access_token_key];

        __block int s3index = 0;
        __block int s3length = (int)[paths count];
        __block id uploadedFile = [@[] mutableCopy];
        __block id uploadedFileSuccess = [@[] mutableCopy];
        
        id result = [@{} mutableCopy];
        result[@"r"] = @TRUE;
        result[@"uploadedFile"] = [@[] mutableCopy];
        if([paths count] == 0) {
            [callback callWithArguments:@[result]];
            return;
        }
        
        __block BOOL cancelled = NO;
        
        __block DevilController* vc = (DevilController*)[JevilInstance currentInstance].vc;
        BOOL showUploadingPopup = [paths count] > 5;
        if(showUploadingPopup) {
            [DevilUtil showAlert:vc msg:@"파일을 준비 중 입니다" showYes:YES yesText:@"취소" cancelable:true callback:^(BOOL res) {
                cancelled = YES;
                id r = [@{@"r":@FALSE, @"msg":@"취소되었습니다"} mutableCopy];
                [callback callWithArguments:@[r]];
            }];
        }
        
        [DevilUtil httpPutQueueClear];
        for(int i=0;i<[paths count];i++){
            __block NSString* path = [DevilUtil replaceUdidPrefixDir:paths[i]];
            id ss = [path componentsSeparatedByString:@"."];
            NSString* ext = ss[[ss count]-1];
            NSString* url = [NSString stringWithFormat:@"%@%@/%@", [WildCardConstructor sharedInstance].project[@"host"], put_url, ext];
            [uploadedFile addObject:path];
            [uploadedFileSuccess addObject:@FALSE];
            __block int thisIndex = i;
            
            [[WildCardConstructor sharedInstance].delegate onNetworkRequestGet:url header:header success:^(NSMutableDictionary *upload) {
                if(cancelled)
                    return;
                
                if(upload == nil || !upload[@"upload_url"]){
                    s3index++;
                    result[@"r"] = @FALSE;
                    if(s3index == s3length){
                        for(int j=0;j<[uploadedFile count];j++){
                            [result[@"uploadedFile"] addObject:
                             [@{@"key" : uploadedFile[j],
                                @"success" : uploadedFileSuccess[j]
                             } mutableCopy]];
                        }
                        [callback callWithArguments:@[result]];
                        [[JevilInstance currentInstance] syncData];
                    }
                } else {
                    NSString* upload_url = upload[@"upload_url"];
                    uploadedFile[thisIndex] = upload[@"key"];
                    NSData* data = [NSData dataWithContentsOfFile:path];
                    
                    NSString* contentType = nil;
                    if([path hasSuffix:@"jpg"] || [path hasSuffix:@"jpeg"])
                        contentType = @"image/jpeg";
                    else if([path hasSuffix:@"png"])
                        contentType = @"image/png";
                    else if([path hasSuffix:@"mp4"])
                        contentType = @"video/mp4";
                    
                    if([data length] == 0)
                        @throw [NSException exceptionWithName:@"Devil" reason:[NSString stringWithFormat:@"Failed. Upload Data is 0 byte. %@", path] userInfo:nil];
                    
                    [DevilUtil httpPut:upload_url contentType:contentType data:data complete:^(id  _Nonnull res) {
                        if(cancelled)
                            return;
                        
                        s3index++;
                        
                        if(showUploadingPopup)
                            [vc setActiveAlertMessage:[NSString stringWithFormat:@"업로드 중입니다 %d / %d", s3index, [paths count]]];
                        
                        if(res != nil)
                            uploadedFileSuccess[thisIndex] = @TRUE;
                        else
                            result[@"r"] = @FALSE;
                        
                        if(s3index == s3length){
                            for(int j=0;j<[uploadedFile count];j++){
                                [result[@"uploadedFile"] addObject:
                                 [@{
                                     @"original" : paths[j],
                                     @"key" : uploadedFile[j],
                                     @"success" : uploadedFileSuccess[j]
                                 } mutableCopy]];
                            }
                            
                            if(showUploadingPopup)
                                [vc closeActiveAlertMessage];
                            
                            [callback callWithArguments:@[result]];
                            [[JevilInstance currentInstance] syncData];
                        }
                    }];
                }
            }];
        }
    }];
    
}

+ (void)sendPushKeyWithDevilServer {
    NSString* fcm = [[NSUserDefaults standardUserDefaults] objectForKey:@"FCM"];
    if(fcm == nil)
        return;
    
    UIDevice *device = [UIDevice currentDevice];
    NSString* udid = [[device identifierForVendor] UUIDString];
    NSString* url = [NSString stringWithFormat:@"/push/key?fcm=%@&udid=%@&os=iOS&package=%@", urlencode(fcm), urlencode(udid),
                     urlencode([[[NSBundle mainBundle] bundleIdentifier] lowercaseString])
                     ];
    url = [NSString stringWithFormat:@"%@%@", [WildCardConstructor sharedInstance].project[@"host"], url];
    
    id header = [@{} mutableCopy];
    NSString* x_access_token_key = [NSString stringWithFormat:@"x-access-token"];
    if([Jevil get:x_access_token_key])
        header[@"x-access-token"] = [Jevil get:x_access_token_key];
    
    [[DevilDebugView sharedInstance] log:DEVIL_LOG_REQUEST title:@"/push/key" log:nil];
    [[WildCardConstructor sharedInstance].delegate onNetworkRequestGet:url header:header success:^(NSMutableDictionary *responseJsonObject) {
        [[DevilDebugView sharedInstance] log:DEVIL_LOG_RESPONSE title:@"/push/key" log:responseJsonObject];
    }];
    
}

+ (void)getThenWithHeader:(NSString *)url :(id)header :(JSValue *)callback {

    NSString* originalUrl = url;
    if([url hasPrefix:@"/"])
        url = [NSString stringWithFormat:@"%@%@", [WildCardConstructor sharedInstance].project[@"host"], url];

    [[DevilDebugView sharedInstance] log:DEVIL_LOG_REQUEST title:originalUrl log:nil];
    [[WildCardConstructor sharedInstance].delegate onNetworkRequestGet:url header:header success:^(NSMutableDictionary *responseJsonObject) {
        [[DevilDebugView sharedInstance] log:DEVIL_LOG_RESPONSE title:originalUrl log:responseJsonObject];
        
        if(!responseJsonObject)
            responseJsonObject = [@{} mutableCopy];
        [callback callWithArguments:@[responseJsonObject, @YES]];
        [[JevilInstance currentInstance] syncData];
    }];
}

+ (void)postThenWithHeader:(NSString *)url :(id)header :(id)param :(JSValue *)callback {

    NSString* originalUrl = url;
    if([url hasPrefix:@"/"])
        url = [NSString stringWithFormat:@"%@%@", [WildCardConstructor sharedInstance].project[@"host"], url];

    [[DevilDebugView sharedInstance] log:DEVIL_LOG_REQUEST title:originalUrl log:param];
    [[WildCardConstructor sharedInstance].delegate onNetworkRequestPost:url header:header json:param success:^(NSMutableDictionary *responseJsonObject) {
        [[DevilDebugView sharedInstance] log:DEVIL_LOG_RESPONSE title:originalUrl log:responseJsonObject];
        
        if(!responseJsonObject)
            responseJsonObject = [@{} mutableCopy];
        [callback callWithArguments:@[responseJsonObject, @YES]];
        [[JevilInstance currentInstance] syncData];
    }];
}



+ (void)startLoading{
    if([WildCardConstructor sharedInstance].loadingDelegate)
        [[WildCardConstructor sharedInstance].loadingDelegate startLoading];
}
+ (void)stopLoading{
    if([WildCardConstructor sharedInstance].loadingDelegate)
        [[WildCardConstructor sharedInstance].loadingDelegate stopLoading];
}

+ (void)update{
    
    [[JevilInstance currentInstance] syncData];
    
    UIViewController*vc = [JevilInstance currentInstance].vc;
    if(vc != nil && ([vc isKindOfClass:[DevilController class]])) {
        [((DevilController*)vc) updateMeta];
        if(((DevilController*)[JevilInstance currentInstance].vc).devilBlockDialog)
            [((DevilController*)[JevilInstance currentInstance].vc).devilBlockDialog update];
    }
}

+ (void)focus:(NSString*)nodeName {
    DevilController* vc = (DevilController*)[JevilInstance currentInstance].vc;
    
    WildCardUITextField* tf = (WildCardUITextField*)[[vc findView:nodeName] subviews][0];
    
    [tf becomeFirstResponder];
}

+ (void)hideKeyboard {
    [[JevilInstance currentInstance].vc.view endEditing:YES];
    
    if(((DevilController*)[JevilInstance currentInstance].vc).devilBlockDialog) {
        [((DevilController*)[JevilInstance currentInstance].vc).devilBlockDialog endEditing:YES];
    }
    
}

+ (void)scrollTo:(NSString*)nodeName :(int)index :(BOOL)noani {
    
    @try{
        [[JevilInstance currentInstance] performSelector:@selector(videoViewAutoPlay) withObject:nil afterDelay:0.001f];
        
        if(nodeName && ![@"null" isEqualToString:nodeName] ) {
            DevilController* vc = (DevilController*)[JevilInstance currentInstance].vc;
            WildCardUICollectionView* list = (WildCardUICollectionView*)[[vc findView:nodeName] subviews][0];
            if(list != nil)
                [list asyncScrollTo:index:!noani];
        } else {
            DevilController* vc = (DevilController*)[JevilInstance currentInstance].vc;
            if(vc.tv != nil)
                [vc.tv asyncScrollTo:index];
        }
    }@catch(NSException* e){
        [DevilExceptionHandler handle:e];
    }
    
}

+ (void)scrollUp:(NSString*)nodeName {
    if(nodeName && ![@"null" isEqualToString:nodeName]) {
        id meta = [JevilInstance currentInstance].meta;
        WildCardUICollectionView* list = [[meta getView:nodeName] subviews][0];
        [list scrollToItemAtIndexPath:[NSIndexPath indexPathForRow:0 inSection:0] atScrollPosition:UITableViewScrollPositionMiddle animated:YES];
    } else {
        DevilController* vc = (DevilController*)[JevilInstance currentInstance].vc;
        if(vc.tv != nil)
            [vc.tv scrollsToTop];
    }
}

+ (void)updateThis{
    [[JevilInstance currentInstance] syncData];
    [[JevilInstance currentInstance].meta update];
}

+ (void)popup:(NSString*)blockName :(NSDictionary*)param :(JSValue *)callback{
    NSString* title = param[@"title"];
    NSString* yes = param[@"yes"];
    NSString* no = param[@"no"];
    NSString* show = param[@"show"];
    [[JevilInstance currentInstance] syncData];
    DevilBlockDialog* d = [DevilBlockDialog popup:blockName data:[JevilInstance currentInstance].data title:title yes:yes no:no
                                             show:show
                                         onselect:^(BOOL yes, id res) {
        [callback callWithArguments:@[(yes?@TRUE:@FALSE)]];
        [[JevilInstance currentInstance] syncData];
    }];
    
    if([[JevilInstance currentInstance].vc isKindOfClass:[DevilController class]])
        ((DevilController*)[JevilInstance currentInstance].vc).devilBlockDialog = d;
    
    d.didFinishDismissingBlock = ^{
        if([[JevilInstance currentInstance].vc isKindOfClass:[DevilController class]])
            if(d == ((DevilController*)[JevilInstance currentInstance].vc).devilBlockDialog)
                ((DevilController*)[JevilInstance currentInstance].vc).devilBlockDialog = nil;
    };
}

/**
 TODO : 템플릿으로 구현해야함
 */
+ (void)popupAddress:(NSDictionary*)param :(JSValue *)callback {
    NSString* title = param[@"title"];
    NSString* yes = param[@"yes"];
    NSString* no = param[@"no"];
    NSString* show = param[@"show"];
    [[JevilInstance currentInstance] syncData];
    DevilBlockDialog* d = [DevilBlockDialog popup:@"address" data:[JevilInstance currentInstance].data title:title yes:yes no:no
                                             show:show
                                         onselect:^(BOOL yes, id res) {
        [[JevilInstance currentInstance] pushData];
        [callback callWithArguments:@[(yes?@TRUE:@FALSE)]];
        [[JevilInstance currentInstance] syncData];
    }];
    
    if([[JevilInstance currentInstance].vc isKindOfClass:[DevilController class]])
        ((DevilController*)[JevilInstance currentInstance].vc).devilBlockDialog = d;
    
    d.didFinishDismissingBlock = ^{
        if([[JevilInstance currentInstance].vc isKindOfClass:[DevilController class]])
            ((DevilController*)[JevilInstance currentInstance].vc).devilBlockDialog = nil;
    };
}

+ (void)popupClose {
    [Jevil popupClose:NO];
}

+ (void)popupClose:(BOOL)yes {
    if(((DevilController*)[JevilInstance currentInstance].vc).devilBlockDialog)
        [((DevilController*)[JevilInstance currentInstance].vc).devilBlockDialog dismissWithCallback:yes];
}

+ (void)popupSelect:(NSArray *)arrayString :(NSDictionary*)param :(JSValue *)callback {
    
    UIViewController*vc = [JevilInstance currentInstance].vc;
    DevilSelectDialog* d = [[DevilSelectDialog alloc] initWithViewController:vc];
    id list = [arrayString mutableCopy];
    id paramM = [param mutableCopy];
    if([JevilInstance currentInstance].meta.lastClick)
        paramM[@"view"] = [JevilInstance currentInstance].meta.lastClick;
    [d popupSelect:list param:paramM onselect:^(id  _Nonnull res) {
        [callback callWithArguments:@[res]];
        [[JevilInstance currentInstance] syncData];
    }];
    
    if([[JevilInstance currentInstance].vc isKindOfClass:[DevilController class]])
        ((DevilController*)[JevilInstance currentInstance].vc).devilSelectDialog = d;
}

+ (void)popupDate:(NSDictionary*)param :(JSValue *)callback {
    UIViewController*vc = [JevilInstance currentInstance].vc;
    DevilDateTimePopup* d = [[DevilDateTimePopup alloc] initWithViewController:vc];
    id paramM = [param mutableCopy];
    [d popup:paramM isDate:true onselect:^(id  _Nonnull res) {
        if(res) {
            [callback callWithArguments:@[res]];
            [[JevilInstance currentInstance] syncData];
        }
    }];
    
    if([[JevilInstance currentInstance].vc isKindOfClass:[DevilController class]])
        [((DevilController*)[JevilInstance currentInstance].vc).retainObject addObject:d];
}

+ (void)popupTime:(NSDictionary*)param :(JSValue *)callback {
    UIViewController*vc = [JevilInstance currentInstance].vc;
    DevilDateTimePopup* d = [[DevilDateTimePopup alloc] initWithViewController:vc];
    id paramM = [param mutableCopy];
    [d popup:paramM isDate:false onselect:^(id  _Nonnull res) {
        if(res) {
            [callback callWithArguments:@[res]];
            [[JevilInstance currentInstance] syncData];
        }
    }];
    
    if([[JevilInstance currentInstance].vc isKindOfClass:[DevilController class]])
        [((DevilController*)[JevilInstance currentInstance].vc).retainObject addObject:d];
}

+ (void)resetTimer:(NSString *)nodeName{
    id meta = [JevilInstance currentInstance].meta;
    WildCardUIView* vv = (WildCardUIView*)[meta getView:nodeName];
    [vv.tags[@"timer"] reset];
}

+ (int)getViewPagerSelectedIndex:(NSString *)nodeName{
    id meta = [JevilInstance currentInstance].meta;
    WildCardUIView* vv = (WildCardUIView*)[meta getView:nodeName];
    UICollectionView* cv = (UICollectionView*)[vv subviews][0];
    WildCardCollectionViewAdapter* adapter = (WildCardCollectionViewAdapter*)cv.delegate;
    return adapter.selectedIndex;
}

+ (void)isWifi:(JSValue *)callback {
    BOOL r = [DevilUtil isWifiConnection];
    [[JevilFunctionUtil sharedInstance] registFunction:callback];
    [[JevilFunctionUtil sharedInstance] callFunction:callback params:@[(r?@TRUE:@FALSE)]];
}

+ (void)wifiList:(JSValue *)callback {
    
    WifiManager* wm = [[WifiManager alloc] init];
    [wm getWifList:^(id  _Nonnull res) {
        [callback callWithArguments:@[res]];
        [[JevilInstance currentInstance] syncData];
    }];
    
    if([[JevilInstance currentInstance].vc isKindOfClass:[DevilController class]])
        ((DevilController*)[JevilInstance currentInstance].vc).wifiManager = wm;
}

+ (void)wifiConnect:(NSString*)ssid :(NSString*)password :(JSValue *)callback{
    WifiManager* wm = [[WifiManager alloc] init];
    [wm connect:ssid :^(id  _Nonnull res) {
        if([res[@"r"] boolValue])
            [callback callWithArguments:@[@TRUE]];
        else
            [callback callWithArguments:@[@FALSE]];
        [[JevilInstance currentInstance] syncData];
    }];
    
    if([[JevilInstance currentInstance].vc isKindOfClass:[DevilController class]])
        ((DevilController*)[JevilInstance currentInstance].vc).wifiManager = wm;
}

+ (void)gallery:(NSDictionary*)param :(JSValue *)callback {
    [DevilCamera gallery:[JevilInstance currentInstance].vc param:param callback:^(id  _Nonnull res) {
        if([res[@"r"] boolValue]) {
            [callback callWithArguments:@[res]];
            [[JevilInstance currentInstance] syncData];
        } else if(res[@"msg"]){
            [Jevil alert:res[@"msg"]];
        }
    }];
}

+ (void)galleryList:(NSDictionary*)param :(JSValue *)callback {
    [DevilCamera galleryList:[JevilInstance currentInstance].vc param:param callback:^(id  _Nonnull res) {
        [callback callWithArguments:@[res]];
        [[JevilInstance currentInstance] syncData];
    }];
}

+ (void)gallerySystem:(NSDictionary*)param :(JSValue *)callback {
    [[DevilCamera sharedInstance] gallerySystem:[JevilInstance currentInstance].vc param:param callback:^(id  _Nonnull res) {
        if([res[@"r"] boolValue]) {
            [callback callWithArguments:@[res]];
            [[JevilInstance currentInstance] syncData];
        } else if(res[@"msg"]){
            [Jevil alert:res[@"msg"]];
        }
    }];
}


+ (void)cameraSystem:(NSDictionary*)param :(JSValue *)callback {
    [[DevilCamera sharedInstance] cameraSystem:[JevilInstance currentInstance].vc param:param callback:^(id  _Nonnull res) {
        if([res[@"r"] boolValue]) {
            [callback callWithArguments:@[res]];
            [[JevilInstance currentInstance] syncData];
        } else if(res[@"msg"]){
            [Jevil alert:res[@"msg"]];
        }
    }];
}

+ (void)camera:(NSDictionary*)param :(JSValue *)callback {
    [DevilCamera camera:[JevilInstance currentInstance].vc param:param callback:^(id  _Nonnull res) {
        if([res[@"r"] boolValue]) {
            [callback callWithArguments:@[res]];
            [[JevilInstance currentInstance] syncData];
        } else if(res[@"msg"]){
            [Jevil alert:res[@"msg"]];
        }
    }];
}

+ (void)cameraQr:(NSDictionary*)param :(JSValue *)callback {
    [DevilCamera cameraQr:[JevilInstance currentInstance].vc param:param callback:^(id  _Nonnull res) {
        if([res[@"r"] boolValue]) {
            [callback callWithArguments:@[res]];
            [[JevilInstance currentInstance] syncData];
        } else if(res[@"msg"]){
            [Jevil alert:res[@"msg"]];
        }
    }];
}

+ (void)cameraQrClose {
    [[JevilInstance currentInstance].vc dismissModalViewControllerAnimated:YES];
}

+ (void)share:(NSString*)url{
    NSArray *activityItems = @[[NSURL URLWithString:url]];
    UIActivityViewController *activityViewControntroller = [[UIActivityViewController alloc] initWithActivityItems:activityItems applicationActivities:nil];
    activityViewControntroller.excludedActivityTypes = @[];
    [[JevilInstance currentInstance].vc presentViewController:activityViewControntroller animated:true completion:nil];
}

+ (void)out:(NSString*)url{
    if([url hasPrefix:@"http"]) {
        SFSafariViewController *svc = [[SFSafariViewController alloc] initWithURL:[NSURL URLWithString:url]];
        [[JevilInstance currentInstance].vc presentViewController:svc animated:YES completion:nil];
    } else {
        [[UIApplication sharedApplication] openURL:[NSURL URLWithString: url] options:@{} completionHandler:^(BOOL success) {
            
        }];
    }
}

+ (void)saveFileFromUrl:(NSDictionary*)param :(JSValue *)callback {
    [[JevilFunctionUtil sharedInstance] registFunction:callback];
    [DevilUtil saveFileFromUrl:param[@"url"] to:param[@"destFileName"] callback:^(id  _Nonnull res) {
        [[JevilFunctionUtil sharedInstance] callFunction:callback params:@[res]];
    }];
}

+ (void)downloadAndView:(NSString*)url {
    [self download:url];
}

+ (void)downloadAndShare:(NSString*)url {
    
    NSData *urlData = [NSData dataWithContentsOfURL:[NSURL URLWithString:url]];
    if(urlData) {
        NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
        NSString  *documentsDirectory = [paths objectAtIndex:0];

        NSString* ext = [DevilUtil getFileExt:url];
        NSString* name = [DevilUtil getFileName:url];
        NSString* path = [NSTemporaryDirectory() stringByAppendingPathComponent:[name stringByAppendingPathExtension:ext]];
        [urlData writeToFile:path atomically:YES];
        path = [NSString stringWithFormat:@"file:/%@", path];
        
        UIActivityViewController *activityViewController = [[UIActivityViewController alloc] initWithActivityItems:@[[NSURL URLWithString:path]]
                                        applicationActivities:nil];
        [[JevilInstance currentInstance].vc.navigationController presentViewController:activityViewController
                                          animated:YES
                                        completion:^{

        }];
    }
}

+ (void)download:(NSString*)url {
    
    NSData *urlData = [NSData dataWithContentsOfURL:[NSURL URLWithString:url]];
    if(urlData) {
        NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
        NSString  *documentsDirectory = [paths objectAtIndex:0];

        NSString* ext = [DevilUtil getFileExt:url];
        NSString* name = [DevilUtil getFileName:url];
        NSString* path = [NSTemporaryDirectory() stringByAppendingPathComponent:[name stringByAppendingPathExtension:ext]];
        [urlData writeToFile:path atomically:YES];
        path = [NSString stringWithFormat:@"file:/%@", path];
        UIDocumentInteractionController * d = [UIDocumentInteractionController interactionControllerWithURL: [NSURL URLWithString:path]];
        DevilController* vc = (DevilController*)[JevilInstance currentInstance].vc;
        d.delegate = vc;
        [d presentPreviewAnimated:YES];
        //[d presentOptionsMenuFromRect:vc.view.bounds inView:vc.view animated:YES];
        [JevilInstance currentInstance].forRetain[@"UIDocumentInteractionController"] = d;
    }
}


+ (void)sound:(NSDictionary*)param{
    @try {
        [[DevilSound sharedInstance] sound:param];
    } @catch (NSException *exception) {
        //TODO
    }
}

+ (void)soundControlCallback:(JSValue *)callback {
    [[JevilFunctionUtil sharedInstance] registFunction:callback];
    [[DevilSound sharedInstance] setControlCallback:^(NSString * _Nonnull command) {
        [[JevilFunctionUtil sharedInstance] callFunction:callback params:@[command]];
    }];
}

+ (id)soundCurrentInfo{
    return [[DevilSound sharedInstance] currentInfo];
}

+ (BOOL)soundIsPlaying{
    @try {
        return [[DevilSound sharedInstance] isPlaying];
    } @catch (NSException *exception) {
        //TODO
    }
}

+ (void)soundCallback:(JSValue*)callback{
    [[DevilSound sharedInstance] setSoundCallback:^(id res) {
        [callback callWithArguments:@[ res ]];
    }];
}

+ (void)soundTick:(JSValue*)callback{
    [[DevilSound sharedInstance] setTickCallback:^(int sec, int totalSeconds) {
        [callback callWithArguments:@[ [NSNumber numberWithInt:sec], [NSNumber numberWithInt:totalSeconds]]];
    }];
}
+ (void)soundPause{
    [[DevilSound sharedInstance] pause];
}
+ (void)soundStop{
    [[DevilSound sharedInstance] stop];
}
+ (void)soundResume{
    [[DevilSound sharedInstance] resume];
}
+ (void)soundMove:(int)sec{
    [[DevilSound sharedInstance] move:sec];
}
+ (void)soundSeek:(int)sec{
    [[DevilSound sharedInstance] seek:sec];
}
+ (void)soundSpeed:(NSString*)speed{
    [[DevilSound sharedInstance] speed:[speed floatValue]];
}
+ (void)speechRecognizer:(NSDictionary*)param :(JSValue*)callback{
    [[JevilFunctionUtil sharedInstance] registFunction:callback];
    [[DevilSpeech sharedInstance] listen:param :^(id  _Nonnull res) {
        [[JevilFunctionUtil sharedInstance] callFunction:callback params:@[ res ]];
    }];
}
+ (void)stopSpeechRecognizer {
    [[DevilSpeech sharedInstance] cancel];
}


+ (NSString*)recordStatus{
    return [DevilRecord sharedInstance].status;
}

+ (void)recordStart:(NSDictionary*)param :(JSValue*)callback{
    [[JevilFunctionUtil sharedInstance] registFunction:callback];
    [[DevilRecord sharedInstance] startRecord:param complete:^(id  _Nonnull res) {
        [[JevilFunctionUtil sharedInstance] callFunction:callback params:@[res]];
    }];
}

+ (void)recordTick:(JSValue*)callback{
    [[JevilFunctionUtil sharedInstance] registFunction:callback];
    [[DevilRecord sharedInstance] setTickCallback:^(int sec) {
        [[JevilFunctionUtil sharedInstance] callFunction:callback params:@[[NSNumber numberWithInt:sec]]];
    }];
    [[DevilRecord sharedInstance] tick];
    
}

+ (void)recordStop:(JSValue*)callback{
    [[JevilFunctionUtil sharedInstance] registFunction:callback];
    [[DevilRecord sharedInstance] stopRecord:^(id  _Nonnull res) {
        [[JevilFunctionUtil sharedInstance] callFunction:callback params:@[res]];
    }];
}

+ (void)recordCancelCallback:(JSValue*)callback{
    [[JevilFunctionUtil sharedInstance] registFunction:callback];
    [DevilRecord sharedInstance].cancelCallback = ^{
        [[JevilFunctionUtil sharedInstance] callFunction:callback params:@[]];
    };
}

+ (void)setText:(NSString*)node :(NSString*)text {
    id meta = [JevilInstance currentInstance].meta;
    WildCardUIView* vv = (WildCardUIView*)[meta getView:node];
    UILabel* l = [vv subviews][0];
    l.text = text;
}

+ (void)webLoad:(NSString*)node :(JSValue *)callback {
    DevilController* vc = (DevilController*)[JevilInstance currentInstance].vc;
    if(vc.mainWc != nil) {
        WildCardUIView* vv = (WildCardUIView*)[vc.mainWc.meta getView:node];
        DevilWebView* web = [vv subviews][0];
        web.shouldOverride = ^BOOL(NSString * _Nonnull url) {
            @try{
                JSValue* r = [callback callWithArguments:@[url]];
                return [r toBool];
            }@catch (NSException *exception) {
                [Jevil alert:[NSString stringWithFormat:@"%@", exception]];
            }
        };
    }
}

+ (void)scrollDragged:(NSString*)node :(JSValue *)callback {
    DevilController* vc = (DevilController*)[JevilInstance currentInstance].vc;
    if(node == nil || [@"null" isEqualToString:node] ) {
        [vc.tv setDraggedCallback:^(id res) {
            [callback callWithArguments:@[]];
        }];
    } else if(vc.mainWc != nil) {
        WildCardUIView* vv = (WildCardUIView*)[vc.mainWc.meta getView:node];
        UICollectionView* c = [vv subviews][0];
        WildCardCollectionViewAdapter* adapter = c.delegate;
        [adapter setDraggedCallback:^(id res) {
            [callback callWithArguments:@[]];
        }];
    }
}

+ (void)scrollEnd:(NSString*)node :(JSValue *)callback {
    DevilController* vc = (DevilController*)[JevilInstance currentInstance].vc;
    if(node == nil || [@"null" isEqualToString:node] ) {
        [vc.tv setLastItemCallback:^(id res) {
            [callback callWithArguments:@[]];
        }];
    } else if(vc.mainWc != nil) {
        WildCardUIView* vv = (WildCardUIView*)[vc.mainWc.meta getView:node];
        UICollectionView* c = [vv subviews][0];
        WildCardCollectionViewAdapter* adapter = c.delegate;
        [adapter setLastItemCallback:^(id res) {
            [callback callWithArguments:@[]];
        }];
    }
}

+ (void)textChanged:(NSString*)node :(JSValue *)callback {
    @try{
        DevilController* vc = (DevilController*)[JevilInstance currentInstance].vc;
        WildCardUIView* vv = [vc findView:node];
        id o = [vv subviews][0];
        if([o isMemberOfClass:[WildCardUITextField class]]) {
            WildCardUITextField* c = o;
            c.textChangedCallback = ^(NSString * _Nonnull text) {
                [JevilInstance currentInstance].meta = vc.mainWc.meta;
                [[JevilInstance currentInstance] pushData];
                [callback callWithArguments:@[text]];
            };
        } else {
            WildCardUITextView* c = o;
            c.textChangedCallback = ^(NSString * _Nonnull text) {
                [JevilInstance currentInstance].meta = vc.mainWc.meta;
                [[JevilInstance currentInstance] pushData];
                [callback callWithArguments:@[text]];
            };
        }
    }@catch(NSException* e){
        [DevilExceptionHandler handle:e];
    }
}

+ (void)textFocusChanged:(NSString*)node :(JSValue *)callback {
    DevilController* vc = (DevilController*)[JevilInstance currentInstance].vc;
    if(vc.mainWc != nil) {
        MetaAndViewResult* result = (WildCardUIView*)[vc findViewWithMeta:node];
        __block WildCardUIView* vv = result.view;
        __block WildCardMeta* meta = result.meta;
        
        id o = [vv subviews][0];
        if([o isMemberOfClass:[WildCardUITextField class]]) {
            WildCardUITextField* c = o;
            c.textFocusChangedCallback = ^(BOOL focus) {
                [JevilInstance currentInstance].meta = meta;
                [[JevilInstance currentInstance] pushData];
                [callback callWithArguments:@[(focus?@TRUE:@FALSE)]];
            };
        } else {
            WildCardUITextView* c = o;
            c.textFocusChangedCallback = ^(BOOL focus) {
                [JevilInstance currentInstance].meta = meta;
                [[JevilInstance currentInstance] pushData];
                [callback callWithArguments:@[(focus?@TRUE:@FALSE)]];
            };
        }
    }
}

+ (void)videoViewAutoPlay {
    //TODO
    [[JevilInstance currentInstance] performSelector:@selector(videoViewAutoPlay) withObject:nil afterDelay:0.5f];
}

+ (void)getCurrentLocation:(NSDictionary*)param :(JSValue*)callback{
    [[DevilLocation sharedInstance] getCurrentLocation:^(id  _Nonnull result) {
        [callback callWithArguments:@[ result ]];
    }];
}

+ (void)getCurrentPlace:(NSDictionary*)param :(JSValue*)callback {
    [[DevilLocation sharedInstance] getCurrentPlace:^(id  _Nonnull result) {
        [callback callWithArguments:@[ result ]];
    }];
}

+ (void)searchPlace:(NSDictionary*)param :(JSValue*)callback {
    [[DevilLocation sharedInstance] searchKoreanDongWithKakao:param[@"keyword"] :^(id  _Nonnull result) {
        [callback callWithArguments:@[ result ]];
    }];
}

+ (JSValue*)parseUrl:(NSString*)url{
    id r = [DevilUtil parseUrl:url];
    return r;
}

+ (void)menuReady:(NSString*)blockName :(NSDictionary*)param{
    [DevilDrawer menuReady:blockName :param];
}
+ (void)menuOpen:(NSString*)blockName{
    [DevilDrawer menuOpen:blockName];
}
+ (void)menuClose{
    [DevilDrawer menuClose];
}

+ (void)setTimer:(NSString*)key :(int)milli_sec :(JSValue*)callback {
    
    [NSObject cancelPreviousPerformRequestsWithTarget:[JevilInstance currentInstance] selector:@selector(timerFunction:) object:key];
    [[JevilInstance currentInstance] performSelector:@selector(timerFunction:) withObject:key afterDelay:milli_sec/1000.0f];
    [JevilInstance currentInstance].timerCallback = ^(id  _Nonnull res) {
        [callback callWithArguments:@[]];
    };
}

+ (void)removeTimer:(NSString*)key {
    [NSObject cancelPreviousPerformRequestsWithTarget:[JevilInstance currentInstance] selector:@selector(timerFunction:) object:key];
}

+ (void)beaconScan:(NSDictionary*)param :(JSValue*)callback :(JSValue*)foundCallback {
    
    [JevilInstance currentInstance].devilBeacon = [DevilBeacon sharedInstance];
    [[DevilBeacon sharedInstance] scan:param complete:^(id  _Nonnull res) {
        [callback callWithArguments:@[res]];
    } found:^(id  _Nonnull res) {
        [foundCallback callWithArguments:@[res]];
    }];
}

+ (void)beaconStop{
    [[DevilBeacon sharedInstance] stop];
}

+ (void)createDeepLink:(NSDictionary*)param :(JSValue*)callback {
    [[JevilFunctionUtil sharedInstance] registFunction:callback];
    [[DevilLink sharedInstance] create:param callback:^(id  _Nonnull res) {
        [[JevilFunctionUtil sharedInstance] callFunction:callback params:@[res]];
    }];
}

+ (NSString*)getReserveUrl {
    return [[DevilLink sharedInstance] getReserveUrl];
}

+ (NSString*)popReserveUrl {
    return [[DevilLink sharedInstance] popReserveUrl];
}

+ (void)localPush:(id)param {
    [[DevilLink sharedInstance] localPush:param];
}

+ (BOOL)consumeStandardReserveUrl {
    return [[DevilLink sharedInstance] consumeStandardReserveUrl];
}

+ (BOOL)standardUrlProcess:(NSString*)url {
    return [[DevilLink sharedInstance] standardUrlProcess:url];
}

+ (void)toJpg:(NSString*)nodeName :(JSValue*)callback
{
    [[JevilFunctionUtil sharedInstance] registFunction:callback];
    
    DevilController* vc = (DevilController*)[JevilInstance currentInstance].vc;
    UIView* view = [vc findView:nodeName];
    
    UIGraphicsBeginImageContextWithOptions(view.bounds.size, view.opaque, 0.0f);
    [view drawViewHierarchyInRect:view.bounds afterScreenUpdates:NO];
    UIImage * snapshotImage = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    UIImageWriteToSavedPhotosAlbum(snapshotImage,nil,nil,nil);
    
    [[JevilFunctionUtil sharedInstance] callFunction:callback params:@[@{@"r":@TRUE}]];
}

+ (void)androidEscapeDozeModeIf:(NSString*)msg:(NSString*)yes:(NSString*)no{
    
}


+ (void)video:(NSDictionary*)param{
    DevilPlayerController* d = [[DevilPlayerController alloc] init];
    d.param = param;
    //[[JevilInstance currentInstance].vc.navigationController pushViewController:d animated:YES];
    [[JevilInstance currentInstance].vc.navigationController presentModalViewController:d animated:YES];
}

+ (void)photo:(NSDictionary*)param{
    DevilPhotoController* d = [[DevilPhotoController alloc] init];
    d.param = param;
    //[[JevilInstance currentInstance].vc.navigationController pushViewController:d animated:YES];
    [[JevilInstance currentInstance].vc.navigationController presentModalViewController:d animated:YES];
}


+ (void)timer:(NSString*)node :(int)sec {
    DevilController* vc = (DevilController*)[JevilInstance currentInstance].vc;
    WildCardUIView* vv = [vc findView:node];
    WildCardTimer* timer = (WildCardTimer*)vv.tags[@"timer"];
    [timer startTimeFromSec:sec];
}

+ (void)custom:(NSString*)function {
    DevilController* vc = (DevilController*)[JevilInstance currentInstance].vc;
    NSString *action = function;
    WildCardTrigger* trigger = [[WildCardTrigger alloc] init];
    trigger.node = nil;
    [WildCardAction parseAndConducts:trigger action:action meta:[JevilInstance currentInstance].meta];
}

+ (void)bleList:(NSDictionary*)param :(JSValue *)callback {
    @try {
        [[JevilFunctionUtil sharedInstance] registFunction:callback];
        [[DevilBle sharedInstance] list:param :^(id  _Nonnull res) {
            [[JevilFunctionUtil sharedInstance] callFunction:callback params:@[res]];
        }];
    } @catch (NSException *exception) {
        //TODO
    }
}

+ (void)bleConnect:(NSString*)udid {
    [[DevilBle sharedInstance] connect:udid :^(id  _Nonnull res) {
        
    }];
}

+ (void)bleDisconnect:(NSString*)udid {
    [[DevilBle sharedInstance] disconnect:udid :^(id  _Nonnull res) {
        
    }];
}

+ (void)bleRelease:(NSString*)udid {
    [[DevilBle sharedInstance] bleRelease];
}

+ (void)bleCallback:(NSString*)command :(JSValue *)callback {
    [[JevilFunctionUtil sharedInstance] registFunction:callback];
    [[DevilBle sharedInstance] callback:command :^(id  _Nonnull res) {
        [[JevilFunctionUtil sharedInstance] callFunction:callback params:@[res]];
    }];
}

+ (void)bleWrite:(NSDictionary*)param :(JSValue *)callback{
    [[JevilFunctionUtil sharedInstance] registFunction:callback];
    [[DevilBle sharedInstance] send:param :^(id  _Nonnull res) {
        [[JevilFunctionUtil sharedInstance] callFunction:callback params:@[res]];
    }];
}

+ (void)bleRead:(NSDictionary*)param :(JSValue *)callback{
    [[JevilFunctionUtil sharedInstance] registFunction:callback];
    [[DevilBle sharedInstance] read:param :^(id  _Nonnull res) {
        [[JevilFunctionUtil sharedInstance] callFunction:callback params:@[res]];
    }];
}


+ (void)fileChooser:(NSDictionary*)param :(JSValue*)callback {
    [[JevilFunctionUtil sharedInstance] registFunction:callback];
    [[DevilFileChooser sharedInstance] fileChooser:[JevilInstance currentInstance].vc param:param callback:^(id  _Nonnull res) {
        if([res[@"r"] boolValue]) {
            [callback callWithArguments:@[res]];
        } else if(res[@"msg"]){
            [Jevil alert:res[@"msg"]];
        }
    }];
}

+ (void)imageMapCallback:(NSString*)nodeName :(NSString*)command :(JSValue*)callback {
    DevilController* vc = (DevilController*)[JevilInstance currentInstance].vc;
    DevilImageMap* map = (DevilImageMap*)[[vc findView:nodeName] subviews][0];
    [[JevilFunctionUtil sharedInstance] registFunction:callback];
    [map callback:command :^(id  _Nonnull res) {
        [[JevilFunctionUtil sharedInstance] callFunction:callback params:@[res]];
    }];
}

+ (void)imageMapLocation:(NSString*)nodeName :(NSString*)key :(JSValue*)callback {
    DevilController* vc = (DevilController*)[JevilInstance currentInstance].vc;
    DevilImageMap* map = (DevilImageMap*)[[vc findView:nodeName] subviews][0];
    [map relocation:key];
}

+ (void)imageMapMode:(NSString*)nodeName :(NSString*)mode :(NSDictionary*)param {
    DevilController* vc = (DevilController*)[JevilInstance currentInstance].vc;
    DevilImageMap* map = (DevilImageMap*)[[vc findView:nodeName] subviews][0];
    [map setMode:mode :param];
}

+ (NSString*)getByte:(NSString*)text {
    return [DevilUtil byteToHex:[text dataUsingEncoding:NSUTF8StringEncoding]];
}

+ (void)configHost:(NSString*)host{
    [WildCardConstructor sharedInstance].project[@"host"] = host;
}

+ (void)log:(NSString*)text:(NSDictionary*)log{
    [[DevilDebugView sharedInstance] log:DEVIL_LOG_CUSTOM title:text log:log];
}

@end
