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

- (void)sort{
    if(self.data[@"list"]){
        self.data[@"list"] = [self.data[@"list"] sortedArrayUsingComparator:^NSComparisonResult(id a, id b) {
            return [b[@"lastClick"] doubleValue] - [a[@"lastClick"] doubleValue];
        }];
    }
}

- (void)viewDidAppear:(BOOL)animated{
    [super viewDidAppear:animated];
    [self sort];
    if(self.mainWc)
        [self reloadBlock];
    
    [[Devil sharedInstance] consumeReservedUrl];
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
        
        for(int i=(int)[self.data[@"list"] count]-1;i>=0;i--) {
            id p = self.data[@"list"][i];
            NSString* lastProjectKey = [NSString stringWithFormat:@"%@_LAST", p[@"id"]];
            NSNumber* lastClick = [[NSUserDefaults standardUserDefaults] objectForKey:lastProjectKey];
            
            if(!lastClick){
                NSTimeInterval timeStamp = [[NSDate date] timeIntervalSince1970];
                NSNumber* now = [NSNumber numberWithDouble: timeStamp];
                [[NSUserDefaults standardUserDefaults] setObject:now forKey:lastProjectKey];
            }
            
            p[@"lastClick"] = lastClick;
        }
        
        [self sort];
        
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
    NSTimeInterval timeStamp = [[NSDate date] timeIntervalSince1970];
    NSNumber* now = [NSNumber numberWithDouble: timeStamp];
    NSString* lastProjectKey = [NSString stringWithFormat:@"%@_LAST", project_id];
    [[NSUserDefaults standardUserDefaults] setObject:now forKey:lastProjectKey];
    
    [[NSUserDefaults standardUserDefaults] synchronize];
    [DevilSdk start:project_id viewController:self complete:^(BOOL res) {
        
        NSString* hostKey = [NSString stringWithFormat:@"%@_HOST", project_id];
        NSString* webHostKey = [NSString stringWithFormat:@"%@_WEB_HOST", project_id];
        NSString *savedHost = [[NSUserDefaults standardUserDefaults] objectForKey:hostKey];
        if(savedHost)
            [WildCardConstructor sharedInstance:project_id].project[@"host"] = savedHost;
        
        NSString *savedWebHost = [[NSUserDefaults standardUserDefaults] objectForKey:webHostKey];
        if(savedWebHost)
            [WildCardConstructor sharedInstance:project_id].project[@"web_host"] = savedWebHost;
        
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
        NSString* url = [NSString stringWithFormat:@"https://console-api.deavil.com/api/project/%@", project_id];
        [[WildCardConstructor sharedInstance].delegate onNetworkRequest:url success:^(NSMutableDictionary* res) {
            [self hideIndicator];
            if(res != nil)
            {
                id list = res[@"project"][@"dev_host_list"];
                list = [list mutableCopy];
                [list insertObject:@{@"host": res[@"project"][@"host"]}atIndex:0];
                
                NSString* hostKey = [NSString stringWithFormat:@"%@_HOST", project_id];
                NSString* webHostKey = [NSString stringWithFormat:@"%@_WEB_HOST", project_id];
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
                [d popupSelect:list param:param onselect:^(id  _Nonnull host) {
                    for(id m in list) {
                        if([m[@"host"] isEqualToString:host]) {
                            [[NSUserDefaults standardUserDefaults] setObject:host forKey:hostKey];
                            [[NSUserDefaults standardUserDefaults] setObject:m[@"web_host"] forKey:webHostKey];
                        }
                    }
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
