//
//  WildCardTimer.m
//  devilcore
//
//  Created by Mu Young Ko on 2021/01/12.
//

#import "WildCardTimer.h"
#import "WildCardTrigger.h"
#import "WildCardAction.h"

@interface WildCardTimer()

@property (nonatomic, retain) WildCardMeta* meta;
@property (nonatomic, retain) WildCardUILabel*tv;
@property (nonatomic, retain) id layer;
@property (nonatomic, retain) NSString* name;
@property (nonatomic, retain) WildCardUIView* vv;

@property int sec;
@property int originalSec;
@property BOOL singleCol;

@end

@implementation WildCardTimer

-(id)initWith:(WildCardMeta*)meta :(WildCardUILabel*)tv :(id)layer :(NSString*)name :(WildCardUIView*)vv{
    self = [super init];
    self.meta = meta;
    self.tv = tv;
    self.layer = layer;
    self.name = name;
    self.vv = vv;
    return self;
}

-(void)reset{
    self.sec = self.originalSec;
}

-(void)startTimeFrom:(NSString*)mm_ss{
    id s = [mm_ss componentsSeparatedByString:@":"];
    int hh = 0;
    int mm = 0;
    int ss = 0;
    if([s count] == 1){
        hh = mm = 0;
        ss = [s[0] intValue];
        self.singleCol = YES;
    } else if([s count] == 2){
        hh = 0;
        mm = [s[0] intValue];
        ss = [s[1] intValue];
        self.singleCol = NO;
    } else if([s count] == 3){
        hh = [s[0] intValue];
        mm = [s[1] intValue];
        ss = [s[2] intValue];
        self.singleCol = NO;
    }
    
    self.sec = self.originalSec = ss + mm*60 + hh*3600;
    id layerTimer = self.layer[@"timer"];
    if(layerTimer[@"start"])
        self.sec = self.originalSec = [layerTimer[@"start"] intValue];
    [self tick];
    self.vv.tags[@"timer"] = self;
}

-(void)showTime{
    NSString* t = @"";
    if(self.singleCol){
        t = [NSString stringWithFormat:@"%02d", self.sec];
    } else {
        if(self.sec >= 3600)
            t = [NSString stringWithFormat:@"%02d:%02d:%02d", self.sec/3600, (self.sec%3600)/60, self.sec % 60];
        else
            t = [NSString stringWithFormat:@"%02d:%02d", (self.sec%3600)/60, self.sec % 60];
    }
    self.tv.text = t;
}

-(void)tick {
    [self showTime];
    self.sec --;
    if(self.sec < 0){
        NSString* action = self.layer[@"timer"][@"action"];
        WildCardTrigger* trigger = [[WildCardTrigger alloc] init];
        [WildCardAction parseAndConducts:trigger action:action meta:self.meta];
    } else
        [self performSelector:@selector(tick) withObject:nil afterDelay:1];
}

@end
