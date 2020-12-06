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

@implementation JevilAction

+(void)act:(NSString*)functionName args:(id)args viewController:(UIViewController*)vc meta:(WildCardMeta*)meta{
    functionName = [functionName stringByReplacingOccurrencesOfString:@"Jevil." withString:@""];
    if([functionName isEqualToString:@"menu"]){
        UIWindow* w = [UIApplication sharedApplication].keyWindow;
        if([vc.view viewWithTag:44123] == nil){
            CGRect screenRect = [[UIScreen mainScreen] bounds];
            int screenWidth = screenRect.size.width;
            int screenHeight = screenRect.size.height;
        
            NSString* screenName = args[0];
            screenName = [screenName stringByReplacingOccurrencesOfString:@"'" withString:@""];
            WildCardDrawerView* d = [[WildCardDrawerView alloc] initWithFrame:CGRectMake(0,0,screenWidth, screenHeight)];
            [d setTag:44123];
            [w addSubview:d];
            NSString* screenId = [[WildCardConstructor sharedInstance] getScreenIdByName:screenName];
            
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
        WildCardDrawerView* d = [w viewWithTag:44123];
        [d naviDown];
    }
}

@end
