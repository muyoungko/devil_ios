//
//  JevilNfc.m
//  devilnfc
//
//  Created by Mu Young Ko on 2022/09/23.
//

#import "JevilNfc.h"
#import "DevilNfcInstance.h"

@import devilcore;

@implementation JevilNfc

+ (void)start:(NSDictionary*)param :(JSValue*)callback {
    [[JevilFunctionUtil sharedInstance] registFunction:callback];
    [[DevilNfcInstance sharedInstance] start:param :^id _Nonnull(id  _Nonnull res) {
        @try {
            JSValue* value = [callback callWithArguments:@[res]];
            return [value toDictionary];
        } @catch(NSException* e) {
            [JevilNfc handle:e];
        }
    }];
}

+ (void)stop {
    [[DevilNfcInstance sharedInstance] stop];
}

+(void)handle:(NSException*)e{
    UIViewController* vc = [JevilInstance currentInstance].vc;
    UIAlertController *alertController = [UIAlertController alertControllerWithTitle:e.name
                                                                             message:e.reason
                                                                      preferredStyle:UIAlertControllerStyleAlert];

    [alertController addAction:[UIAlertAction actionWithTitle:@"OK"
                                                      style:UIAlertActionStyleCancel
                                                    handler:^(UIAlertAction *action) {
                                                        
    }]];
    [vc presentViewController:alertController animated:YES completion:^{}];
}

@end
