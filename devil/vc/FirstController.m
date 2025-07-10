//
//  FirstController.m
//  CloudJsonViewer
//
//  Created by Mu Young Ko on 2020/11/20.
//  Copyright © 2020 Mu Young Ko. All rights reserved.
//

#import "FirstController.h"
#import "LoginController.h"
#import "Devil.h"
#import <devilcore/devilcore.h>
#import "MainV2Controller.h"
@import devilcore;

@interface FirstController ()

@end

@implementation FirstController

- (void)viewDidLoad {
    [super viewDidLoad];
    [DevilSdk sharedInstance];
    
    [[NSBundle mainBundle] loadNibNamed:@"FirstController" owner:self options:nil];
    [self.navigationController setNavigationBarHidden:YES animated:NO];
    
    [self showIndicator];
    [[WildCardConstructor sharedInstance] initWithOnlineVersion:@"0.0.2" onComplete:^(BOOL success) {
    //[[WildCardConstructor sharedInstance] initWithOnlineOnComplete:^(BOOL success) {
        
        //[WildCardConstructor sharedInstance].project[@"host"] = @"http://192.168.45.205:6111";
        NSString* udid = [[[UIDevice currentDevice] identifierForVendor] UUIDString];
        [[Devil sharedInstance] isLogin:^(id  _Nonnull res) {
            [self hideIndicator];
            if(res){
                if([res[@"r"] boolValue]) {
                    MainV2Controller* v = [[MainV2Controller alloc] init];
                    v.screenId = @"56553391";
                    [self.navigationController setViewControllers:@[v]];
                } else {
                    [self.navigationController setViewControllers:@[[[LoginController alloc] init]]];
                }
            }
        }];
    }];
}


/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

@end
