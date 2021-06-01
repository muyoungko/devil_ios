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
#import "DevilUtil.h"
#import "DevilToast.h"
#import "DevilUtil.h"
#import "WildCardUITextField.h"
#import "DevilSound.h"
#import "DevilSpeech.h"
#import "DevilLocation.h"
#import "DevilWebView.h"
#import "WildCardUITextView.h"
#import "WildCardVideoView.h"

@interface Jevil()


@end

@implementation Jevil

+ (BOOL)isLogin{
    return true;
}

+ (void)go:(NSString*)screenName :(id)param{
    NSString* screenId = [[WildCardConstructor sharedInstance] getScreenIdByName:screenName];
    DevilController* d = [[DevilController alloc] init];
    if(param != nil)
        d.startData = param;
    d.screenId = screenId;
    [[JevilInstance currentInstance].vc.navigationController pushViewController:d animated:YES];
    [[DevilDebugView sharedInstance] log:DEVIL_LOG_SCREEN title:screenName log:param];
}

+ (void)replaceScreen:(NSString*)screenName :(id)param{
    [((DevilController*)[JevilInstance currentInstance].vc) finish];
    NSString* screenId = [[WildCardConstructor sharedInstance] getScreenIdByName:screenName];
    DevilController* d = [[DevilController alloc] init];
    if(param != nil)
        d.startData = param;
    d.screenId = screenId;
    UINavigationController* n = [JevilInstance currentInstance].vc.navigationController;
    [n popViewControllerAnimated:NO];
    [n pushViewController:d animated:NO];
    [[DevilDebugView sharedInstance] log:DEVIL_LOG_SCREEN title:screenName log:param];
}

+ (void)rootScreen:(NSString*)screenName :(id)param{
    NSString* screenId = [[WildCardConstructor sharedInstance] getScreenIdByName:screenName];
    DevilController* d = [[DevilController alloc] init];
    if(param != nil)
        d.startData = param;
    d.screenId = screenId;
    [[JevilInstance currentInstance].vc.navigationController setViewControllers:@[d]];
    [[DevilDebugView sharedInstance] log:DEVIL_LOG_SCREEN title:screenName log:param];
}

+ (void)finish:(id)callbackData {
    if(callbackData){
        [JevilInstance globalInstance].callbackData = callbackData;
    }
    [((DevilController*)[JevilInstance currentInstance].vc) finish];
    [[JevilInstance currentInstance].vc.navigationController popViewControllerAnimated:YES];
}

+ (void)finishThen:(JSValue *)callback {
    [((DevilController*)[JevilInstance currentInstance].vc) finish];
    [JevilInstance globalInstance].callbackFunction = callback;
    [[JevilInstance currentInstance].vc.navigationController popViewControllerAnimated:YES];
}

+ (void)back{
    [Jevil finish:nil];
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
    UIAlertController *alertController = [UIAlertController alertControllerWithTitle:msg
                                                                             message:nil
                                                                      preferredStyle:UIAlertControllerStyleAlert];

    [alertController addAction:[UIAlertAction actionWithTitle:@"확인"
                                                      style:UIAlertActionStyleCancel
                                                    handler:^(UIAlertAction *action) {
                                                        
    }]];
    [[JevilInstance currentInstance].vc presentViewController:alertController animated:YES completion:^{}];
}

+ (void)alertFinish:(NSString*)msg{
    UIAlertController *alertController = [UIAlertController alertControllerWithTitle:msg
                                                                             message:nil
                                                                      preferredStyle:UIAlertControllerStyleAlert];

    [alertController addAction:[UIAlertAction actionWithTitle:@"확인"
                                                      style:UIAlertActionStyleCancel
                                                    handler:^(UIAlertAction *action) {
       [[JevilInstance currentInstance].vc.navigationController popViewControllerAnimated:YES];
    }]];
    [[JevilInstance currentInstance].vc presentViewController:alertController animated:YES completion:^{}];
}

