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
#import <devil-Swift.h>
#import <devillogin/devillogin-Swift.h>

@import devilcore;

@class Test;
@class DevilKakaoLogin;

@interface MainController()

@end
@implementation MainController

- (void)viewDidLoad {
    [super viewDidLoad];
    [self showNavigationBar];
    self.title = trans(@"프로젝트 목록");
    
    [self constructRightBackButton:@"refresh.png"];
    
    [self update];
    
    [[Devil sharedInstance] sendPush];
    
    Test* t = [[Test alloc] init];
    [t run];
    
}

- (void)locationManagerDidChangeAuthorization:(CLLocationManager *)manager{
    NSLog(@"locationManagerDidChangeAuthorization");
}

- (void)viewWillAppear:(BOOL)animated{
    [super viewWillAppear:animated];
    [self showNavigationBar];
    [self.navigationController.navigationBar setBarTintColor:UIColorFromRGB(0xffffff)];
    [WildCardConstructor sharedInstance:@"1605234988599"];
}


- (void)viewDidAppear:(BOOL)animated{
    [super viewDidAppear:animated];
}


- (void)showNavigationBar{
    [self.navigationController setNavigationBarHidden:NO animated:NO];
}

- (void)rightClick:(id)sender{
    [self update];
}

-(void)update{
    [self showIndicator];
    [[Devil sharedInstance] request:@"/front/api/project" postParam:nil complete:^(id  _Nonnull res) {
       [self hideIndicator];
       self.data[@"list"] = res[@"list"];
        if(self.mainWc)
            [self reloadBlock];
        else {
            [self constructBlockUnder:@"1605324337776"];
        }
    }];
}

-(void)startProject:(NSString*) project_id{
    
    AppDelegate* appDelegate = (AppDelegate*)[UIApplication sharedApplication].delegate;
    [WildCardConstructor sharedInstance:project_id].delegate = appDelegate;
    [WildCardConstructor sharedInstance:project_id].textConvertDelegate = appDelegate;
    [WildCardConstructor sharedInstance:project_id].textTransDelegate = appDelegate;
    [DevilSdk start:project_id viewController:self complete:^(BOOL res) {
        
        NSString* hostKey = [NSString stringWithFormat:@"%@_HOST", project_id];
        NSString *selectedKey = [[NSUserDefaults standardUserDefaults] objectForKey:hostKey];
        if(selectedKey) {
            [WildCardConstructor sharedInstance:project_id].project[@"host"] = selectedKey;
        }
        
        [self hideIndicator];
    }];
}
-(BOOL)onInstanceCustomAction:(WildCardMeta *)meta function:(NSString*)functionName args:(NSArray*)args view:(WildCardUIView*) node{
    if([functionName isEqualToString:@"start"]){
        [self showIndicator];
        NSString* project_id = [NSString stringWithFormat:@"%@", meta.correspondData[@"id"]];
        [self startProject:project_id];
        return true;
    } else if([functionName isEqualToString:@"more"]){
        
        NSString *project_id = [meta.correspondData[@"id"] stringValue];
        
        [self showIndicator];
        NSString* path = [NSString stringWithFormat:@"https://console-api.deavil.com/api/project/%@", project_id];
        NSString* url = [NSString stringWithFormat:path, project_id];
        [[WildCardConstructor sharedInstance].delegate onNetworkRequest:url success:^(NSMutableDictionary* res) {
            [self hideIndicator];
            if(res != nil)
            {
                id list = res[@"project"][@"dev_host_list"];
                list = [list mutableCopy];
                [list insertObject:@{@"host": res[@"project"][@"host"]}atIndex:0];
                
                NSString* hostKey = [NSString stringWithFormat:@"%@_HOST", project_id];
                NSString *selectedKey = [[NSUserDefaults standardUserDefaults] objectForKey:hostKey];
                
                id param = [@{@"key":@"host",
                               @"value":@"host",
                               @"view": node,
                               @"show": @"point",
                               @"w" : @250,
                               @"title" : @"Host Select"
                } mutableCopy];
                
                if(selectedKey){
                    param[@"selectedKey"] = selectedKey;
                }
                
                DevilSelectDialog* d = [[DevilSelectDialog alloc] initWithViewController:self];
                [d popupSelect:list param:param onselect:^(id  _Nonnull res) {
                    [[NSUserDefaults standardUserDefaults] setObject:res forKey:hostKey];
                    [[NSUserDefaults standardUserDefaults] synchronize];
                    [self startProject:project_id];
                }];
            }
        }];
        
        return true;
    }
    else 
        return [super onInstanceCustomAction:meta function:functionName args:args view:node];
}
@end
