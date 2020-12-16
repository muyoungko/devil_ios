//
//  JevilAction.m
//  devilcore
//
//  Created by Mu Young Ko on 2020/12/06.
//
#import "JevilAction.h"
#import "WildCardDrawerView.h"
#import "WildCardScreenTableView.h"
#import "WildCardConstructor.h"
#import "DevilController.h"

@implementation JevilAction

+(void)act:(NSString*)functionName args:(id)args viewController:(UIViewController*)vc meta:(WildCardMeta*)meta{
    functionName = [functionName stringByReplacingOccurrencesOfString:@"Jevil." withString:@""];
    if([functionName isEqualToString:@"menu"]){
        UIWindow* w = [UIApplication sharedApplication].keyWindow;
        UIView* pv = w;
        if([pv viewWithTag:44123] == nil){
            CGRect screenRect = [[UIScreen mainScreen] bounds];
            int screenWidth = screenRect.size.width;
            int screenHeight = screenRect.size.height;
        
            NSString* screenName = args[0];
            screenName = [screenName stringByReplacingOccurrencesOfString:@"'" withString:@""];
            WildCardDrawerView* d = [[WildCardDrawerView alloc] initWithFrame:CGRectMake(0,0,screenWidth, screenHeight)];
            [d setTag:44123];
            [pv addSubview:d];
            NSString* screenId = [[WildCardConstructor sharedInstance] getScreenIdByName:screenName];
            [[WildCardConstructor sharedInstance] firstBlockFitScreenIfTrue:screenId sketch_height_more:0];
            
            WildCardScreenTableView* tv = [[WildCardScreenTableView alloc] initWithScreenId:screenId];
            tv.data = meta.correspondData;
            tv.wildCardConstructorInstanceDelegate = meta.wildCardConstructorInstanceDelegate;
            tv.frame = CGRectMake(0, 0, screenWidth, screenHeight);
            [d.viewMenu addSubview:tv];
            
            int statusBarHeight = [[UIApplication sharedApplication] statusBarFrame].size.height;
        }
        WildCardDrawerView* d = [w viewWithTag:44123];
        [d naviUp];
        //self.leftWc.frame = CGRectMake(self.leftWc.frame.origin.x, statusBarHeight, self.leftWc.frame.size.width, screenHeight);
    }
    else if([functionName isEqualToString:@"menuDown"]){
        UIWindow* w = [UIApplication sharedApplication].keyWindow;
        UIView* pv = w;
        WildCardDrawerView* d = [pv viewWithTag:44123];
        [d naviDown];
    } else if([functionName isEqualToString:@"back"]){
        [vc.navigationController popViewControllerAnimated:YES];
    } else if([functionName isEqualToString:@"out"]){
        
        NSString* urlTo = args[0];
        urlTo = [urlTo stringByReplacingOccurrencesOfString:@"'" withString:@""];
            
        if(urlTo != nil)
            [[UIApplication sharedApplication] openURL:[NSURL URLWithString:urlTo] options:@{} completionHandler:^(BOOL success) {

            }];
    } else if([functionName isEqualToString:@"go"]){
        DevilController* nvc = [[DevilController alloc] init];
        NSString* screenName = args[0];
        screenName = [screenName stringByReplacingOccurrencesOfString:@"'" withString:@""];
        nvc.screenId = [[WildCardConstructor sharedInstance] getScreenIdByName:screenName];
        [vc.navigationController pushViewController:nvc animated:YES];
    }
}

@end