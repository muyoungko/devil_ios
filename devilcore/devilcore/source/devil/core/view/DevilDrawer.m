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
@property (nonatomic, retain) NSString* activeBlockName;

@end

@implementation DevilDrawer

+ (id)sharedInstance {
    static DevilDrawer *sharedInstance = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        sharedInstance = [[self alloc] init];
    });
    return sharedInstance;
}

-(id)init {
    self = [super init];
    self.activeBlockName = nil;
    return self;
}

+(void)menuReady:(NSString*)blockName :(id)param{
    UIWindow* w = [UIApplication sharedApplication].keyWindow;
    UIView* pv = w;
    
    UIViewController* vc = [JevilInstance currentInstance].vc;
    NSString* blockId = [[WildCardConstructor sharedInstance] getBlockIdByName:blockName];
    int intBlockId = [blockId intValue];
    if([pv viewWithTag:intBlockId] == nil){
        
        NSString* show = param[@"show"];
        int offset = param[@"offset"] ? [param[@"offset"] intValue] : 0;
        int px_offset = [WildCardUtil convertSketchToPixel:offset];
        
        CGRect screenRect = [[UIScreen mainScreen] bounds];
        int screenWidth = screenRect.size.width;
        int screenHeight = screenRect.size.height;
    
        WildCardDrawerView* d = [[WildCardDrawerView alloc] initWithFrame:CGRectMake(0,0,screenWidth, screenHeight)];
        [d setTag:intBlockId];
        [pv addSubview:d];
            
        id cloudJson = [[WildCardConstructor sharedInstance] getBlockJson:blockId];
        //TODO fitblock
        id contentView = [WildCardConstructor constructLayer:d withLayer:cloudJson instanceDelegate:vc];
        [d constructContentView:contentView show:show offset:px_offset];
        int statusBarHeight = [[UIApplication sharedApplication] statusBarFrame].size.height;
    }
    
    WildCardDrawerView* d = [w viewWithTag:intBlockId];
    ((WildCardUIView*)d.contentView).meta.wildCardConstructorInstanceDelegate = vc;
    id data = [JevilInstance currentInstance].data;
    [WildCardConstructor applyRule:d.contentView withData:data];
}

+(void)menuOpen:(NSString*)blockName{
    UIWindow* w = [UIApplication sharedApplication].keyWindow;
    NSString* blockId = [[WildCardConstructor sharedInstance] getBlockIdByName:blockName];
    int intBlockId = [blockId intValue];
    WildCardDrawerView* d = [w viewWithTag:intBlockId];
    id data = [JevilInstance currentInstance].data;
    [[d superview] bringSubviewToFront:d];
    [WildCardConstructor applyRule:d.contentView withData:data];
    [d naviUp];
    [[DevilDrawer sharedInstance] setActiveBlockName:blockName];
}

+(void)menuClose{
    UIWindow* w = [UIApplication sharedApplication].keyWindow;
    NSString* blockName = [[DevilDrawer sharedInstance] getActiveBlockName];
    if(blockName != nil) {
        NSString* blockId = [[WildCardConstructor sharedInstance] getBlockIdByName:blockName];
        int intBlockId = [blockId intValue];
        WildCardDrawerView* d = [w viewWithTag:intBlockId];
        [d naviDown];
        [[DevilDrawer sharedInstance] setActiveBlockName:nil];
    }
}

-(NSString*)getActiveBlockName{
    return self.activeBlockName;
}
@end
