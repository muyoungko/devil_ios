//
//  MainController.m
//  CloudJsonViewer
//
//  Created by Mu Young Ko on 2020/11/13.
//  Copyright © 2020 Mu Young Ko. All rights reserved.
//

#import "MainController.h"
#import "Devil.h"
#import "Lang.h"

@implementation MainController

- (void)viewDidLoad {
    [super viewDidLoad];
    [self showNavigationBar];
    self.title = trans(@"프로젝트 목록");
    
    [self showIndicator];
    [[Devil sharedInstance] request:@"/front/api/project" postParam:nil complete:^(id  _Nonnull res) {
       [self hideIndicator];
       self.data[@"list"] = res[@"list"];
       [self constructBlockUnder:@"1605324337776"]; 
    }];
}

@end
