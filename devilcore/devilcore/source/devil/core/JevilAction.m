//
//  JevilAction.m
//  devilcore
//
//  Created by Mu Young Ko on 2020/12/06.
//

#import "JevilAction.h"

@implementation JevilAction

+(void)actoin:(NSString*)functionName args:(id)args viewController:(UIViewController*)vc meta:(WildCardMeta*)meta{
    functionName = [functionName stringByReplacingOccurrencesOfString:@"Jevil." withString:@""];
    if([functionName isEqualToString:@"menu"]){
        
    }
    else if([functionName isEqualToString:@"menuDown"]){
        
    }
}

@end
