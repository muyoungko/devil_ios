//
//  FirstController.m
//  CloudJsonViewer
//
//  Created by Mu Young Ko on 2020/11/20.
//  Copyright © 2020 Mu Young Ko. All rights reserved.
//

#import "FirstController.h"
#import "MainController.h"
#import "LoginController.h"
#import "Devil.h"
#import <devilcore/devilcore.h>

@interface FirstController ()

@end

@implementation FirstController

- (void)viewDidLoad {
    [super viewDidLoad];
    [DevilSdk sharedInstance];
    
    [[NSBundle mainBundle] loadNibNamed:@"FirstController" owner:self options:nil];
    [self.navigationController setNavigationBarHidden:YES animated:NO];
    
    [self showIndicator];
    [[WildCardConstructor sharedInstance] initWithOnline:@"1605234988599" onComplete:^(BOOL success) {
        [[Devil sharedInstance] isLogin:^(id  _Nonnull res) {
            [self hideIndicator];
            if(res){
                if([res[@"r"] boolValue]){
                    [self.navigationController setViewControllers:@[[[MainController alloc] init]]];
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
