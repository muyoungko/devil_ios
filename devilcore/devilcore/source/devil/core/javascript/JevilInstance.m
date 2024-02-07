//
//  JevilInstance.m
//  devilcore
//
//  Created by Mu Young Ko on 2021/01/14.
//

#import "JevilInstance.h"
#import "JevilUtil.h"
#import "WildCardVideoView.h"
#import "DevilController.h"
#import "MarketInstance.h"

@implementation JevilInstance

+(JevilInstance*)globalInstance{
    static JevilInstance *sharedInstance = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        sharedInstance = [[JevilInstance alloc] init];
    });
    return sharedInstance;
}

+(JevilInstance*)screenInstance{
    static JevilInstance *sharedInstance = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        sharedInstance = [[JevilInstance alloc] init];
    });
    return sharedInstance;
}

+(JevilInstance*)currentInstance{
    static JevilInstance *sharedInstance = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        sharedInstance = [[JevilInstance alloc] init];
    });
    return sharedInstance;
}

- (instancetype)init
{
    self = [super init];
    if (self) {
        self.forRetain = [@{} mutableCopy];
    }
    return self;
}
-(void)syncData{
    JSValue* dataJs = [self.jscontext evaluateScript:@"data"];
    id newData = [dataJs toDictionary];
    id ingredient_list = newData[@"ingredient_list"];
    [JevilUtil sync:newData :self.data];
    id ingredient_list2 = self.data[@"ingredient_list"];
}

-(void)pushData{
    self.jscontext[@"data"] = self.data;
}

-(void)videoViewAutoPlay{
    [WildCardVideoView autoPlay];
}

-(void)timerFunction:(NSString*)key{
    if(self.timerCallback != nil){
        self.timerCallback(key);
        self.timerCallback = nil;
    }
}

-(MarketComponent*)findMarketComponent:(NSString*)nodeName {
    DevilController* vc = (DevilController*)self.vc;
    MetaAndViewResult* mv = [vc findViewWithMeta:nodeName];
    return [MarketInstance findMarketComponent:mv.meta replaceView:mv.view];
}

@end
