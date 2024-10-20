//
//  ReplaceRuleCheckbox.m
//  devilcore
//
//  Created by Mu Young Ko on 2024/10/20.
//

#import "ReplaceRuleCheckbox.h"
#import "WildCardUITapGestureRecognizer.h"
#import "WildCardEventTracker.h"
#import "WildCardAction.h"
#import "WildCardTrigger.h"
#import "JevilInstance.h"
@implementation ReplaceRuleCheckbox
 
- (void)constructRule:(WildCardMeta *)meta parent:(UIView *)parent vv:(WildCardUIView *)vv layer:(id)layer depth:(int)depth result:(id)result{
    [super constructRule:meta parent:parent vv:vv layer:layer depth:depth result:result];
    id checkbox = layer[@"checkbox"];
    NSString* name = layer[@"name"];
    vv.userInteractionEnabled = YES;
    [WildCardConstructor userInteractionEnableToParentPath:vv depth:depth];
    
    self.replaceJsonLayer = layer;
    
    WildCardUITapGestureRecognizer *singleFingerTap = [[WildCardUITapGestureRecognizer alloc] initWithTarget:self action:@selector(onCheckBoxClickListener:)];
    singleFingerTap.meta = meta;
    singleFingerTap.nodeName = name;
    [vv addGestureRecognizer:singleFingerTap];
}

- (void)updateRule:(WildCardMeta *)meta data:(id)opt{
    id extension = self.replaceJsonLayer[@"checkbox"];
    NSString* onNodeName = extension[@"select3"];
    NSString* offNodeName = extension[@"select4"];
    NSString* watch = extension[@"select5"];
    NSString* defaultOnOff = extension[@"select7"];
    WildCardUIView* onNodeView = meta.generatedViews[onNodeName];
    WildCardUIView* offNodeView = meta.generatedViews[offNodeName];
    
    BOOL check = YES;
    JSValue* js = meta.correspondData;
    
    if(![meta.correspondData hasProperty:watch])
    {
        if([@"Y" isEqualToString:defaultOnOff])
            check = YES;
        else
            check = NO;
    }
    else if([(JSValue*)meta.correspondData[watch] toBool])
    {
        check = YES;
    }
    else
    {
        check = NO;
    }
    
    self.replaceView.isAccessibilityElement = YES;
    self.replaceView.accessibilityTraits = UIAccessibilityTraitButton;
    self.replaceView.accessibilityLabel = [NSString stringWithFormat:@"%@ %@", self.replaceJsonLayer[@"name"], check?@" Selected":@" UnSelected"];
    if(check) {
        onNodeView.hidden = NO;
        offNodeView.hidden = YES;
        
        meta.correspondData[watch] = @TRUE;
    } else {
        onNodeView.hidden = YES;
        offNodeView.hidden = NO;
        
        meta.correspondData[watch] = @FALSE;
    }
}

-(void)onCheckBoxClickListener:(WildCardUITapGestureRecognizer *)recognizer
{
    WildCardMeta* meta = recognizer.meta;
    NSDictionary* extension = self.replaceJsonLayer[@"checkbox"];
    NSString* onNodeName = extension[@"select3"];
    NSString* offNodeName = extension[@"select4"];
    NSString* watch = extension[@"select5"];
    NSString* clickAction = extension[@"select8"];
    WildCardUIView* onNodeView = meta.generatedViews[onNodeName];
    WildCardUIView* offNodeView = meta.generatedViews[offNodeName];
    BOOL check = YES;
    if([(JSValue*)meta.correspondData[watch] toBool])
    {
        check = YES;
    }
    else
    {
        check = NO;
    }
    
    check = !check;
    
    id layer = recognizer.rule.replaceJsonLayer;
    recognizer.rule.replaceView.accessibilityLabel = [NSString stringWithFormat:@"%@ %@", layer[@"name"], check?@"선택됨":@"선택안됨"];
    
    if(check)
    {
        onNodeView.hidden = NO;
        offNodeView.hidden = YES;
        
        meta.correspondData[watch] = [JSValue valueWithBool:YES inContext:[JevilInstance currentInstance].jscontext];
    }
    else
    {
        onNodeView.hidden = YES;
        offNodeView.hidden = NO;
        
        meta.correspondData[watch] = [JSValue valueWithBool:NO inContext:[JevilInstance currentInstance].jscontext];
    }
    
    if(clickAction) {
        WildCardUIView* vv = (WildCardUIView*)recognizer.view;
        NSString *script = clickAction;
        WildCardTrigger* trigger = [[WildCardTrigger alloc] init];
        trigger.node = vv;
        [WildCardAction execute:trigger script:script meta:recognizer.meta];
    }
    
//    
//    WildCardTrigger* trigger = [[WildCardTrigger alloc] init];
//    [WildCardAction parseAndConducts:trigger action:clickAction meta:recognizer.meta];
//    
//    NSMutableDictionary* t = meta.triggersByName[recognizer.nodeName];
//    if(t[WILDCARD_NODE_CLICKED] != nil)
//        [t[WILDCARD_NODE_CLICKED] doAllAction];
}


@end
