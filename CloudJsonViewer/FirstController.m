//
//  FirstViewController.m
//  CloudJsonViewer
//
//  Created by Mu Young Ko on 2018. 6. 18..
//  Copyright © 2018년 Mu Young Ko. All rights reserved.
//

#import "FirstController.h"
#import <AFNetworking/AFNetworking.h>
#import "WildCardConstructor.h"
#import "Devil.h"
#import "MainController.h"
#import "LoginController.h"

@interface FirstController ()

@end

@implementation FirstController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    [[WildCardConstructor sharedInstance] initWithOnline:@"devil" onComplete:^(BOOL success) {
        [[Devil sharedInstance] request:@"/member/islogin" postParam:nil complete:^(id  _Nonnull res) {
            if(res){
                if([res[@"r"] boolValue]){
                    [self.navigationController setViewControllers: @[[[MainController alloc] init]] ];
                } else {
                    [self.navigationController setViewControllers: @[[[LoginController alloc] init]] ];
                }
            } else {
                [self showAlertWithFinish:@"Network is not available"];
            }
        }];
    }];
}



@end
