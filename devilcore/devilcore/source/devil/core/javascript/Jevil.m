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

+ (void)go:(NSString*)screenName{
    NSString* screenId = [[WildCardConstructor sharedInstance] getScreenIdByName:screenName];
    DevilController* d = [[DevilController alloc] init];
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


+ (void)get:(NSString *)url then:(JSValue *)callback {

    if([url hasPrefix:@"/"])
        url = [NSString stringWithFormat:@"%@%@", [WildCardConstructor sharedInstance].project[@"host"], url];

    id header = [@{} mutableCopy];
    id header_list = [WildCardConstructor sharedInstance].project[@"header_list"];
    for(id h in header_list){
        header[h[@"header"]] = h[@"content"];
    }

    [[WildCardConstructor sharedInstance].delegate onNetworkRequestGet:url header:header success:^(NSMutableDictionary *responseJsonObject) {
        NSError *error;
        NSData *jsonData = [NSJSONSerialization dataWithJSONObject:responseJsonObject
                                                           options:NSJSONWritingPrettyPrinted 
                                                             error:&error];
        NSString *jsonString = [[NSString alloc] initWithData:jsonData encoding:NSUTF8StringEncoding]; 
        [callback callWithArguments:@[jsonString, @YES]];
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
        NSError *error;
        NSData *jsonData = [NSJSONSerialization dataWithJSONObject:responseJsonObject
                                                           options:NSJSONWritingPrettyPrinted 
                                                             error:&error];
        NSString *jsonString = [[NSString alloc] initWithData:jsonData encoding:NSUTF8StringEncoding]; 
        [callback callWithArguments:@[jsonString, @YES]];
    }];
}

+ (void)startLoading{
    if([WildCardConstructor sharedInstance].loadingDelegate)
        [[WildCardConstructor sharedInstance].loadingDelegate stopLoading];
}
+ (void)stopLoading{
    if([WildCardConstructor sharedInstance].loadingDelegate)
        [[WildCardConstructor sharedInstance].loadingDelegate startLoading];
}

+ (void)update{
    UIViewController*vc = [JevilCtx sharedInstance].vc;
    if(vc != nil && [[vc class] isKindOfClass:[DevilController class]]){
        [((DevilController*)vc) updateMeta];
    }
}
@end
