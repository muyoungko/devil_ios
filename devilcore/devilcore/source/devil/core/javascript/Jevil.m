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
    [[JevilInstance currentInstance].vc.navigationController popViewControllerAnimated:YES];
}

+ (void)finishThen:(JSValue *)callback {
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

+ (void)alert:(NSString*)msg{
    UIAlertController *alertController = [UIAlertController alertControllerWithTitle:msg
                                                                             message:nil
                                                                      preferredStyle:UIAlertControllerStyleAlert];

    [alertController addAction:[UIAlertAction actionWithTitle:@"Ok"
                                                      style:UIAlertActionStyleCancel
                                                    handler:^(UIAlertAction *action) {
                                                        
    }]];
    [[JevilInstance currentInstance].vc presentViewController:alertController animated:YES completion:^{}];
}

+ (void)alertFinish:(NSString*)msg{
    UIAlertController *alertController = [UIAlertController alertControllerWithTitle:msg
                                                                             message:nil
                                                                      preferredStyle:UIAlertControllerStyleAlert];

    [alertController addAction:[UIAlertAction actionWithTitle:@"Ok"
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
    [[NSUserDefaults standardUserDefaults] setObject:value forKey:key];
    [[NSUserDefaults standardUserDefaults] synchronize];
}
+ (void)remove:(NSString *)key{
    [[NSUserDefaults standardUserDefaults] removeObjectForKey:key];
    [[NSUserDefaults standardUserDefaults] synchronize];
}
+ (NSString*)get:(NSString *)key{
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
    [[DevilDebugView sharedInstance] log:DEVIL_LOG_REQUEST title:originalUrl log:nil];
    [[WildCardConstructor sharedInstance].delegate onNetworkRequestGet:url header:header success:^(NSMutableDictionary *responseJsonObject) {
        [[DevilDebugView sharedInstance] log:DEVIL_LOG_RESPONSE title:originalUrl log:responseJsonObject];
        [callback callWithArguments:@[responseJsonObject, @YES]];
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

    [[DevilDebugView sharedInstance] log:DEVIL_LOG_REQUEST title:originalUrl log:param];
    [[WildCardConstructor sharedInstance].delegate onNetworkRequestPost:url header:header json:param success:^(NSMutableDictionary *responseJsonObject) {
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
    if(vc != nil && 
        ([[vc class] isKindOfClass:[DevilController class]] || [[vc class] isEqual:[DevilController class]]))
        {
        [((DevilController*)vc) updateMeta];
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
    
    [[JevilInstance currentInstance] syncData];
    UIViewController*vc = [JevilInstance currentInstance].vc;
    id meta = [JevilInstance currentInstance].meta;
    DevilBlockDialog* d = [DevilBlockDialog popup:blockName data:[JevilInstance currentInstance].data title:title yes:yes no:no onselect:^(BOOL yes) {
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

+ (void)popupSelect:(NSArray*)array :(NSString*)selectedKey :(JSValue *)callback {
    UIViewController*vc = [JevilInstance currentInstance].vc;
    DevilSelectDialog* d = [[DevilSelectDialog alloc] initWithViewController:vc];
    id list = [array mutableCopy];
    [d popupSelect:list selectedKey:selectedKey onselect:^(id  _Nonnull res) {
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

@end