+ (void)confirm:(NSString*)msg :(NSString*)yes :(NSString*)no :(JSValue *)callback {
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

+ (void)alertThen:(NSString*)msg :(JSValue *)callback {
    UIAlertController *alertController = [UIAlertController alertControllerWithTitle:msg
                                                                             message:nil
                                                                      preferredStyle:UIAlertControllerStyleAlert];

    [alertController addAction:[UIAlertAction actionWithTitle:@"확인"
                                                      style:UIAlertActionStyleCancel
                                                    handler:^(UIAlertAction *action) {
        [callback callWithArguments:@[]];
        [[JevilInstance currentInstance] syncData];
                                                        
    }]];
    [[JevilInstance currentInstance].vc presentViewController:alertController animated:YES completion:^{}];
}

+ (void)save:(NSString *)key :(NSString *)value{
    key = [NSString stringWithFormat:@"%@_%@", key, [WildCardConstructor sharedInstance].project_id];
    
    [[NSUserDefaults standardUserDefaults] setObject:value forKey:key];
    [[NSUserDefaults standardUserDefaults] synchronize];
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

+ (void)get:(NSString *)url then:(JSValue *)callback {
    NSString* originalUrl = url;
    if([url hasPrefix:@"/"])
        url = [NSString stringWithFormat:@"%@%@", [WildCardConstructor sharedInstance].project[@"host"], url];

    id header = [@{} mutableCopy];
    id header_list = [WildCardConstructor sharedInstance].project[@"header_list"];
    for(id h in header_list){
        header[h[@"header"]] = h[@"content"];
    }
    
    NSString* x_access_token_key = [NSString stringWithFormat:@"x-access-token"];
    if([Jevil get:x_access_token_key])
        header[@"x-access-token"] = [Jevil get:x_access_token_key];
    
    [[DevilDebugView sharedInstance] log:DEVIL_LOG_REQUEST title:originalUrl log:nil];
    [[WildCardConstructor sharedInstance].delegate onNetworkRequestGet:url header:header success:^(NSMutableDictionary *responseJsonObject) {
        [[DevilDebugView sharedInstance] log:DEVIL_LOG_RESPONSE title:originalUrl log:responseJsonObject];
        if(!responseJsonObject)
            responseJsonObject = [@{} mutableCopy];
        [callback callWithArguments:@[responseJsonObject]];
        [[JevilInstance currentInstance] syncData];
    }];
}

+ (void)post:(NSString *)url :(id)param then:(JSValue *)callback {

    NSString* originalUrl = url;
    if([url hasPrefix:@"/"])
        url = [NSString stringWithFormat:@"%@%@", [WildCardConstructor sharedInstance].project[@"host"], url];

    id header = [@{} mutableCopy];
    id header_list = [WildCardConstructor sharedInstance].project[@"header_list"];
    for(id h in header_list){
        header[h[@"header"]] = h[@"content"];
    }
    
    NSString* x_access_token_key = [NSString stringWithFormat:@"x-access-token"];
    if([Jevil get:x_access_token_key])
        header[@"x-access-token"] = [Jevil get:x_access_token_key];
    
    [[DevilDebugView sharedInstance] log:DEVIL_LOG_REQUEST title:originalUrl log:param];
    [[WildCardConstructor sharedInstance].delegate onNetworkRequestPost:url header:header json:param success:^(NSMutableDictionary *responseJsonObject) {
        [[DevilDebugView sharedInstance] log:DEVIL_LOG_RESPONSE title:originalUrl log:responseJsonObject];
        
        if(!responseJsonObject)
            responseJsonObject = [@{} mutableCopy];
        [callback callWithArguments:@[responseJsonObject]];
        [[JevilInstance currentInstance] syncData];
    }];
}

+ (void)uploadS3:(NSArray*)paths :(JSValue *)callback{
    if([paths count] == 0) {
        [callback callWithArguments:@[@{@"r":@TRUE, @"uploadedFile":@[]}]];
        return;
    }
    
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
    for(int i=0;i<[paths count];i++){
        __block NSString* path = paths[i];
        id ss = [path componentsSeparatedByString:@"."];
        NSString* ext = ss[[ss count]-1];
        NSString* url = [NSString stringWithFormat:@"%@/api/media/url/put/%@", [WildCardConstructor sharedInstance].project[@"host"], ext];
        [uploadedFile addObject:path];
        [uploadedFileSuccess addObject:@FALSE];
        __block int thisIndex = i;
        [[WildCardConstructor sharedInstance].delegate onNetworkRequestGet:url header:header success:^(NSMutableDictionary *upload) {
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
                [DevilUtil httpPut:upload_url contentType:contentType data:data complete:^(id  _Nonnull res) {
                    s3index++;
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
                        [callback callWithArguments:@[result]];
                        [[JevilInstance currentInstance] syncData];
                    }
                }];
            }
        }];
    }
    
}

+ (void)sendPushKeyWithDevilServer {
    NSString* fcm = [[NSUserDefaults standardUserDefaults] objectForKey:@"FCM"];
    if(fcm == nil)
        return;
    
    UIDevice *device = [UIDevice currentDevice];
    NSString* udid = [[device identifierForVendor] UUIDString];
    NSString* url = [NSString stringWithFormat:@"/push/key?fcm=%@&udid=%@&os=iOS", urlencode(fcm), urlencode(udid)];
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
    if(vc != nil && 
        ([[vc class] isKindOfClass:[DevilController class]] || [[vc class] isEqual:[DevilController class]]))
        {
        [((DevilController*)vc) updateMeta];
    }
}

+ (void)focus:(NSString*)nodeName {
    id meta = [JevilInstance currentInstance].meta;
    WildCardUITextField* tf = (WildCardUITextField*)[meta getTextView:nodeName];
    [tf becomeFirstResponder];
}

