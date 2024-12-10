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
#import "ReplaceRuleMarket.h"
#import "ReplaceRule.h"
#import "DevilBlockDrawerMarketComponent.h"
#import "DevilGoogleMapMarketComponent.h"
#import "MarketInstance.h"
#import "DevilUtil.h"
#import "DevilPdf.h"
#import "DevilReview.h"
#import "DevilContact.h"
#import "DevilPaintMarketComponent.h"
#import "DevilMultiPartUploader.h"
#import "DevilDownloader.h"
#import "DevilImageEditController.h"
#import "DevilGyroscope.h"
#import "DevilMqtt.h"

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
    d.landscape = [DevilUtil isLandscape:[DevilSdk sharedInstance].currentOrientation];
    
    d.screenId = screenId;
    [[JevilInstance currentInstance].vc.navigationController pushViewController:d animated:YES];
    [[DevilDebugView sharedInstance] log:DEVIL_LOG_SCREEN title:screenName log:param];
}

+ (void)tab:(NSString*)screenName{
    NSString* screenId = [[WildCardConstructor sharedInstance] getScreenIdByName:screenName];
    DevilController*vc = [JevilInstance currentInstance].vc;
    [vc tab:screenId];
}

+ (void)replaceScreen:(NSString*)screenName :(id)param{
    NSString* screenId = [[WildCardConstructor sharedInstance] getScreenIdByName:screenName];
    DevilController* d = (DevilController*)[[DevilSdk sharedInstance] getRegisteredScreenViewController:screenName];
    if(param != nil) {
        d.startData = param;
    }
    [DevilSdk sharedInstance].currentOrientation = [[WildCardConstructor sharedInstance] supportedOrientation:screenId :[Jevil get:@"ORIENTATION"]];
    d.landscape = [DevilUtil isLandscape:[DevilSdk sharedInstance].currentOrientation];
    
    d.screenId = screenId;
    UINavigationController* n = [JevilInstance currentInstance].vc.navigationController;
    [n popViewControllerAnimated:NO];
    [n pushViewController:d animated:NO];
    [[DevilDebugView sharedInstance] log:DEVIL_LOG_SCREEN title:screenName log:param];
    
    /**
     만약 현재 화면이 루트 화면이면 orientation이 변경이 콜되지 않는다 강제로 콜해줘야함
     */
    if([WildCardConstructor isTablet] && [n.viewControllers count] == 2) {
        NSString* orientation = [Jevil get:@"ORIENTATION"];
        if(orientation != nil && [@"landscape" isEqualToString:orientation] )
            [[UIDevice currentDevice] setValue:@(UIInterfaceOrientationLandscapeLeft) forKey:@"orientation"];
        else
            [[UIDevice currentDevice] setValue:@(UIInterfaceOrientationPortrait) forKey:@"orientation"];
        [UINavigationController attemptRotationToDeviceOrientation];
    }
}

+ (void)rootScreen:(NSString*)screenName :(id)param{
    NSString* screenId = [[WildCardConstructor sharedInstance] getScreenIdByName:screenName];
    DevilController* d = (DevilController*)[[DevilSdk sharedInstance] getRegisteredScreenViewController:screenName];
    if(param != nil) {
        d.startData = param;
    }
    
    [DevilSdk sharedInstance].currentOrientation = [[WildCardConstructor sharedInstance] supportedOrientation:screenId :[Jevil get:@"ORIENTATION"]];
    d.landscape = [DevilUtil isLandscape:[DevilSdk sharedInstance].currentOrientation];
    
    d.screenId = screenId;
    [[JevilInstance currentInstance].vc.navigationController setViewControllers:@[d]];
    [[DevilDebugView sharedInstance] log:DEVIL_LOG_SCREEN title:screenName log:param];
}

+ (void)markScreen{
    if([[JevilInstance currentInstance].vc isKindOfClass:[DevilController class]])
        [JevilInstance currentInstance].mark = [JevilInstance currentInstance].vc;
}

+ (void)backToMarkScreen{
    UINavigationController* n = [JevilInstance currentInstance].vc.navigationController;
    id arr = [@[] mutableCopy];
    BOOL foundMark = false;
    for(id v in n.viewControllers) {
        [arr addObject:v];
        if(v == [JevilInstance currentInstance].mark) {
            foundMark = true;
            break;
        }
    }
    if(foundMark)
        [[JevilInstance currentInstance].vc.navigationController setViewControllers:arr];
    else
        [[JevilInstance currentInstance].vc.navigationController popViewControllerAnimated:YES];
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
        
        if(callbackData[@"to"]) {
            UINavigationController* n = [JevilInstance currentInstance].vc.navigationController;
            id arr = [@[] mutableCopy];
            NSString* to = callbackData[@"to"];
            for(id v in n.viewControllers) {
                [arr addObject:v];
                if([v isKindOfClass:[DevilController class]]
                   && [((DevilController*)v).screenName isEqualToString:to]) {
                    [[JevilInstance currentInstance].vc.navigationController setViewControllers:arr];
                    [JevilInstance globalInstance].callbackData = nil;
                    return;
                }
            }
        }
    }
    
    if([[JevilInstance currentInstance].vc.navigationController.viewControllers count] == 1)
        exit(0);
    else
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
    if(![DevilAlertDialog showAlertTemplate: trans(msg) :^(BOOL yes) {
        
    }]) {
        UIAlertController *alertController = [UIAlertController alertControllerWithTitle:trans(msg)
                                                                                 message:nil
                                                                          preferredStyle:UIAlertControllerStyleAlert];
        
        [alertController addAction:[UIAlertAction actionWithTitle:trans(@"OK")
                                                            style:UIAlertActionStyleCancel
                                                          handler:^(UIAlertAction *action) {
            
        }]];
        
        [[JevilInstance currentInstance].vc presentViewController:alertController animated:YES completion:^{}];
        ((DevilController*)[JevilInstance currentInstance].vc).activeAlert = alertController;
    }
}

+ (void)alertFinish:(NSString*)msg{
    if(![DevilAlertDialog showAlertTemplate:trans(msg) :^(BOOL yes) {
        [[JevilInstance currentInstance].vc.navigationController popViewControllerAnimated:YES];
    }]) {
        UIAlertController *alertController = [UIAlertController alertControllerWithTitle:msg
                                                                                 message:nil
                                                                          preferredStyle:UIAlertControllerStyleAlert];
        
        [alertController addAction:[UIAlertAction actionWithTitle:trans(@"OK")
                                                            style:UIAlertActionStyleCancel
                                                          handler:^(UIAlertAction *action) {
            [[JevilInstance currentInstance].vc.navigationController popViewControllerAnimated:YES];
        }]];
        [[JevilInstance currentInstance].vc presentViewController:alertController animated:YES completion:^{}];
    }
    
}

+ (void)confirm:(NSString*)msg :(NSString*)yes :(NSString*)no :(JSValue *)callback {
    
    if(![DevilAlertDialog showConfirmTemplate:trans(msg) :yes :no :^(BOOL yes) {
        [callback callWithArguments:@[(yes?@YES:@NO)]];
        
    }]) {
        UIAlertController *alertController = [UIAlertController alertControllerWithTitle:nil
                                                                                 message:trans(msg)
                                                                          preferredStyle:UIAlertControllerStyleAlert];
        
        [alertController addAction:[UIAlertAction actionWithTitle:yes
                                                            style:UIAlertActionStyleDefault
                                                          handler:^(UIAlertAction *action) {
            [callback callWithArguments:@[@YES]];
            
            
        }]];
        
        [alertController addAction:[UIAlertAction actionWithTitle:no
                                                            style:UIAlertActionStyleCancel
                                                          handler:^(UIAlertAction *action) {
            [callback callWithArguments:@[@NO]];
            
        }]];
        [[JevilInstance currentInstance].vc presentViewController:alertController animated:YES completion:^{}];
    }
}

