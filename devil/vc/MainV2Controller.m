//
//  MainV2Controller.m
//  devil
//
//  Created by Mu Young Ko on 2022/01/09.
//  Copyright © 2022 Mu Young Ko. All rights reserved.
//

#import "MainV2Controller.h"
#import "AppDelegate.h"
#import "Devil.h"

@interface MainV2Controller ()

@end

@implementation MainV2Controller

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
}

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

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
        
        NSString *project_id = [meta.correspondData[@"id"] toString];
        
        [self showIndicator];
        NSString* url = [NSString stringWithFormat:@"https://console-api.deavil.com/api/project/%@", project_id];
        [[WildCardConstructor sharedInstance].delegate onNetworkRequest:url success:^(NSMutableDictionary* res) {
            [self hideIndicator];
            if(res != nil)
            {
                id list = res[@"project"][@"dev_host_list"];
                NSString* host = res[@"project"][@"host"];
                if(!host)
                    host = @"";
                if(!list)
                    list = [@[] mutableCopy];
                if(res[@"project"][@"host"])
                    
                list = [list mutableCopy];
                [list insertObject:@{@"host": host}atIndex:0];
                
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
