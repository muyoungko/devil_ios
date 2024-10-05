//
//  JevilAnimation.m
//  devilcore
//
//  Created by Mu Young Ko on 2022/11/14.
//

#import "JevilAnimation.h"
#import "DevilController.h"
#import "Jevil.h"
#import "JevilInstance.h"
#import "WildCardUtil.h"
#import "WildCardUIView.h"
#import "WildCardConstructor.h"

@implementation JevilAnimation

+ (void)start:(NSString*)node:(NSDictionary*)param{
    DevilController* vc = (DevilController*)[JevilInstance currentInstance].vc;
    UIView* v = [vc findView:node];
    
    NSString* type = param[@"type"];
    float duration = 0.3f;
    if(param[@"duration"])
        duration = [param[@"duration"] intValue] / 1000.0f;
    if([type isEqualToString:@"pulse"]) {
        float scale = 1.1;
        if(param[@"scale"])
            scale = [param[@"scale"] floatValue];
        CAAnimationGroup *animationGroup = [CAAnimationGroup animation];
        animationGroup.duration = 0.8f;
        int count = INFINITY;
        if(param[@"count"])
            count = [param[@"count"] intValue];
        animationGroup.repeatCount = count;
        
        CAKeyframeAnimation* animation = [CAKeyframeAnimation animationWithKeyPath:@"transform.scale"];
        animation.cumulative = YES;
        animation.values = @[@1.0, [NSNumber numberWithFloat:scale], @1.0];
        animation.keyTimes = @[@0.2, @0.5, @0.7];
        animationGroup.animations = @[animation];
        
        [v.layer addAnimation:animationGroup forKey:nil];
    } else if([type isEqualToString:@"fadein"]) {
        v.alpha = 0.0;
        v.hidden = NO;
        [UIView animateWithDuration:duration delay:0.0 options:UIViewAnimationOptionCurveLinear animations:^{
            v.alpha = 1.0;
        } completion:^(BOOL finished) {
            
        }];
    } else if([type isEqualToString:@"fadeout"]) {
        v.alpha = 1.0;
        v.hidden = NO;
        [UIView animateWithDuration:duration delay:0.0 options:UIViewAnimationOptionCurveLinear animations:^{
            v.alpha = 0.0;
        } completion:^(BOOL finished) {
            
        }];
    } else if([type isEqualToString:@"move"]) {
        
        CGRect rect = CGRectMake(v.frame.origin.x, v.frame.origin.y, v.frame.size.width, v.frame.size.height);
        if(param[@"x"])
            rect.origin.x = [WildCardUtil convertSketchToPixel:[param[@"x"] intValue]];
        if(param[@"y"])
            rect.origin.y = [WildCardUtil convertSketchToPixel:[param[@"y"] intValue]];
        if(param[@"w"])
            rect.size.width = [WildCardUtil convertSketchToPixel:[param[@"w"] intValue]];
        if(param[@"h"])
            rect.size.height = [WildCardUtil convertSketchToPixel:[param[@"h"] intValue]];
        [UIView animateWithDuration:duration delay:0.0 options:UIViewAnimationOptionCurveLinear animations:^{
            v.frame = rect;
        } completion:^(BOOL finished) {
            
        }];
    } else if([type isEqualToString:@"morphing"]) {
        [JevilAnimation morphing:(WildCardUIView*)v param:param duration:duration];
    }
}

+ (void)stop:(NSString*)node {
    DevilController* vc = (DevilController*)[JevilInstance currentInstance].vc;
    UIView* v = [vc findView:node];
    [v.layer removeAllAnimations];
}

+ (void)morphing:(WildCardUIView*)beforeView param:(id)param duration:(float)duration {
    
    NSString* blockName = param[@"block"];
    WildCardUIView* afterView;
    if([blockName hasPrefix:@"#"]) {
        blockName = [blockName stringByReplacingOccurrencesOfString:@"#" withString:@""];
        NSString* blockId = [[WildCardConstructor sharedInstance] getBlockIdByName:blockName];
        id blockCloudJson = [[WildCardConstructor sharedInstance] getBlockJson:blockId];
        DevilController* vc = (DevilController*)[JevilInstance currentInstance].vc;
        afterView = [WildCardConstructor constructLayer:nil withLayer:blockCloudJson instanceDelegate:vc];
        [WildCardConstructor applyRule:afterView withData:vc.data];
    }
    
    [UIView animateWithDuration:duration delay:0.0 options:UIViewAnimationOptionCurveEaseOut animations:^{
        [JevilAnimation compareViewRecur:beforeView afterView:afterView depth:0];
    } completion:^(BOOL finished) {
            
    }];
    
}

+ (void)compareViewRecur:(WildCardUIView *)beforeView
               afterView:(WildCardUIView *)afterView
                  depth:(int)depth {
    if (depth > 0) {
        
        if (beforeView.frame.origin.x != afterView.frame.origin.x ||
            beforeView.frame.origin.y != afterView.frame.origin.y ||
            beforeView.frame.size.width != afterView.frame.size.width ||
            beforeView.frame.size.height != afterView.frame.size.height) {

            beforeView.frame = afterView.frame;
        }
        
        if (beforeView.alpha != afterView.alpha) {
            beforeView.alpha = afterView.alpha;
        }
    }

    NSMutableDictionary *afterChildMap = [NSMutableDictionary dictionary];
    for (int i = 0; i < afterView.subviews.count; i++) {
        UIView *child2 = afterView.subviews[i];
        if ([child2 isKindOfClass:[WildCardUIView class]]) {
            WildCardUIView *c2 = (WildCardUIView *)child2;
            afterChildMap[c2.name] = c2;
        }
    }

    for (int i = 0; i < beforeView.subviews.count; i++) {
        UIView *child1 = beforeView.subviews[i];
        if ([child1 isKindOfClass:[WildCardUIView class]]) {
            WildCardUIView *beforeChild = (WildCardUIView *)child1;
            WildCardUIView *afterChild = afterChildMap[beforeChild.name];
            
            if (afterChild) {
                [afterChildMap removeObjectForKey:beforeChild.name];
                [self compareViewRecur:beforeChild afterView:afterChild depth:depth + 1];
            } else {
                beforeChild.alpha = 0;
            }
        }
    }
    
    for (id name in afterChildMap) {
        WildCardUIView *afterChild = afterChildMap[name];
        [afterChild removeFromSuperview];
        afterChild.alpha = 0;
        [beforeView addSubview:afterChild];
        afterChild.alpha = 1;
    }
}
@end
