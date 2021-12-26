//
//  ExceptionHandler.m
//  devilcore
//
//  Created by Mu Young Ko on 2020/12/21.
//

#import "DevilExceptionHandler.h"
#import "JevilInstance.h"
@implementation DevilExceptionHandler
+(void)handle:(UIViewController*)vc data:(id)data e:(NSException*)e{
    UIAlertController *alertController = [UIAlertController alertControllerWithTitle:e.name
                                                                             message:e.reason
                                                                      preferredStyle:UIAlertControllerStyleAlert];

    [alertController addAction:[UIAlertAction actionWithTitle:@"OK"
                                                      style:UIAlertActionStyleCancel
                                                    handler:^(UIAlertAction *action) {
                                                        
    }]];
    [vc presentViewController:alertController animated:YES completion:^{}];
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