+ (void)hideKeyboard {
    [[JevilInstance currentInstance].vc.view endEditing:YES];
}

+ (void)scrollTo:(NSString*)nodeName :(int)index {
    UICollectionView* list;
    if(nodeName && ![@"null" isEqualToString:nodeName] ) {
        id meta = [JevilInstance currentInstance].meta;
        list = [[meta getView:nodeName] subviews][0];
        [list scrollToItemAtIndexPath:[NSIndexPath indexPathWithIndex:index] atScrollPosition:UICollectionViewScrollPositionCenteredVertically animated:YES];
    } else {
        DevilController* vc = (DevilController*)[JevilInstance currentInstance].vc;
        if(vc.tv != nil)
            [vc.tv scrollToRowAtIndexPath:[NSIndexPath indexPathForRow:index inSection:0] atScrollPosition:UITableViewScrollPositionMiddle animated:YES];
    }
    
}

+ (void)scrollUp:(NSString*)nodeName {
    if(nodeName && ![@"null" isEqualToString:nodeName]) {
        id meta = [JevilInstance currentInstance].meta;
        UICollectionView* list = [[meta getView:nodeName] subviews][0];
        [list scrollsToTop];
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

+ (void)tab:(NSString*)screenName{
    UIViewController*vc = [JevilInstance currentInstance].vc;
    id meta = [JevilInstance currentInstance].meta;
    [JevilAction act:@"Jevil.tab" args:@[screenName] viewController:vc meta:meta];
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

+ (BOOL)wifiIsOn {
    return YES;
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

+ (void)camera:(NSDictionary*)param :(JSValue *)callback {
    [DevilCamera camera:[JevilInstance currentInstance].vc param:param callback:^(id  _Nonnull res) {
        [callback callWithArguments:@[res]];
        [[JevilInstance currentInstance] syncData];
    }];
}

+ (void)share:(NSString*)url{
    NSArray *activityItems = @[[NSURL URLWithString:url]];
    UIActivityViewController *activityViewControntroller = [[UIActivityViewController alloc] initWithActivityItems:activityItems applicationActivities:nil];
    activityViewControntroller.excludedActivityTypes = @[];
    [[JevilInstance currentInstance].vc presentViewController:activityViewControntroller animated:true completion:nil];
}

+ (void)out:(NSString*)url{
    [[UIApplication sharedApplication] openURL:[NSURL URLWithString: url] options:@{} completionHandler:^(BOOL success) {
        
    }];
}

+ (void)sound:(NSDictionary*)param{
    @try {
        [[DevilSound sharedInstance] sound:param];
    } @catch (NSException *exception) {
        //TODO
    }
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
+ (void)soundSpeed:(NSString*)speed{
    [[DevilSound sharedInstance] speed:[speed floatValue]];
}
+ (void)speechRecognizer:(NSDictionary*)param :(JSValue*)callback{
    [[DevilSpeech sharedInstance] listen:param :^(id  _Nonnull text) {
        [callback callWithArguments:@[ text ]];
    }];
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
            JSValue* r = [callback callWithArguments:@[url]];
            return [r toBool];
        };
    }
}

+ (void)scrollDragged:(NSString*)node :(JSValue *)callback {
    DevilController* vc = (DevilController*)[JevilInstance currentInstance].vc;
    if(vc.mainWc != nil) {
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
    DevilController* vc = (DevilController*)[JevilInstance currentInstance].vc;
    if(vc.mainWc != nil) {
        WildCardUIView* vv = (WildCardUIView*)[vc.mainWc.meta getView:node];
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
            //TODO
        }
    }
}

+ (void)textFocusChanged:(NSString*)node :(JSValue *)callback {
    DevilController* vc = (DevilController*)[JevilInstance currentInstance].vc;
    if(vc.mainWc != nil) {
        WildCardUIView* vv = (WildCardUIView*)[vc.mainWc.meta getView:node];
        id o = [vv subviews][0];
        if([o isMemberOfClass:[WildCardUITextField class]]) {
            WildCardUITextField* c = o;
            c.textFocusChangedCallback = ^(BOOL focus) {
                [JevilInstance currentInstance].meta = vc.mainWc.meta;
                [[JevilInstance currentInstance] pushData];
                [callback callWithArguments:@[(focus?@TRUE:@FALSE)]];
            };
        } else {
            WildCardUITextView* c = o;
            //TODO
        }
    }
}

+ (void)videoViewAutoPlay {
    [[JevilInstance currentInstance] performSelector:@selector(videoViewAutoPlay) withObject:nil afterDelay:0.001f];
}

+ (void)isWifi:(JSValue *)callback {
    [callback callWithArguments:@[@TRUE]];
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
    [[DevilLocation sharedInstance] search:param[@"keyword"] :^(id  _Nonnull result) {
        [callback callWithArguments:@[ result ]];
    }];
}


@end
