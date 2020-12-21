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
    [[JevilCtx sharedInstance].vc.navigationController popViewControllerAnimated:NO];
    [[JevilCtx sharedInstance].vc.navigationController pushViewController:d animated:NO];
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
    NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:[NSURL URLWithString:url]
                                                           cachePolicy:NSURLRequestReloadIgnoringLocalAndRemoteCacheData
                                                       timeoutInterval:10];
    [request setHTTPMethod:@"GET"];
    [NSURLConnection sendAsynchronousRequest:request queue:[NSOperationQueue mainQueue] completionHandler:^(NSURLResponse *response, NSData *data, NSError *error) {
        if ([data length] > 0 && error == nil) {
            [callback callWithArguments:@[[[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding], @YES]];
        } 
    }];
}

+ (void)showIndicator{
    [((DevilController*)[JevilCtx sharedInstance].vc) showIndicator];
}
+ (void)hideIndicator{
    [((DevilController*)[JevilCtx sharedInstance].vc) hideIndicator];
}
@end