+ (void)alertThen:(NSString*)msg :(JSValue *)callback {
    
    if(![DevilAlertDialog showAlertTemplate:trans(msg) :^(BOOL yes) {
        [callback callWithArguments:@[]];
        
    }]) {
        UIAlertController *alertController = [UIAlertController alertControllerWithTitle:trans(msg)
                                                                                 message:nil
                                                                          preferredStyle:UIAlertControllerStyleAlert];
        
        [alertController addAction:[UIAlertAction actionWithTitle:trans(@"OK")
                                                            style:UIAlertActionStyleCancel
                                                          handler:^(UIAlertAction *action) {
            [callback callWithArguments:@[]];
            
            
        }]];
        [[JevilInstance currentInstance].vc presentViewController:alertController animated:YES completion:^{}];
    }
}

+ (void)alertThenOption:(id)param :(JSValue *)callback {
    NSString* msg = param[@"msg"];
    BOOL cancelable = [param[@"cancelable"] boolValue];
    NSString* yes = trans(@"OK");
    if(param[@"yes"])
        yes = param[@"yes"];
    if(![DevilAlertDialog showAlertTemplate:trans(msg) :^(BOOL yes) {
        [callback callWithArguments:@[]];
        
    }]) {
        UIAlertController *alertController = [UIAlertController alertControllerWithTitle:trans(msg)
                                                                                 message:nil
                                                                          preferredStyle:UIAlertControllerStyleAlert];
        
        [alertController addAction:[UIAlertAction actionWithTitle:yes
                                                            style:UIAlertActionStyleCancel
                                                          handler:^(UIAlertAction *action) {
            [callback callWithArguments:@[]];
            
            
        }]];
        [[JevilInstance currentInstance].vc presentViewController:alertController animated:YES completion:^{
            
        }];
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
        [[DevilDebugView sharedInstance] log:DEVIL_LOG_REQUEST title:[@"GET " stringByAppendingString:originalUrl] log:nil];
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
                
            }
        }];
    }
}

+ (void)httpWithMultipartPost:(NSString *)url :(NSDictionary*)headerObject :(NSDictionary*)param :(JSValue *)progress_callback :(JSValue *)callback {
    [[JevilFunctionUtil sharedInstance] registFunction:callback];
    [[JevilFunctionUtil sharedInstance] registFunction:progress_callback];
    
    if([url hasPrefix:@"/"])
        url = [NSString stringWithFormat:@"%@%@", [WildCardConstructor sharedInstance].project[@"host"], url];
    
    id header = [@{} mutableCopy];
    if(headerObject)
        header = [headerObject mutableCopy];
    
    NSString* x_access_token_key = [NSString stringWithFormat:@"x-access-token"];
    if([Jevil get:x_access_token_key])
        header[@"x-access-token"] = [Jevil get:x_access_token_key];
    
    DevilMultiPartUploader* devilMultiPartUploader = [[DevilMultiPartUploader alloc] init];
    [devilMultiPartUploader multiPartUpload:[param[@"showProgress"] boolValue] url:url header:header name:param[@"name"] filename:param[@"filename"] filePath:param[@"path"] progress:^(id  _Nonnull res) {
        if(progress_callback) {
            [[JevilFunctionUtil sharedInstance] callFunction:progress_callback params:@[res]];
        }
    } complete:^(id  _Nonnull res) {
        [[JevilFunctionUtil sharedInstance] callFunction:callback params:@[res]];
    }];
}

