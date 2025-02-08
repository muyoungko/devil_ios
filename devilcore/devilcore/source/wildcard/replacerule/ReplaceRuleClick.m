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
#import "WildCardUILongClickGestureRecognizer.h"
#import "WildCardEventTracker.h"

@interface ReplaceRuleClick()
@property (nonatomic, retain) WildCardUITapGestureRecognizer* singleFingerTap;
@property (nonatomic, retain) WildCardUILongClickGestureRecognizer* longClick;
@end

@implementation ReplaceRuleClick

- (void)constructRule:(WildCardMeta *)wcMeta parent:(UIView *)parent vv:(WildCardUIView *)vv layer:(id)layer depth:(int)depth result:(id)result{

    vv.userInteractionEnabled = YES;
    [WildCardConstructor userInteractionEnableToParentPath:vv depth:depth];

    self.replaceView = vv;
    NSString* ga = layer[@"ga"];
    if(!ga)
        ga = vv.name;
    
    NSString* gaDataPath = layer[@"gaData"];
    
    if(layer[@"clickContent"]) {
        WildCardUITapGestureRecognizer *singleFingerTap =
        [[WildCardUITapGestureRecognizer alloc] initWithTarget:[WildCardConstructor sharedInstance] action:@selector(onClickListener:)];
        singleFingerTap.meta = wcMeta;
        [vv addGestureRecognizer:singleFingerTap];
        singleFingerTap.ga = ga;
        singleFingerTap.gaDataPath = gaDataPath;
        self.singleFingerTap = singleFingerTap;
        ((WildCardUIView*)self.replaceView).stringTag = layer[@"clickContent"];
        
    } else if(layer[@"clickJavascript"]) {
        WildCardUITapGestureRecognizer *singleFingerTap =
        [[WildCardUITapGestureRecognizer alloc] initWithTarget:[WildCardConstructor sharedInstance] action:@selector(script:)];
        singleFingerTap.meta = wcMeta;
        [vv addGestureRecognizer:singleFingerTap];
        singleFingerTap.ga = ga;
        singleFingerTap.gaDataPath = gaDataPath;
        self.singleFingerTap = singleFingerTap;
        ((WildCardUIView*)self.replaceView).stringTag = layer[@"clickJavascript"];
    }
    
    if(![@"Y" isEqualToString:layer[@"disableEffect"]]) {
        vv.effect = true;
        [vv prepareTouchEffect];
    }
    
    if(layer[@"longClickJavascript"]) {
        
        WildCardUILongClickGestureRecognizer *longClick =
        [[WildCardUILongClickGestureRecognizer alloc] initWithTarget:[WildCardConstructor sharedInstance] action:@selector(scriptForLongClick:)];
        longClick.meta = wcMeta;
        [vv addGestureRecognizer:longClick];
        longClick.ga = ga;
        longClick.gaDataPath = gaDataPath;
        self.longClick = longClick;
        longClick.script = layer[@"longClickJavascript"];
    }
}

- (void)updateRule:(WildCardMeta *)meta data:(id)opt{
}

@end
