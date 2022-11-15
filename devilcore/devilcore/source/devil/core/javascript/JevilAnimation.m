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

@implementation JevilAnimation

+ (void)start:(NSString*)node:(NSDictionary*)param{
    DevilController* vc = (DevilController*)[JevilInstance currentInstance].vc;
    UIView* v = [vc findView:node];
    
    NSString* type = param[@"type"];
    if([type isEqualToString:@"pulse"]) {
        float scale = 1.1;
        if(param[@"scale"])
            scale = [param[@"scale"] floatValue];
        CAAnimationGroup *animationGroup = [CAAnimationGroup animation];
        animationGroup.duration = 0.8f;
        animationGroup.repeatCount = INFINITY;
        
        CAKeyframeAnimation* animation = [CAKeyframeAnimation animationWithKeyPath:@"transform.scale"];
        animation.cumulative = YES;
        animation.values = @[@1.0, [NSNumber numberWithFloat:scale], @1.0];
        animation.keyTimes = @[@0.2, @0.5, @0.7];
        animationGroup.animations = @[animation];
        
        [v.layer addAnimation:animationGroup forKey:nil];
    }
}

+ (void)stop:(NSString*)node {
    DevilController* vc = (DevilController*)[JevilInstance currentInstance].vc;
    UIView* v = [vc findView:node];
    [v.layer removeAllAnimations];
}
@end