+ (void)httpWithFilePath:(NSString *)method :(NSString *)url :(NSDictionary*)headerObject :(NSString*)filepath :(JSValue *)callback {
    [[JevilFunctionUtil sharedInstance] registFunction:callback];
    NSString* originalUrl = url;
    if([url hasPrefix:@"/"])
        url = [NSString stringWithFormat:@"%@%@", [WildCardConstructor sharedInstance].project[@"host"], url];
    
    id header = [@{} mutableCopy];
    if(headerObject)
        header = [headerObject mutableCopy];
    
    NSString* x_access_token_key = [NSString stringWithFormat:@"x-access-token"];
    if([Jevil get:x_access_token_key])
        header[@"x-access-token"] = [Jevil get:x_access_token_key];
    
    NSData* data = [NSData dataWithContentsOfFile:[DevilUtil replaceUdidPrefixDir:filepath]];
    if(data == nil) {
        [[JevilFunctionUtil sharedInstance] callFunction:callback params:@[@{@"r":@FALSE, @"msg":@"File not exists"}]];
        return;
    }
    NSString* contentType = [DevilUtil fileNameToContentType:filepath];
    [[DevilDebugView sharedInstance] log:DEVIL_LOG_REQUEST title:[NSString stringWithFormat:@"%@ %@",method,originalUrl] log:nil];
    [DevilUtil httpPut:url contentType:contentType path:filepath complete:^(id _Nonnull res) {
        if(res == nil)
            res = [@{} mutableCopy];
        else if([res isMemberOfClass:[NSError class]]){
            NSString* error = [NSString stringWithFormat:@"%@", res];
            [[DevilDebugView sharedInstance] log:DEVIL_LOG_RESPONSE title:originalUrl log:@{error:error}];
        } else
            [[DevilDebugView sharedInstance] log:DEVIL_LOG_RESPONSE title:originalUrl log:res];
        
        [[JevilFunctionUtil sharedInstance] callFunction:callback params:@[res]];
    }];
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
    [[DevilDebugView sharedInstance] log:DEVIL_LOG_REQUEST title:[NSString stringWithFormat:@"%@ %@",method,originalUrl] log:nil];
    [[WildCardConstructor sharedInstance].delegate onNetworkRequestHttp:method :url :header :[body mutableCopy] :^(NSMutableDictionary *responseJsonObject) {
        if(responseJsonObject == nil)
            responseJsonObject = [@{} mutableCopy];
        else if([responseJsonObject isMemberOfClass:[NSError class]]){
            NSString* error = [NSString stringWithFormat:@"%@", responseJsonObject];
            [[DevilDebugView sharedInstance] log:DEVIL_LOG_RESPONSE title:originalUrl log:@{error:error}];
        } else
            [[DevilDebugView sharedInstance] log:DEVIL_LOG_RESPONSE title:originalUrl log:responseJsonObject];
        
        [[JevilFunctionUtil sharedInstance] callFunction:callback params:@[responseJsonObject]];
        
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
    
    [[DevilDebugView sharedInstance] log:DEVIL_LOG_REQUEST title:[@"GET " stringByAppendingString:originalUrl] log:nil];
    [[WildCardConstructor sharedInstance].delegate onNetworkRequestGet:url header:header success:^(NSMutableDictionary *responseJsonObject) {
        
        if(responseJsonObject == nil)
            responseJsonObject = [@{} mutableCopy];
        else if([responseJsonObject isMemberOfClass:[NSError class]]){
            NSString* error = [NSString stringWithFormat:@"%@", responseJsonObject];
            [[DevilDebugView sharedInstance] log:DEVIL_LOG_RESPONSE title:originalUrl log:@{error:error}];
        } else
            [[DevilDebugView sharedInstance] log:DEVIL_LOG_RESPONSE title:originalUrl log:responseJsonObject];
        
        [[JevilFunctionUtil sharedInstance] callFunction:callback params:@[responseJsonObject]];
        
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
    
    [[DevilDebugView sharedInstance] log:DEVIL_LOG_REQUEST title:[@"POST " stringByAppendingString:originalUrl] log:param];
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
    
    [[DevilDebugView sharedInstance] log:DEVIL_LOG_REQUEST title:[@"PUT " stringByAppendingString:originalUrl] log:param];
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
        
        NSString* url = [NSString stringWithFormat:@"%@%@", [WildCardConstructor sharedInstance].project[@"host"], put_url];
        id ext_list = [@[] mutableCopy];
        id processed_path_list = [@[] mutableCopy];
        for(int i=0;i<[paths count];i++){
            __block NSString* path = [DevilUtil replaceUdidPrefixDir:paths[i]];
            [processed_path_list addObject:path];
            id ss = [path componentsSeparatedByString:@"."];
            NSString* ext = ss[[ss count]-1];
            [ext_list addObject:ext];
        }
        
        for(int i=0;i<[processed_path_list count];i++){
            NSString* path = processed_path_list[i];
            NSData* data = [NSData dataWithContentsOfFile:[DevilUtil replaceUdidPrefixDir:path]];
            if([data length] == 0) {
                result[@"r"] = @FALSE;
                result[@"code"] = @"CODE_FILE_NOT_FOUND";
                result[@"path"] = paths[i];
                result[@"msg"] = @"File not found";
                [callback callWithArguments:@[result]];
            }
        }
        
        [[WildCardConstructor sharedInstance].delegate onNetworkRequestPost:url header:header json:@{@"ext_list":ext_list} success:^(NSMutableDictionary *res) {
            
            if(cancelled)
                return;
            
            if(!res || ![res[@"r"] boolValue]) {
                result[@"r"] = @FALSE;
                if(showUploadingPopup)
                    [vc closeActiveAlertMessage];
                
                [callback callWithArguments:@[result]];
                
                return;
            }
            
            id upload_list = res[@"list"];
            for(int i=0;i<[upload_list count];i++) {
                id upload = upload_list[i];
                
                NSString* upload_url = upload[@"upload_url"];
                [uploadedFile addObject:upload[@"key"]];
                
                NSString* path = processed_path_list[i];
                NSString* contentType = [DevilUtil fileNameToContentType:path];
                [DevilUtil httpPut:upload_url contentType:contentType path:path complete:^(id  _Nonnull res) {
                    if(cancelled)
                        return;
                    
                    s3index++;
                    
                    if(showUploadingPopup)
                        [vc setActiveAlertMessage:[NSString stringWithFormat:@"%@ %d / %d", trans(@"업로드 중입니다"), s3index, (int)[paths count]]];
                    
                    if(res != nil)
                        [uploadedFileSuccess addObject:@TRUE];
                    else {
                        [uploadedFileSuccess addObject:@FALSE];
                        result[@"r"] = @FALSE;
                    }
                    
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
                        
                    }
                }];
            }
        }];
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
    
    [[DevilDebugView sharedInstance] log:DEVIL_LOG_REQUEST title:[@"GET " stringByAppendingString:@"/push/key"] log:nil];
    [[WildCardConstructor sharedInstance].delegate onNetworkRequestGet:url header:header success:^(NSMutableDictionary *responseJsonObject) {
        [[DevilDebugView sharedInstance] log:DEVIL_LOG_RESPONSE title:@"/push/key" log:responseJsonObject];
    }];
    
}

+ (void)getThenWithHeader:(NSString *)url :(id)header :(JSValue *)callback {
    
    NSString* originalUrl = url;
    if([url hasPrefix:@"/"])
        url = [NSString stringWithFormat:@"%@%@", [WildCardConstructor sharedInstance].project[@"host"], url];
    
    [[DevilDebugView sharedInstance] log:DEVIL_LOG_REQUEST title:[@"GET " stringByAppendingString:originalUrl] log:nil];
    [[WildCardConstructor sharedInstance].delegate onNetworkRequestGet:url header:header success:^(NSMutableDictionary *responseJsonObject) {
        [[DevilDebugView sharedInstance] log:DEVIL_LOG_RESPONSE title:originalUrl log:responseJsonObject];
        
        if(!responseJsonObject)
            responseJsonObject = [@{} mutableCopy];
        [callback callWithArguments:@[responseJsonObject, @YES]];
        
    }];
}

+ (void)postThenWithHeader:(NSString *)url :(id)header :(id)param :(JSValue *)callback {
    
    NSString* originalUrl = url;
    if([url hasPrefix:@"/"])
        url = [NSString stringWithFormat:@"%@%@", [WildCardConstructor sharedInstance].project[@"host"], url];
    
    if(!header)
        header = [@{} mutableCopy];
    
    [[DevilDebugView sharedInstance] log:DEVIL_LOG_REQUEST title:[@"POST " stringByAppendingString:originalUrl] log:param];
    [[WildCardConstructor sharedInstance].delegate onNetworkRequestPost:url header:header json:param success:^(NSMutableDictionary *responseJsonObject) {
        [[DevilDebugView sharedInstance] log:DEVIL_LOG_RESPONSE title:originalUrl log:responseJsonObject];
        
        if(!responseJsonObject)
            responseJsonObject = [@{} mutableCopy];
        [callback callWithArguments:@[responseJsonObject, @YES]];
        
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

+ (void)scrollTo:(NSString*)nodeName :(int)index :(id)param {
    
    @try{
        [[JevilInstance currentInstance] performSelector:@selector(videoViewAutoPlay) withObject:nil afterDelay:0.001f];
        if(nodeName && ![@"null" isEqualToString:nodeName] ) {
            DevilController* vc = (DevilController*)[JevilInstance currentInstance].vc;
            WildCardUICollectionView* list = (WildCardUICollectionView*)[[vc findView:nodeName] subviews][0];
            int max = (int)[((WildCardCollectionViewAdapter*)list.delegate) getCount];
            if(index >= max)
                index = max - 1;
            if(list != nil) {
                BOOL ani = param[@"animation"] ? [param[@"animation"] boolValue] : YES;
                int offset = param[@"offset"] ? [WildCardConstructor convertSketchToPixel:[param[@"offset"] doubleValue]] : 0;
                if(offset > 0) {
                    
                    UIWindow *window = UIApplication.sharedApplication.windows.firstObject;
                    float adjustAreaHeight = window.safeAreaInsets.top;
                    
                    UICollectionViewLayoutAttributes *firstCellAttributes = [list layoutAttributesForItemAtIndexPath:[NSIndexPath indexPathForRow:index inSection:0]];
                    int y = firstCellAttributes.frame.origin.y - offset - adjustAreaHeight;
                    [list setContentOffset:CGPointMake(0, y) animated:ani];
                } else
                    [list scrollTo:index : ani];
            }
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
    }
}

+ (void)updateThis{
    
    [[JevilInstance currentInstance].meta update];
}

+ (void)popup:(NSString*)blockName :(NSDictionary*)param :(JSValue *)callback{
    NSString* title = param[@"title"];
    NSString* yes = param[@"yes"];
    NSString* no = param[@"no"];
    NSString* show = param[@"show"];
    
    
    DevilBlockDialog* d = [DevilBlockDialog popup:blockName data:[JevilInstance currentInstance].data title:title yes:yes no:no
                                             show:show
                                            param:param
                                         delegate:[JevilInstance currentInstance].vc
                                         onselect:^(BOOL yes, id res) {
        [callback callWithArguments:@[(yes?@TRUE:@FALSE)]];
        
    }];
    if(!d)
        return [Jevil alert:[NSString stringWithFormat:@"Block Name does not exists[ %@]", blockName]];
    
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
    
    DevilBlockDialog* d = [DevilBlockDialog popup:@"address" data:[JevilInstance currentInstance].data title:title yes:yes no:no
                                             show:show
                                         onselect:^(BOOL yes, id res) {
        [[JevilInstance currentInstance] pushData];
        [callback callWithArguments:@[(yes?@TRUE:@FALSE)]];
        
    }];
    
    if([[JevilInstance currentInstance].vc isKindOfClass:[DevilController class]])
        ((DevilController*)[JevilInstance currentInstance].vc).devilBlockDialog = d;
    
    d.didFinishDismissingBlock = ^{
        if([[JevilInstance currentInstance].vc isKindOfClass:[DevilController class]])
            ((DevilController*)[JevilInstance currentInstance].vc).devilBlockDialog = nil;
    };
}


+ (void)popupClose:(id)yes {
    if(((DevilController*)[JevilInstance currentInstance].vc).devilBlockDialog) {
        if(yes == nil)
            [((DevilController*)[JevilInstance currentInstance].vc).devilBlockDialog dismiss];
        else
            [((DevilController*)[JevilInstance currentInstance].vc).devilBlockDialog dismissWithCallback:yes];
    }
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
            
        }
    }];
    
    if([[JevilInstance currentInstance].vc isKindOfClass:[DevilController class]])
        [((DevilController*)[JevilInstance currentInstance].vc).retainObject addObject:d];
}

+ (void)resetTimer:(NSString *)nodeName {
    DevilController* vc = (DevilController*)[JevilInstance currentInstance].vc;
    WildCardUIView* vv = [vc findView:nodeName];
    [vv.tags[@"timer"] reset];
}

+ (void)timerReset:(NSString *)nodeName {
    DevilController* vc = (DevilController*)[JevilInstance currentInstance].vc;
    WildCardUIView* vv = [vc findView:nodeName];
    [vv.tags[@"timer"] reset];
}

+ (void)timerPause:(NSString *)nodeName {
    DevilController* vc = (DevilController*)[JevilInstance currentInstance].vc;
    WildCardUIView* vv = [vc findView:nodeName];
    [vv.tags[@"timer"] pause];
}

+ (void)timerResume:(NSString *)nodeName {
    DevilController* vc = (DevilController*)[JevilInstance currentInstance].vc;
    WildCardUIView* vv = [vc findView:nodeName];
    [vv.tags[@"timer"] resume];
}

+ (void)setViewPagerSelectedIndex:(NSString *)nodeName :(int)index{
    DevilController* dc = ((DevilController*)[JevilInstance currentInstance].vc);
    id meta = dc.mainWc.meta;
    WildCardUIView* vv = (WildCardUIView*)[meta getView:nodeName];
    UICollectionView* cv = (UICollectionView*)[vv subviews][0];
    WildCardCollectionViewAdapter* adapter = (WildCardCollectionViewAdapter*)cv.delegate;
    if(index < [adapter getCount])
        [adapter scrollToIndex:index view:adapter.collectionView];
    else {
        if(!dc.viewPagerReservedSelectedIndexMap)
            dc.viewPagerReservedSelectedIndexMap = [@{} mutableCopy];
        dc.viewPagerReservedSelectedIndexMap[nodeName] = [NSNumber numberWithInt:index];
    }
}

+ (int)getViewPagerSelectedIndex:(NSString *)nodeName{
    id meta = ((DevilController*)[JevilInstance currentInstance].vc).mainWc.meta;
    WildCardUIView* vv = (WildCardUIView*)[meta getView:nodeName];
    UICollectionView* cv = (UICollectionView*)[vv subviews][0];
    WildCardCollectionViewAdapter* adapter = (WildCardCollectionViewAdapter*)cv.delegate;
    return adapter.selectedIndex;
}

+ (void)viewPagerSelectedCallback:(NSString*)nodeName :(JSValue*)callback{
    DevilController* dc = ((DevilController*)[JevilInstance currentInstance].vc);
    id meta = dc.mainWc.meta;
    [[JevilFunctionUtil sharedInstance] registFunction:callback];
    WildCardUIView* vv = (WildCardUIView*)[meta getView:nodeName];
    if(vv) {
        UICollectionView* cv = (UICollectionView*)[vv subviews][0];
        WildCardCollectionViewAdapter* adapter = (WildCardCollectionViewAdapter*)cv.delegate;
        [adapter setViewPagerSelectedCallback:^(int index) {
            [[JevilFunctionUtil sharedInstance] callFunction:callback params:@[
                nodeName,
                [NSNumber numberWithInt:index]
            ]];
        }];
    } else {
        if(!dc.viewPagerReservedSelectedCallbackMap)
            dc.viewPagerReservedSelectedCallbackMap = [@{} mutableCopy];
        dc.viewPagerReservedSelectedCallbackMap[nodeName] = ^(int index) {
            [[JevilFunctionUtil sharedInstance] callFunction:callback params:@[
                nodeName,
                [NSNumber numberWithInt:index]
            ]];
        };
    }
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
        
    }];
    
    if([[JevilInstance currentInstance].vc isKindOfClass:[DevilController class]])
        ((DevilController*)[JevilInstance currentInstance].vc).wifiManager = wm;
}

+ (void)gallery:(NSDictionary*)param :(JSValue *)callback {
    [DevilCamera gallery:[JevilInstance currentInstance].vc param:param callback:^(id  _Nonnull res) {
        if([res[@"r"] boolValue]) {
            [callback callWithArguments:@[res]];
            
        } else if(res[@"msg"]){
            [Jevil alert:res[@"msg"]];
        }
    }];
}

+ (void)galleryList:(NSDictionary*)param :(JSValue *)callback {
    [DevilCamera galleryList:[JevilInstance currentInstance].vc param:param callback:^(id  _Nonnull res) {
        [callback callWithArguments:@[res]];
        
    }];
}

+ (void)gallerySystem:(NSDictionary*)param :(JSValue *)callback {
    [[DevilCamera sharedInstance] gallerySystem:[JevilInstance currentInstance].vc param:param callback:^(id  _Nonnull res) {
        if([res[@"r"] boolValue]) {
            [callback callWithArguments:@[res]];
            
        } else if(res[@"msg"]){
            [Jevil alert:res[@"msg"]];
        }
    }];
}


+ (void)cameraSystem:(NSDictionary*)param :(JSValue *)callback {
    [[DevilCamera sharedInstance] cameraSystem:[JevilInstance currentInstance].vc param:param callback:^(id  _Nonnull res) {
        if([res[@"r"] boolValue]) {
            [callback callWithArguments:@[res]];
            
        } else if(res[@"msg"]){
            [Jevil alert:res[@"msg"]];
        }
    }];
}

+ (void)camera:(NSDictionary*)param :(JSValue *)callback {
    [DevilCamera camera:[JevilInstance currentInstance].vc param:param callback:^(id  _Nonnull res) {
        if([res[@"r"] boolValue]) {
            [callback callWithArguments:@[res]];
            
        } else if(res[@"msg"]){
            [Jevil alert:res[@"msg"]];
        }
    }];
}

+ (void)cameraQr:(NSDictionary*)param :(JSValue *)callback {
    [DevilCamera cameraQr:[JevilInstance currentInstance].vc param:param callback:^(id  _Nonnull res) {
        if([res[@"r"] boolValue]) {
            [callback callWithArguments:@[res]];
            
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
    UIActivityViewController *activityViewController = [[UIActivityViewController alloc] initWithActivityItems:activityItems applicationActivities:nil];
    if(activityViewController.popoverPresentationController) {
        activityViewController.popoverPresentationController.sourceView = [JevilInstance currentInstance].vc.view;
        float sw = [UIScreen mainScreen].bounds.size.width;
        float sh = [UIScreen mainScreen].bounds.size.height;
        activityViewController.popoverPresentationController.sourceRect = CGRectMake(sw*0.5, sh*0.5, 0, 0);
        activityViewController.popoverPresentationController.permittedArrowDirections = nil;
    }
    activityViewController.excludedActivityTypes = @[];
    [[JevilInstance currentInstance].vc presentViewController:activityViewController animated:true completion:nil];
}

+ (void)out:(NSString*)url :(BOOL)force {
    @try {
        if([url hasPrefix:@"http"] && !force) {
            SFSafariViewController *svc = [[SFSafariViewController alloc] initWithURL:[NSURL URLWithString:url]];
            [[JevilInstance currentInstance].vc presentViewController:svc animated:YES completion:nil];
        } else {
            [[UIApplication sharedApplication] openURL:[NSURL URLWithString: url] options:@{} completionHandler:^(BOOL success) {
                
            }];
        }
    } @catch (NSException* e) {
        [DevilExceptionHandler handle:e];
    }
}

+ (void)saveFileFromUrl:(NSDictionary*)param :(JSValue *)callback {
    [[JevilFunctionUtil sharedInstance] registFunction:callback];
    
    __block BOOL showProgress = [param[@"showProgress"] boolValue];
    
    [[DevilDebugView sharedInstance] log:DEVIL_LOG_REQUEST title:@"saveFileFromUrl" log:param];
    DevilDownloader* downloder = [[DevilDownloader alloc] init];
    NSString* destFilePath = [DevilUtil generateDocumentFilePathWithName:param[@"destFileName"]];
    [downloder download:showProgress url:param[@"url"] header:@{} filePath:destFilePath progress:^(id  _Nonnull res) {
        
    } complete:^(id  _Nonnull res) {
        [[JevilFunctionUtil sharedInstance] callFunction:callback params:@[res]];
    }];
    [((DevilController*)[JevilInstance currentInstance].vc).retainObject addObject:downloder];
    
}

+ (void)downloadAndView:(NSString*)url {
    
    DevilDownloader* downloder = [[DevilDownloader alloc] init];
    [downloder download:true url:url header:@{} filePath:nil progress:^(id  _Nonnull res) {
        
    } complete:^(id  _Nonnull res) {
        if([res[@"r"] boolValue]) {
            NSString* path = res[@"dest"];
            NSString* pathEncoding = res[@"dest_encoding"];
            UIDocumentInteractionController * d = [UIDocumentInteractionController interactionControllerWithURL: [NSURL URLWithString:[NSString stringWithFormat:@"file:/%@", pathEncoding]]];
            DevilController* vc = (DevilController*)[JevilInstance currentInstance].vc;
            d.delegate = vc;
            [d presentPreviewAnimated:YES];
            [JevilInstance currentInstance].forRetain[@"UIDocumentInteractionController"] = d;
        } else {
            if(res[@"msg"])
                [Jevil alert:res[@"msg"]];
            else
                [Jevil alert:trans(@"Unknown Error")];
        }
    }];
    [((DevilController*)[JevilInstance currentInstance].vc).retainObject addObject:downloder];
}

+ (void)downloadAndViewWithOption:(id)param {
    NSString* url = param[@"url"];
    NSString* path = nil;
    if(param[@"name"])
        path = [DevilUtil generateTempFilePathWithName:param[@"name"]];
    DevilDownloader* downloder = [[DevilDownloader alloc] init];
    [downloder download:true url:url header:@{} filePath:path progress:^(id  _Nonnull res) {
        
    } complete:^(id  _Nonnull res) {
        if([res[@"r"] boolValue]) {
            NSString* path = res[@"dest"];
            NSString* pathEncoding = res[@"dest_encoding"];
            UIDocumentInteractionController * d = [UIDocumentInteractionController interactionControllerWithURL: [NSURL URLWithString:[NSString stringWithFormat:@"file:/%@", pathEncoding]]];
            DevilController* vc = (DevilController*)[JevilInstance currentInstance].vc;
            d.delegate = vc;
            [d presentPreviewAnimated:YES];
            [JevilInstance currentInstance].forRetain[@"UIDocumentInteractionController"] = d;
        } else {
            if(res[@"msg"])
                [Jevil alert:res[@"msg"]];
            else
                [Jevil alert:trans(@"Unknown Error")];
        }
    }];
    [((DevilController*)[JevilInstance currentInstance].vc).retainObject addObject:downloder];
}

+ (void)downloadAndShare:(NSString*)url {
    
    __block BOOL showProgress = true;
    
    DevilDownloader* downloder = [[DevilDownloader alloc] init];
    [downloder download:showProgress url:url header:@{} filePath:nil progress:^(id  _Nonnull res) {
        
    } complete:^(id  _Nonnull res) {
        if([res[@"r"] boolValue]) {
            NSString* path = res[@"dest"];
            NSString* pathEncoding = res[@"dest_encoding"];
            UIActivityViewController *activityViewController = [[UIActivityViewController alloc] initWithActivityItems:@[[NSURL URLWithString:[NSString stringWithFormat:@"file:/%@", pathEncoding]]]
                                                                                                 applicationActivities:nil];
            if(activityViewController.popoverPresentationController) {
                activityViewController.popoverPresentationController.sourceView = [JevilInstance currentInstance].vc.view;
                
                float sw = [UIScreen mainScreen].bounds.size.width;
                float sh = [UIScreen mainScreen].bounds.size.height;
                activityViewController.popoverPresentationController.sourceRect = CGRectMake(sw*0.5, sh*0.5, 0, 0);
                activityViewController.popoverPresentationController.permittedArrowDirections = nil;
            }
            [[JevilInstance currentInstance].vc.navigationController presentViewController:activityViewController
                                                                                  animated:YES
                                                                                completion:^{
                
            }];
        } else {
            if(res[@"msg"])
                [Jevil alert:res[@"msg"]];
            else
                [Jevil alert:trans(@"Unknown Error")];
        }
    }];
    [((DevilController*)[JevilInstance currentInstance].vc).retainObject addObject:downloder];
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
    if([[DevilSpeech sharedInstance] isRecording]) {
        [[DevilSpeech sharedInstance] cancel];
        [[JevilFunctionUtil sharedInstance] callFunction:callback params:@[ @{@"r":@FALSE, @"end":@TRUE, @"msg":@"Recording"}]];
    } else {
        [[DevilSpeech sharedInstance] listen:param :^(id  _Nonnull res) {
            [[JevilFunctionUtil sharedInstance] callFunction:callback params:@[ res ]];
        }];
    }
    
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


+ (void)webScript:(NSString*)node :(NSString *)javascript :(JSValue *)callback {
    DevilController* vc = (DevilController*)[JevilInstance currentInstance].vc;
    if(vc.mainWc != nil) {
        WildCardUIView* vv = (WildCardUIView*)[vc.mainWc.meta getView:node];
        DevilWebView* web = [vv subviews][0];
        [web evaluateJavaScript:javascript completionHandler:^(id _Nullable, NSError * _Nullable error) {
            [callback callWithArguments:@[]];
        }];
    }
}

+ (void)webLoadUrl:(NSString*)node :(NSString*)url {
    DevilController* vc = (DevilController*)[JevilInstance currentInstance].vc;
    WildCardUIView* vv = (WildCardUIView*)[vc.mainWc.meta getView:node];
    DevilWebView* web = [vv subviews][0];
    if([url hasPrefix:@"/"]) {
        url = [NSString stringWithFormat:@"%@%@", [WildCardConstructor sharedInstance].project[@"web_host"], url];
    }
    [web loadRequest:[NSURLRequest requestWithURL:[NSURL URLWithString:url]]];
}

+ (NSString*)webCurrentUrl:(NSString*)node {
    DevilController* vc = (DevilController*)[JevilInstance currentInstance].vc;
    WildCardUIView* vv = (WildCardUIView*)[vc.mainWc.meta getView:node];
    DevilWebView* web = [vv subviews][0];
    return [web.URL absoluteString];
}

+ (void)webForward:(NSString*)node {
    DevilController* vc = (DevilController*)[JevilInstance currentInstance].vc;
    WildCardUIView* vv = (WildCardUIView*)[vc.mainWc.meta getView:node];
    DevilWebView* web = [vv subviews][0];
    [web goForward];
}

+ (void)webRefresh:(NSString*)node {
    DevilController* vc = (DevilController*)[JevilInstance currentInstance].vc;
    WildCardUIView* vv = (WildCardUIView*)[vc.mainWc.meta getView:node];
    DevilWebView* web = [vv subviews][0];
    [web reload];
}

+ (void)startDragAndDrop:(NSString*)node :(id)param :(JSValue *)callback {
    DevilController* vc = (DevilController*)[JevilInstance currentInstance].vc;
    WildCardUIView* vv = [vc findView:node];
    WildCardUICollectionView* c = [vv subviews][0];
    WildCardCollectionViewAdapter* adapter = (WildCardCollectionViewAdapter*)c.delegate;
    if(param[@"dropRangeFrom"])
        adapter.dragAndDropRangeFrom = [param[@"dropRangeFrom"] intValue];
    else
        adapter.dragAndDropRangeFrom = -1;
    
    if(param[@"dropRangeFrom"])
        adapter.dragAndDropRangeTo = [param[@"dropRangeTo"] intValue];
    else
        adapter.dragAndDropRangeTo = -1;
    
    adapter.dragAndDropCallback = ^(int fromIndex, int toIndex) {
        @try{
            [callback callWithArguments:@[@{
                @"event":@"complete",
                @"fromIndex":[NSNumber numberWithInt:fromIndex],
                @"toIndex":[NSNumber numberWithInt:toIndex],
            }]];
        }@catch(NSException* e){
            [DevilExceptionHandler handle:e];
        }
    };
    [c dragEnable:YES];
}

+ (void)stopDragAndDrop:(NSString*)node :(JSValue *)callback {
    DevilController* vc = (DevilController*)[JevilInstance currentInstance].vc;
    WildCardUIView* vv = [vc findView:node];
    WildCardUICollectionView* c = [vv subviews][0];
    [c dragEnable:NO];
    WildCardCollectionViewAdapter* adapter = (WildCardCollectionViewAdapter*)c.delegate;
    adapter.dragAndDropCallback = nil;
}

+ (void)scrollDragged:(NSString*)node :(JSValue *)callback {
    DevilController* vc = (DevilController*)[JevilInstance currentInstance].vc;
    if(vc.mainWc != nil) {
        WildCardUIView* vv = (WildCardUIView*)[vc.mainWc.meta getView:node];
        UICollectionView* c = [vv subviews][0];
        WildCardCollectionViewAdapter* adapter = (WildCardCollectionViewAdapter*)c.delegate;
        [adapter setDraggedCallback:^(id res) {
            [callback callWithArguments:@[]];
        }];
    }
}

+ (void)scrollEnd:(NSString*)node :(JSValue *)callback {
    DevilController* vc = (DevilController*)[JevilInstance currentInstance].vc;
    if(vc.mainWc != nil) {
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

+ (void)videoCallback:(NSString*)nodeName :(NSString*)event :(JSValue*)callback{
    DevilController* vc = (DevilController*)[JevilInstance currentInstance].vc;
    WildCardUIView* view = [vc findView:nodeName];
    WildCardVideoView* vv = (WildCardVideoView*)[view subviews][0];
    [vv callback:nodeName callback:^(id _Nonnull res) {
        [callback callWithArguments:@[ res ]];
    }];
}



+ (void)getCurrentLocation:(NSDictionary*)param :(JSValue*)callback{
    [[DevilLocation sharedInstance] getCurrentLocation:^(id  _Nonnull result) {
        [callback callWithArguments:@[ result ]];
    }];
}

+ (void)getCurrentPlace:(NSDictionary*)param :(JSValue*)callback {
    [[DevilLocation sharedInstance] getCurrentPlace:param:^(id  _Nonnull result) {
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
+ (void)drawerOpen:(NSString*)node{
    DevilController* vc = (DevilController*)[JevilInstance currentInstance].vc;
    WildCardUIView* view = [vc findView:node];
    DevilBlockDrawerMarketComponent* mc = (DevilBlockDrawerMarketComponent*)[MarketInstance findMarketComponent:vc.mainWc.meta replaceView:view];
    [mc naviUp];
    
}
+ (void)drawerClose:(NSString*)node{
    DevilController* vc = (DevilController*)[JevilInstance currentInstance].vc;
    WildCardUIView* view = [vc findView:node];
    DevilBlockDrawerMarketComponent* mc = (DevilBlockDrawerMarketComponent*)[MarketInstance findMarketComponent:vc.mainWc.meta replaceView:view];
    [mc naviDown];
}
+ (void)drawerMove:(NSString*)node :(int)offset{
    DevilController* vc = (DevilController*)[JevilInstance currentInstance].vc;
    WildCardUIView* view = [vc findView:node];
    DevilBlockDrawerMarketComponent* mc = (DevilBlockDrawerMarketComponent*)[MarketInstance findMarketComponent:vc.mainWc.meta replaceView:view];
    [mc naviUpPreview:[WildCardConstructor convertSketchToPixel:offset]];
}

+ (void)drawerCallback:(NSString*)node: (NSString*)command :(JSValue *)callback {
    DevilController* vc = (DevilController*)[JevilInstance currentInstance].vc;
    WildCardUIView* view = [vc findView:node];
    DevilBlockDrawerMarketComponent* mc = (DevilBlockDrawerMarketComponent*)[MarketInstance findMarketComponent:vc.mainWc.meta replaceView:view];
    
    [[JevilFunctionUtil sharedInstance] registFunction:callback];
    [mc callback:command :^(id  _Nonnull res) {
        [[JevilFunctionUtil sharedInstance] callFunction:callback params:@[res]];
    }];
}

+ (void)setTimer:(NSString*)key :(int)milli_sec :(JSValue*)callback {
    [[JevilFunctionUtil sharedInstance] registFunction:callback];
    [NSObject cancelPreviousPerformRequestsWithTarget:[JevilInstance currentInstance] selector:@selector(timerFunction:) object:key];
    
    dispatch_async(dispatch_get_main_queue(), ^{
        [[JevilInstance currentInstance] performSelector:@selector(timerFunction:) withObject:key afterDelay:milli_sec/1000.0f];
        [JevilInstance currentInstance].timerCallback = ^(id  _Nonnull res) {
            [[JevilFunctionUtil sharedInstance] callFunction:callback params:@[]];
        };
    });
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

+ (void)bleWriteDescriptor:(NSDictionary*)param :(JSValue*)callback {
    
}

+ (void)bleReadDescriptor:(NSDictionary*)param :(JSValue*)callback {
    
}

+ (void)fileChooser:(NSDictionary*)param :(JSValue*)callback {
    [[JevilFunctionUtil sharedInstance] registFunction:callback];
    [[DevilFileChooser sharedInstance] fileChooser:[JevilInstance currentInstance].vc param:param callback:^(id  _Nonnull res) {
        if([res[@"r"] boolValue]) {
            [[JevilFunctionUtil sharedInstance] callFunction:callback params:@[res]];
        } else if(res[@"msg"]){
            [Jevil alert:res[@"msg"]];
        }
    }];
}

+ (void)pdfInfo:(NSString*)url :(JSValue*)callback{
    [[JevilFunctionUtil sharedInstance] registFunction:callback];
    [DevilPdf pdfInfo:url callback:^(id  _Nonnull res) {
        [[JevilFunctionUtil sharedInstance] callFunction:callback params:@[res]];
    }];
}

+ (void)pdfToImage:(NSString*)url :(NSDictionary*)param :(JSValue*)callback{
    [[JevilFunctionUtil sharedInstance] registFunction:callback];
    [DevilPdf pdfToImage:url :param callback:^(id  _Nonnull res) {
        [[JevilFunctionUtil sharedInstance] callFunction:callback params:@[res]];
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

+ (void)imageMapFocus:(NSString*)nodeName :(NSString*)pinKey {
    DevilController* vc = (DevilController*)[JevilInstance currentInstance].vc;
    DevilImageMap* map = (DevilImageMap*)[[vc findView:nodeName] subviews][0];
    [map focus:pinKey];
}

+ (void)imageMapConfig:(NSString*)nodeName : (NSDictionary*)param {
    DevilController* vc = (DevilController*)[JevilInstance currentInstance].vc;
    DevilImageMap* map = (DevilImageMap*)[[vc findView:nodeName] subviews][0];
    [map config:param];
}

+ (NSString*)getByte:(NSString*)text {
    return [DevilUtil byteToHex:[text dataUsingEncoding:NSUTF8StringEncoding]];
}

+ (NSString*)getTextFromHex:(NSString*)hex {
    return [DevilUtil safeHexToString:hex];
}

+ (void)configHost:(NSString*)host{
    [WildCardConstructor sharedInstance].project[@"host"] = host;
}

+ (NSString*)getConfigHost {
    return [WildCardConstructor sharedInstance].project[@"host"];
}


+ (void)log:(NSString*)text:(NSDictionary*)log{
    [[DevilDebugView sharedInstance] log:DEVIL_LOG_CUSTOM title:text log:log];
}

+ (NSString*)sha256:(NSString*)text{
    return [DevilUtil sha256:text];
}

+ (NSString*)sha256ToHex:(NSString*)text{
    return [DevilUtil sha256ToHex:text];
}

+ (NSString*)sha256ToHash:(NSString*)text{
    return [DevilUtil sha256ToHash:text];
}

+ (NSString*)sha512ToHash:(NSString*)text{
    return [DevilUtil sha512ToHash:text];
}

+ (void)gaEvent:(NSDictionary*)param{
    if([DevilSdk sharedInstance].devilSdkGADelegate) {
        [[DevilSdk sharedInstance].devilSdkGADelegate onEvent:[WildCardConstructor sharedInstance].project_id eventType:@"custom" viewName:param[@"event"]];
    }
}

+ (BOOL)isScreenOrientationLandscape{
    DevilController* dc = [JevilInstance currentInstance].vc;
    return dc.landscape;
}

+ (BOOL)isTablet{
    return [WildCardUtil isTablet];
}

+ (void)previewProject:(NSString *)project_id :(NSString *)start_screen_id :(NSString *)version {
    NSString* previous_project_id = [WildCardConstructor sharedInstance].project_id;
    [WildCardConstructor sharedInstance:project_id].delegate = [WildCardConstructor sharedInstance:previous_project_id].delegate;
    [WildCardConstructor sharedInstance:project_id].textConvertDelegate = [WildCardConstructor sharedInstance:previous_project_id].textConvertDelegate;
    [WildCardConstructor sharedInstance:project_id].textTransDelegate = [WildCardConstructor sharedInstance:previous_project_id].textTransDelegate;
    
    [DevilSdk start:project_id screenId:start_screen_id controller:[DevilController class] viewController:[JevilInstance currentInstance].vc version:version complete:^(BOOL res) {
        
    }];
}

+ (void)mapCamera:(NSString*)nodeName :(id)param :(JSValue*)callback{
    DevilGoogleMapMarketComponent* mc = [Jevil getDevilGoogleMapMarketComponent:nodeName];
    [mc camera:param];
}
+ (void)mapAddMarker:(NSString*)nodeName :(id)param :(JSValue*)callback{
    DevilGoogleMapMarketComponent* mc = [Jevil getDevilGoogleMapMarketComponent:nodeName];
    [mc addMarker:param];
}
+ (void)mapAddMarkers:(NSString*)nodeName :(id)param :(JSValue*)callback{
    DevilGoogleMapMarketComponent* mc = [Jevil getDevilGoogleMapMarketComponent:nodeName];
    for(id p in param) [mc addMarker:p];
}
+ (void)mapUpdateMarker:(NSString*)nodeName :(id)param :(JSValue*)callback{
    DevilGoogleMapMarketComponent* mc = [Jevil getDevilGoogleMapMarketComponent:nodeName];
    [mc updateMarker:param];
}
+ (void)mapUpdateMarkers:(NSString*)nodeName :(id)param :(JSValue*)callback{
    DevilGoogleMapMarketComponent* mc = [Jevil getDevilGoogleMapMarketComponent:nodeName];
    for(id p in param) [mc updateMarker:p];
}
+ (void)mapRemoveMarker:(NSString*)nodeName :(NSString*)key{
    DevilGoogleMapMarketComponent* mc = [Jevil getDevilGoogleMapMarketComponent:nodeName];
    [mc removeMarker:key];
}
+ (void)mapAddCircle:(NSString*)nodeName :(id)param :(JSValue*)callback{
    DevilGoogleMapMarketComponent* mc = [Jevil getDevilGoogleMapMarketComponent:nodeName];
    [mc addCircle:param];
}
+ (void)mapRemoveCircle:(NSString*)nodeName :(NSString*)key{
    DevilGoogleMapMarketComponent* mc = [Jevil getDevilGoogleMapMarketComponent:nodeName];
    [mc removeCircle:key];
}
+ (void)mapCallback:(NSString*)nodeName :(NSString*)event :(JSValue*)callback{
    DevilGoogleMapMarketComponent* mc = [Jevil getDevilGoogleMapMarketComponent:nodeName];
    
    [[JevilFunctionUtil sharedInstance] registFunction:callback];
    
    if ([event isEqualToString:@"click"]) {
        [mc callbackMarkerClick: ^(id marker) {
            [[JevilFunctionUtil sharedInstance] callFunction:callback params:@[marker]];
        }];
        
    } else if ([event isEqualToString:@"map_click"]) {
        [mc callbackMapClick: ^(id res) {
            [[JevilFunctionUtil sharedInstance] callFunction:callback params:@[res]];
        }];
        
    } else if ([event isEqualToString:@"camera"]) {
        [mc callbackCamera: ^(id res) {
            [[JevilFunctionUtil sharedInstance] callFunction:callback params:@[ res ]];
        }];
        
    } else if ([event isEqualToString:@"drag_start"]) {
        [mc callbackDragStart: ^(id marker) {
            [[JevilFunctionUtil sharedInstance] callFunction:callback params:@[ marker]];
        }];
        
    } else if ([event isEqualToString:@"drag_end"]) {
        [mc callbackDragEnd: ^(id marker) {
            [[JevilFunctionUtil sharedInstance] callFunction:callback params:@[ marker]];
        }];
    }
}

+ (DevilGoogleMapMarketComponent*)getDevilGoogleMapMarketComponent:(NSString*)nodeName {
    DevilController* vc = (DevilController*)[JevilInstance currentInstance].vc;
    MetaAndViewResult* mv = [vc findViewWithMeta:nodeName];
    return (DevilGoogleMapMarketComponent*)[MarketInstance findMarketComponent:mv.meta replaceView:mv.view];
}

+ (BOOL)review {
    return [[DevilReview sharedInstance] review];
}
+ (void)setLanguage:(NSString*)lang{
    [DevilLang setCurrentLang:lang];
}
+ (NSString*)getLanguage{
    return [DevilLang getCurrentLang];
}
+ (NSString*)languageTrans:(NSString*)key {
    return [DevilLang trans:key];
}

+ (void)contactAdd:(id)param {
    [[DevilContact sharedInstance] addContact:param];
}

+ (void)contactList:(NSDictionary*)param :(JSValue *)callback{
    [[JevilFunctionUtil sharedInstance] registFunction:callback];
    [[DevilContact sharedInstance] getContactList:param callback:^(id  _Nonnull res) {
        [[JevilFunctionUtil sharedInstance] callFunction:callback params:@[res]];
    }];
}
+ (void)contactSelect:(NSDictionary*)param :(JSValue *)callback{
    [[JevilFunctionUtil sharedInstance] registFunction:callback];
    [[DevilContact sharedInstance] popupContactSelect:param callback:^(id  _Nonnull res) {
        [[JevilFunctionUtil sharedInstance] callFunction:callback params:@[res]];
    }];
}

+ (void)paintSave:(NSString*)nodeName :(JSValue *)callback {
    [[JevilFunctionUtil sharedInstance] registFunction:callback];
    [((DevilPaintMarketComponent*)[[JevilInstance currentInstance] findMarketComponent:nodeName]) saveImage:^(id  _Nonnull res) {
        [[JevilFunctionUtil sharedInstance] callFunction:callback params:@[res]];
    }];
}

+ (BOOL)paintIsEmpty:(NSString*)nodeName {
    return [((DevilPaintMarketComponent*)[[JevilInstance currentInstance] findMarketComponent:nodeName]) isEmpty];
}

+ (void)paintClear:(NSString*)nodeName {
    [((DevilPaintMarketComponent*)[[JevilInstance currentInstance] findMarketComponent:nodeName]) clear];
}

+ (void)goCropScreen:(NSDictionary*)param :(JSValue *)callback {
    [[JevilFunctionUtil sharedInstance] registFunction:callback];
    DevilImageEditController* d = [[DevilImageEditController alloc] init];
    d.param = param;
    d.callback = ^(id  _Nonnull res) {
        [[JevilFunctionUtil sharedInstance] callFunction:callback params:@[res]];
    };
    [[JevilInstance currentInstance].vc.navigationController pushViewController:d animated:YES];
}

+ (void)gyroscopeStart:(NSDictionary *)param :(JSValue *)callback {
    [[JevilFunctionUtil sharedInstance] registFunction:callback];
    [[DevilGyroscope sharedInstance] startGyroscope:(id)param callback:^(id  _Nonnull res) {
        [[JevilFunctionUtil sharedInstance] callFunction:callback params:@[res]];
    }];
}

+ (void)gyroscopeStop {
    [[DevilGyroscope sharedInstance] stopGyroscope];
}

+ (NSArray *)gyroscopeData:(NSDictionary *)param :(JSValue *)callback {
    return [[DevilGyroscope sharedInstance] getData:param];
}

+ (void)gyroscopeZipData:(NSDictionary *)param :(JSValue *)callback {
    [[JevilFunctionUtil sharedInstance] registFunction:callback];
    [[DevilGyroscope sharedInstance] getZipData:param callback:^(id  _Nonnull res) {
        [[JevilFunctionUtil sharedInstance] callFunction:callback params:@[res]];
    }];
}

+ (void)mqttConnect:(id)param :(JSValue *)callback {
    [[JevilFunctionUtil sharedInstance] registFunction:callback];
    [[DevilMqtt sharedInstance] connect:param callback:^(id  _Nonnull res) {
        [[JevilFunctionUtil sharedInstance] callFunction:callback params:@[res]];
    }];
}

+ (void)mqttSubscribe:(id)param :(JSValue *)callback {
    [[JevilFunctionUtil sharedInstance] registFunction:callback];
    [[DevilMqtt sharedInstance] subscribe:param callback:^(id  _Nonnull res) {
        [[JevilFunctionUtil sharedInstance] callFunction:callback params:@[res]];
    }];
}

+ (void)mqttPublish:(id)param :(JSValue *)callback {
    [[JevilFunctionUtil sharedInstance] registFunction:callback];
    [[DevilMqtt sharedInstance] publish:param callback:^(id  _Nonnull res) {
        [[JevilFunctionUtil sharedInstance] callFunction:callback params:@[res]];
    }];
}

+ (void)mqttListener:(JSValue *)callback {
    [[JevilFunctionUtil sharedInstance] registFunction:callback];
    [[DevilMqtt sharedInstance] listen:^(id  _Nonnull res) {
        [[JevilFunctionUtil sharedInstance] callFunction:callback params:@[res]];
    }];
}

+ (BOOL)mqttIsConnected{
    return [DevilMqtt sharedInstance].connected;
}

+ (void)mqttRelease {
    [[DevilMqtt sharedInstance] close];
}

+ (void)touchListener:(NSString*)node :(JSValue *)callback {
    DevilController* vc = (DevilController*)[JevilInstance currentInstance].vc;
    WildCardUIView* v = [vc findView:node];
    v.multipleTouchEnabled = YES;
    [v addTouchCallback:^(int action, CGPoint p, NSSet *touches) {
        NSString* event = @"";
        if(action == TOUCH_ACTION_DOWN)
            event = @"down";
        else if(action == TOUCH_ACTION_UP)
            event = @"up";
        else if(action == TOUCH_ACTION_MOVE)
            event = @"move";
        else if(action == TOUCH_ACTION_CANCEL)
            event = @"cancel";
        
        
        id list = [@[] mutableCopy];
        for (UITouch *touch in touches) {
            CGPoint p = [touch locationInView:v];
            NSString *touchKey = [NSString stringWithFormat:@"%lx", (long)touch];
            p.x = [WildCardUtil convertPixcelToSketch:p.x];
            p.y = [WildCardUtil convertPixcelToSketch:p.y];
            [list addObject: @{
                @"id": touchKey,
                @"x": [NSNumber numberWithDouble:p.x],
                @"y": [NSNumber numberWithDouble:p.y],
            }];
            if(action != TOUCH_ACTION_MOVE)
                NSLog(@"touches %@ %@ %d (%f,%f)", touchKey, event, (int)[touches count], p.x, p.y);
        }
        
        [[JevilFunctionUtil sharedInstance] callFunction:callback params:@[event, list]];
    }];
}

@end
