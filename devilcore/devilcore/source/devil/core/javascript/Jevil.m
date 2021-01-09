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

@interface Jevil()

@property (nonatomic) NSString *name;
@property (nonatomic) NSString *phone;
@property (nonatomic) NSString *address;

+ (BOOL)isValidNumber:(NSString *)phone;

@end

@implementation Jevil


- (NSString *)description
{
    return [NSString stringWithFormat:@"%@ <%@, %@>", self.name, self.phone, self.address];
}

+ (instancetype)contactWithName:(NSString *)name phone:(NSString *)phone address:(NSString *)address
{
    if ([self isValidNumber:phone]) {
        Jevil *contact = [Jevil new];
        contact.name = name;
        contact.phone = phone;
        contact.address = address;
        return contact;
    } else {
        NSLog(@"Phone number %@ doesn't match format", phone);
        return nil;
    }
}

+ (BOOL)isLogin{
    return true;
}

+ (void)go:(NSString*)screenName {
    NSString* screenId = [[WildCardConstructor sharedInstance] getScreenIdByName:screenName];
    DevilController* d = [[DevilController alloc] init];
    d.screenId = screenId;
    [[JevilCtx sharedInstance].vc.navigationController pushViewController:d animated:YES];
}

+ (void)go:(NSString*)screenName :(NSString*)dataString{
    NSString* screenId = [[WildCardConstructor sharedInstance] getScreenIdByName:screenName];
    DevilController* d = [[DevilController alloc] init];
    if(![@"undefined" isEqualToString: dataString])
        d.dataString = dataString;
    d.screenId = screenId;
    [[JevilCtx sharedInstance].vc.navigationController pushViewController:d animated:YES];
}

+ (void)replaceScreen:(NSString*)screenName{
    NSString* screenId = [[WildCardConstructor sharedInstance] getScreenIdByName:screenName];
    DevilController* d = [[DevilController alloc] init];
    d.screenId = screenId;
    UINavigationController* n = [JevilCtx sharedInstance].vc.navigationController;
    [n popViewControllerAnimated:NO];
    [n pushViewController:d animated:NO];
}

+ (void)rootScreen:(NSString*)screenName{
    NSString* screenId = [[WildCardConstructor sharedInstance] getScreenIdByName:screenName];
    DevilController* d = [[DevilController alloc] init];
    d.screenId = screenId;
    [[JevilCtx sharedInstance].vc.navigationController setViewControllers:@[d]];
}

+ (void)finish{
    [[JevilCtx sharedInstance].vc.navigationController popViewControllerAnimated:YES];
}

+ (void)back{
    [Jevil finish];
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
    [[JevilCtx sharedInstance].vc presentViewController:alertController animated:YES completion:^{}];
}

+ (void)alertFinish:(NSString*)msg{
    UIAlertController *alertController = [UIAlertController alertControllerWithTitle:msg
                                                                             message:nil
                                                                      preferredStyle:UIAlertControllerStyleAlert];

    [alertController addAction:[UIAlertAction actionWithTitle:@"Ok"
                                                      style:UIAlertActionStyleCancel
                                                    handler:^(UIAlertAction *action) {
       [[JevilCtx sharedInstance].vc.navigationController popViewControllerAnimated:YES];
    }]];
    [[JevilCtx sharedInstance].vc presentViewController:alertController animated:YES completion:^{}];
}

+ (void)confirm:(NSString*)msg :(NSString*)yes :(NSString*)no :(JSValue *)callback {
    UIAlertController *alertController = [UIAlertController alertControllerWithTitle:nil
                                                                             message:msg
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
    [[JevilCtx sharedInstance].vc presentViewController:alertController animated:YES completion:^{}];
}

+ (void)alertFunction:(NSString*)msg :(JSValue *)callback {
    UIAlertController *alertController = [UIAlertController alertControllerWithTitle:msg
                                                                             message:nil
                                                                      preferredStyle:UIAlertControllerStyleAlert];

    [alertController addAction:[UIAlertAction actionWithTitle:@"확인"
                                                      style:UIAlertActionStyleCancel
                                                    handler:^(UIAlertAction *action) {
                                                    [callback callWithArguments:@[]];
                                                        
    }]];
    [[JevilCtx sharedInstance].vc presentViewController:alertController animated:YES completion:^{}];
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

    if([url hasPrefix:@"/"])
        url = [NSString stringWithFormat:@"%@%@", [WildCardConstructor sharedInstance].project[@"host"], url];

    id header = [@{} mutableCopy];
    id header_list = [WildCardConstructor sharedInstance].project[@"header_list"];
    for(id h in header_list){
        header[h[@"header"]] = h[@"content"];
    }

    [[WildCardConstructor sharedInstance].delegate onNetworkRequestGet:url header:header success:^(NSMutableDictionary *responseJsonObject) {
        [callback callWithArguments:@[responseJsonObject, @YES]];
    }];
}

+ (void)post:(NSString *)url :(NSString*)param then:(JSValue *)callback {

    if([url hasPrefix:@"/"])
        url = [NSString stringWithFormat:@"%@%@", [WildCardConstructor sharedInstance].project[@"host"], url];

    id header = [@{} mutableCopy];
    id header_list = [WildCardConstructor sharedInstance].project[@"header_list"];
    for(id h in header_list){
        header[h[@"header"]] = h[@"content"];
    }

    id json = [NSJSONSerialization JSONObjectWithData:[param dataUsingEncoding:NSUTF8StringEncoding] options:nil error:nil];
    [[WildCardConstructor sharedInstance].delegate onNetworkRequestPost:url header:header json:json success:^(NSMutableDictionary *responseJsonObject) {
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
    
    JSValue* dataJs = [[JevilCtx sharedInstance].currentJscontext evaluateScript:@"data"];
    id newData = [dataJs toDictionary];
    id allKey = [newData allKeys];
    for(id k in allKey) {
        [JevilCtx sharedInstance].data[k] = newData[k];
    }
    
    UIViewController*vc = [JevilCtx sharedInstance].vc;
    if(vc != nil && 
        ([[vc class] isKindOfClass:[DevilController class]] || [[vc class] isEqual:[DevilController class]]))
        {
        [((DevilController*)vc) updateMeta];
    }
}

+ (void)tab:(NSString*)screenName{
    UIViewController*vc = [JevilCtx sharedInstance].vc;
    id meta = [JevilCtx sharedInstance].meta;
    [JevilAction act:@"Jevil.tab" args:@[screenName] viewController:vc meta:meta];
}

+ (void)popup:(NSString*)screenName{
    UIViewController*vc = [JevilCtx sharedInstance].vc;
    id meta = [JevilCtx sharedInstance].meta;
    [JevilAction act:@"Jevil.popup" args:@[screenName] viewController:vc meta:meta];
}

+ (void)popupSelect:(NSString *)arrayString :(NSString*)selectedKey :(JSValue *)callback {
    UIViewController*vc = [JevilCtx sharedInstance].vc;
    DevilSelectDialog* d = [[DevilSelectDialog alloc] initWithViewController:vc];
    id list = [NSJSONSerialization JSONObjectWithData:[arrayString dataUsingEncoding:NSUTF8StringEncoding] options:nil error:nil];
    [d popupSelect:list selectedKey:selectedKey onselect:^(id  _Nonnull res) {
        [callback callWithArguments:@[res]];
    }];
    
    [JevilCtx sharedInstance].devilSelectDialog = d;
}
@end
