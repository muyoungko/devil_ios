//
//  DevilDrawer.m
//  devilcore
//
//  Created by Mu Young Ko on 2021/06/19.
//

#import "DevilDrawer.h"
#import "WildCardDrawerView.h"
#import "WildCardConstructor.h"
#import "JevilInstance.h"
#import "WildCardUtil.h"

@import UIKit;

@interface DevilDrawer ()

@property void (^callback)(id res);

@end

@implementation DevilDrawer

+ (DevilDrawer*)sharedInstance {
    static DevilDrawer *sharedInstance = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        sharedInstance = [[self alloc] init];
    });
    return sharedInstance;
}

-(id)init {
    self = [super init];
    self.activeWildCardDrawerView = nil;
    self.keep = [@{} mutableCopy];
    return self;
}

+(void)menuReady:(NSString*)blockName :(id)param{
    UIWindow* w = [UIApplication sharedApplication].keyWindow;
    UIView* pv = w;
    
    UIViewController* vc = [JevilInstance currentInstance].vc;
    NSString* vckey = [NSString stringWithFormat:@"%@", vc];
    if([DevilDrawer sharedInstance].keep[vckey] == nil)
        [DevilDrawer sharedInstance].keep[vckey] = [@{} mutableCopy];
    
    NSString* blockId = [[WildCardConstructor sharedInstance] getBlockIdByName:blockName];
    if([DevilDrawer sharedInstance].keep[vckey][blockId] == nil){
        
        NSString* show = param[@"show"];
        int offset = param[@"offset"] ? [param[@"offset"] intValue] : 0;
        int px_offset = [WildCardUtil convertSketchToPixel:offset];
        
        CGRect screenRect = [[UIScreen mainScreen] bounds];
        int screenWidth = screenRect.size.width;
        int screenHeight = screenRect.size.height;
    
        WildCardDrawerView* d = [[WildCardDrawerView alloc] initWithFrame:CGRectMake(0,0,screenWidth, screenHeight)];
        [pv addSubview:d];
            
        id cloudJson = [[WildCardConstructor sharedInstance] getBlockJson:blockId];
        //TODO fitblock
        id contentView = [WildCardConstructor constructLayer:d withLayer:cloudJson instanceDelegate:vc];
        [d constructContentView:contentView show:show offset:px_offset];
        [DevilDrawer sharedInstance].keep[vckey][blockId] = d;
    }
    
    WildCardDrawerView* d = [DevilDrawer sharedInstance].keep[vckey][blockId];
    ((WildCardUIView*)d.contentView).meta.wildCardConstructorInstanceDelegate = vc;
    id data = [JevilInstance currentInstance].data;
    [WildCardConstructor applyRule:d.contentView withData:data];
}

+(void)menuOpen:(NSString*)blockName{
    UIWindow* w = [UIApplication sharedApplication].keyWindow;
    NSString* blockId = [[WildCardConstructor sharedInstance] getBlockIdByName:blockName];
    
    UIViewController* vc = [JevilInstance currentInstance].vc;
    NSString* vckey = [NSString stringWithFormat:@"%@", vc];
    if([DevilDrawer sharedInstance].keep[vckey] == nil)
        [DevilDrawer sharedInstance].keep[vckey] = [@{} mutableCopy];
    
    WildCardDrawerView* d = [DevilDrawer sharedInstance].keep[vckey][blockId];
    id data = [JevilInstance currentInstance].data;
    [[d superview] bringSubviewToFront:d];
    [WildCardConstructor applyRule:d.contentView withData:data];
    [d naviUp];
    [[DevilDrawer sharedInstance] setActiveWildCardDrawerView:d];
}

+(void)menuClose{
    WildCardDrawerView* d = [DevilDrawer sharedInstance].activeWildCardDrawerView;
    if(d != nil) {
        [d naviDown];
        [[DevilDrawer sharedInstance] setActiveWildCardDrawerView:nil];
    }
}

-(void)hide:(UIViewController*)vc{
    NSString* vckey = [NSString stringWithFormat:@"%@", vc];
    id drawers = self.keep[vckey];
    if(drawers != nil) {
        for(id blockId in [drawers allKeys]) {
            UIView* d = drawers[blockId];
            d.hidden = YES;
        }
    }
}

-(void)show:(UIViewController*)vc{
    NSString* vckey = [NSString stringWithFormat:@"%@", vc];
    id drawers = self.keep[vckey];
    if(drawers != nil) {
        for(id blockId in [drawers allKeys]) {
            UIView* d = drawers[blockId];
            d.hidden = NO;
        }
    }
}

-(void)update:(UIViewController*) vc {
    NSString* vckey = [NSString stringWithFormat:@"%@", vc];
    id drawers = self.keep[vckey];
    if(drawers != nil) {
        id data = [JevilInstance currentInstance].data;
        for(id blockId in [drawers allKeys]) {
            WildCardDrawerView* d = drawers[blockId];
            [WildCardConstructor applyRule:d.contentView withData:data];
        }
    }
}

@end
