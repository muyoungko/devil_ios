//
//  JevilLearning.m
//  devil
//
//  Created by Mu Young Ko on 2022/01/10.
//  Copyright © 2022 Mu Young Ko. All rights reserved.
//

#import "JevilLearning.h"
#import "Devil.h"
#import "LearningController.h"

@import devilcore;

@implementation JevilLearning

+ (NSString*)getCurrentScreenId {
    DevilController* dc = (DevilController*)[JevilInstance currentInstance].vc;
    return dc.screenId;
}

+ (NSString*)getText:(NSString*)node{
    DevilController* dc = (DevilController*)[JevilInstance currentInstance].vc;
    WildCardUIView* v = [dc findView:node];
    UILabel* tv = [v subviews][0];
    return tv.text;
}

+ (NSString*)getImage:(NSString*)node{
    DevilController* dc = (DevilController*)[JevilInstance currentInstance].vc;
    WildCardUIView* v = [dc findView:node];
    return v.tags[@"url"];
}

+ (void)click:(NSString*)node {
    DevilController* dc = (DevilController*)[JevilInstance currentInstance].vc;
    MetaAndViewResult* mr = [dc findViewWithMeta:node];
    
    NSString *script = mr.view.stringTag;
    WildCardTrigger* trigger = [[WildCardTrigger alloc] init];
    trigger.node = mr.view;
    [WildCardAction execute:trigger script:script meta:mr.meta];
}

+ (void)waitAlert:(NSString*)alertText :(int)sec :(JSValue*)callback {
    
    double delayInSeconds = sec;
    dispatch_time_t popTime = dispatch_time(DISPATCH_TIME_NOW, (int64_t)(delayInSeconds * NSEC_PER_SEC));
    dispatch_after(popTime, dispatch_get_main_queue(), ^(void){
        DevilController* dc = (DevilController*)[JevilInstance currentInstance].vc;
        NSString* activeAlertText = dc.activeAlert.title;
        [[JevilInstance currentInstance].vc dismissViewControllerAnimated:YES completion:^{
            
        }];
        [callback callWithArguments:
             @[([alertText isEqualToString:activeAlertText]?@TRUE:@FALSE)]
        ];
    });
}

+ (void)reload:(JSValue*)callback {
    DevilController* dc = (DevilController*)[JevilInstance currentInstance].vc;
    UINavigationController* nc = dc.navigationController;
    [[WildCardConstructor sharedInstance] initWithOnlineOnComplete:^(BOOL success) {
        NSString* project_id = [WildCardConstructor sharedInstance].project_id;
        id startData = ((DevilController*)nc.topViewController).startData;
        id screenId = ((DevilController*)nc.topViewController).screenId;
        [nc popViewControllerAnimated:YES];

        NSString* hostKey = [NSString stringWithFormat:@"%@_HOST", project_id];
        NSString* webHostKey = [NSString stringWithFormat:@"%@_WEB_HOST", project_id];
        NSString *savedHost = [[NSUserDefaults standardUserDefaults] objectForKey:hostKey];
        NSString *savedWebHost = [[NSUserDefaults standardUserDefaults] objectForKey:webHostKey];
        if(savedHost)
            [WildCardConstructor sharedInstance:project_id].project[@"host"] = savedHost;
        if(savedWebHost)
            [WildCardConstructor sharedInstance:project_id].project[@"web_host"] = savedWebHost;
        
        LearningController* d = [[LearningController alloc] init];
        d.startData = startData;
        d.screenId = screenId;
        d.projectId = project_id;
        [nc pushViewController:d animated:YES];
        
        double delayInSeconds = 2;
        dispatch_time_t popTime = dispatch_time(DISPATCH_TIME_NOW, (int64_t)(delayInSeconds * NSEC_PER_SEC));
        dispatch_after(popTime, dispatch_get_main_queue(), ^(void){
            [callback callWithArguments:@[]];
        });
    }];
}

+ (NSDictionary*)getRect:(NSString*)node{
    DevilController* dc = (DevilController*)[JevilInstance currentInstance].vc;
    WildCardUIView* v = [dc findView:node];
    id r = [@{} mutableCopy];
    
    
    r[@"x"] = [NSNumber numberWithFloat:[WildCardUtil convertPixcelToSketch:v.frame.origin.x]];
    r[@"y"] = [NSNumber numberWithFloat:[WildCardUtil convertPixcelToSketch:v.frame.origin.y]];
    r[@"w"] = [NSNumber numberWithFloat:[WildCardUtil convertPixcelToSketch:v.frame.size.width]];
    r[@"h"] = [NSNumber numberWithFloat:[WildCardUtil convertPixcelToSketch:v.frame.size.height]];
    return r;
}

+ (NSString*)getTextInVisibleInList:(NSArray*)path :(NSString*)node {
    DevilController* dc = (DevilController*)[JevilInstance currentInstance].vc;
    WildCardMeta* currentMeta = dc.mainWc.meta;
    for(int i=0;i<[path count];i++) {
        id p = path[i];
        WildCardUIView* listView = (WildCardUIView*)[currentMeta getView:p[@"listNode"]];
        WildCardUICollectionView* list = [listView subviews][0];
        WildCardCollectionViewAdapter* adapter = (WildCardCollectionViewAdapter*)list.delegate;
        int index = [p[@"index"] intValue];
        if(index < [[list subviews] count]) {
            UIView* cell = [list subviews][index];
            WildCardUIView* cellRootView = [cell subviews][0];
            currentMeta = cellRootView.meta;
        } else {
            return nil;
        }
    }
    
    UILabel *label = [currentMeta getTextView:node];
    return label.text;
}

+ (BOOL)isVisible:(NSString*)node {
    DevilController* dc = (DevilController*)[JevilInstance currentInstance].vc;
    WildCardUIView* v = [dc findView:node];
    return !v.hidden;
}

+ (void)sendInput:(NSString*)node :(NSString*)text :(JSValue*)callback {
    DevilController* dc = (DevilController*)[JevilInstance currentInstance].vc;
    WildCardUIView* v = [dc findView:node];
    WildCardUITextField* field = (WildCardUITextField*)[v subviews][0];
    field.text = text;
    field.meta.correspondData[field.holder] = text;
    [[JevilInstance currentInstance] pushData];
    
    double delayInSeconds = 1;
    dispatch_time_t popTime = dispatch_time(DISPATCH_TIME_NOW, (int64_t)(delayInSeconds * NSEC_PER_SEC));
    dispatch_after(popTime, dispatch_get_main_queue(), ^(void){
        [[JevilInstance currentInstance] pushData];
        [callback callWithArguments:@[]];
    });
}

+ (void)success{
    NSString* screen_id = ((DevilController*)[JevilInstance currentInstance].vc).screenId;
    NSString* path = [NSString stringWithFormat:@"/api/step/success/%@", screen_id];
    [[Devil sharedInstance] requestLearn:path postParam:nil complete:^(id  _Nonnull res) {
        if(res && [res[@"r"] boolValue])
            [Jevil alertFinish:@"성공하셨습니다"];
        else
            [Jevil alert:@"일시적 오류가 발생하였습니다. 다시 시도해주세요"];
    }];
}


@end
