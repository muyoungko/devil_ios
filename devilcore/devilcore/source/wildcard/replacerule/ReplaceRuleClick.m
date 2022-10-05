//
//  ReplaceRuleClick.m
//  CloudJsonViewer
//
//  Created by Mu Young Ko on 2018. 6. 18..
//  Copyright © 2018년 Mu Young Ko. All rights reserved.
//

#import "ReplaceRuleClick.h"
#import "WildCardConstructor.h"
#import "MappingSyntaxInterpreter.h"
#import "WildCardUITapGestureRecognizer.h"
#import "WildCardEventTracker.h"

@interface ReplaceRuleClick()
@property (nonatomic, retain) WildCardUITapGestureRecognizer* singleFingerTap;
@end

@implementation ReplaceRuleClick

- (void)constructRule:(WildCardMeta *)wcMeta parent:(UIView *)parent vv:(WildCardUIView *)vv layer:(id)layer depth:(int)depth result:(id)result{

    vv.userInteractionEnabled = YES;
    [WildCardConstructor userInteractionEnableToParentPath:vv depth:depth];

    self.replaceView = vv;
    
    if(layer[@"clickContent"]) {
        WildCardUITapGestureRecognizer *singleFingerTap =
        [[WildCardUITapGestureRecognizer alloc] initWithTarget:[WildCardConstructor sharedInstance] action:@selector(onClickListener:)];
        singleFingerTap.meta = wcMeta;
        [vv addGestureRecognizer:singleFingerTap];
        self.singleFingerTap = singleFingerTap;
        ((WildCardUIView*)self.replaceView).stringTag = layer[@"clickContent"];
    } else if(layer[@"clickJavascript"]) {
        WildCardUITapGestureRecognizer *singleFingerTap =
        [[WildCardUITapGestureRecognizer alloc] initWithTarget:[WildCardConstructor sharedInstance] action:@selector(script:)];
        singleFingerTap.meta = wcMeta;
        [vv addGestureRecognizer:singleFingerTap];
        self.singleFingerTap = singleFingerTap;
        ((WildCardUIView*)self.replaceView).stringTag = layer[@"clickJavascript"];
    }
    
    [[WildCardEventTracker sharedInstance] onClickEvent:vv.name];
}

- (void)updateRule:(WildCardMeta *)meta data:(id)opt{
}

@end
