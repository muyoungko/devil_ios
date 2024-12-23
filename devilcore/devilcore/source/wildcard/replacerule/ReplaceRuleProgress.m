//
//  ReplaceRuleProgress.m
//  devilcore
//
//  Created by Mu Young Ko on 2024/12/11.
//

#import "ReplaceRuleProgress.h"
#import "WildCardProgressBar.h"

@interface ReplaceRuleProgress()
@property BOOL constructed;
@end

@implementation ReplaceRuleProgress
- (void)constructRule:(WildCardMeta *)meta parent:(UIView *)parent vv:(WildCardUIView *)vv layer:(id)layer depth:(int)depth result:(id)result{
    self.replaceJsonLayer = layer[@"progress"];
    self.replaceView = vv;
    self.constructed = NO;
}

- (void)updateRule:(WildCardMeta *)meta data:(id)opt{
    id extension = self.replaceJsonLayer;
    if(!self.constructed) {
        self.constructed = YES;
        
        NSString* barBgNodeName = extension[@"select3"];
        __block NSString* watch = extension[@"select4"];
        NSString* cap = extension[@"select5"];
        WildCardUIView* barBg = (WildCardUIView*)[meta getView:barBgNodeName];
        __block BOOL dragable = [@"Y" isEqualToString:extension[@"select6"]];
        NSString* type = extension[@"select8"];
        __block BOOL vertical = [@"vertical" isEqualToString:type];
        
        WildCardProgressBar* barController = [[WildCardProgressBar alloc] init];
        meta.forRetain[@"progress_key"] = barController;
        barController.dragable = dragable;
        barController.vertical = vertical;
        barController.type = type;
        barController.meta = meta;
        barController.progressGroup = (WildCardUIView*)[barBg superview];
        if(cap)
            barController.cap = (WildCardUIView*)[meta getView:cap];
        barController.bar = (WildCardUIView*)self.replaceView;
        barController.bar_bg = barBg;
        barController.watch = watch;
        barController.dragUpScript = extension[@"select7"];
        barController.moveScript = extension[@"select9"];
        [barController construct];
    }
    
    WildCardProgressBar* barController = meta.forRetain[@"progress_key"];
     
    if(self.constructed && barController.moving) {
        return;
    }
    
    [barController update];
}
@end
