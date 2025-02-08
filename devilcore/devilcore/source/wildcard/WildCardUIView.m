//
//  WildCardUIView.m
//  CloudJsonViewer
//
//  Created by Mu Young Ko on 2018. 6. 18..
//  Copyright © 2018년 Mu Young Ko. All rights reserved.
//

#import "WildCardUIView.h"
#import "WildCardConstructor.h"

@interface WildCardUIView() <CAAnimationDelegate>
@property void (^touchCallback)(int action, CGPoint p, NSSet *touches);
@property (nonatomic, retain) CAShapeLayer *shapeLayer;
@end

@implementation WildCardUIView

- (instancetype)init
{
    self = [super init];
    if (self) {
        self.alignment = GRAVITY_LEFT | GRAVITY_TOP;
        self.wrap_width = NO;
        self.wrap_height = NO;
        self.cornerRadiusHalf = NO;
        self.tags = [@{} mutableCopy];
        self.frameUpdateAvoid = NO;
        self.passHitTest = NO;
    }
    return self;
}


//-(void)drawRect:(CGRect)rect{
//    [super drawRect:rect];
//}

- (NSString *)description
{
    NSString *s = [super description];
    return [NSString stringWithFormat:@"%@ name : %@",s,  _name];
}

- (UIView *)hitTest:(CGPoint)point withEvent:(UIEvent *)event {
    //    NSLog(@"hitTest %@", self.name);
    if(self.touchCallback) {
        UIView* r = [super hitTest:point withEvent:event];
        //        NSLog(@"frame - %f, %f, %f, %f", self.frame.origin.x, self.frame.origin.y, self.frame.size.width, self.frame.size.height);
        //        NSLog(@"point - %f, %f", point.x, point.y);
        //        NSLog(@"--------------------");
        if(
           r == nil &&
           point.x > 0 && point.x < self.frame.size.width &&
           point.y > 0 && point.y < self.frame.size.height) {
               //            NSLog(@"hitTest return self");
               return self;
           } else {
               //NSLog(@"hitTest return %@", ((WildCardUIView*)r).name);
               return [super hitTest:point withEvent:event];
           }
    } else {
        UIView* a = [super hitTest:point withEvent:event];
        if(_passHitTest)
            return a == self ? nil : a;
        else
            return a;
    }
}

- (void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event
{
    if(self.effect) {
        [self prepareTouchEffect];
        [self touchEffect];
    }
    
    if(!self.multipleTouchEnabled && touches.count > 1)
        return;
    
    if(!self.touchCallback)
        return;
    
    UITouch *touch = [touches anyObject];
    CGPoint touchPoint = [touch locationInView:self];
    self.touchCallback(TOUCH_ACTION_DOWN, touchPoint, touches);
    
    return ;
}


- (void)touchesMoved:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event {
    if((!self.multipleTouchEnabled && touches.count > 1) || !self.touchCallback)
        return;
    
    UITouch *touch = [touches anyObject];
    CGPoint touchPoint = [touch locationInView:self];
    self.touchCallback(TOUCH_ACTION_MOVE, touchPoint, touches);
}

- (void)touchesCancelled:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event
{
    if(self.effect)
        [self touchEndEffect];
    
    if((!self.multipleTouchEnabled && touches.count > 1) || !self.touchCallback)
        return;
    
    UITouch *touch = [touches anyObject];
    CGPoint touchPoint = [touch locationInView:self];
    self.touchCallback(TOUCH_ACTION_CANCEL, touchPoint, touches);
}
- (void)touchesEnded:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event
{
    [self touchEndEffect];
    
    if((!self.multipleTouchEnabled && touches.count > 1) || !self.touchCallback)
        return;
    
    UITouch *touch = [touches anyObject];
    CGPoint touchPoint = [touch locationInView:self];
    self.touchCallback(TOUCH_ACTION_UP, touchPoint, touches);
}


- (void)setFrame:(CGRect)frame
{
    [super setFrame:frame];
    if(_cornerRadiusHalf)
    {
        self.layer.cornerRadius = frame.size.height / 2.0f;
    }
}

- (void)addTouchCallback:(void (^)(int action, CGPoint p, NSSet *touches))callback {
    self.touchCallback = callback;
}

- (void)prepareTouchEffect {
    if(!self.shapeLayer) {
        UIBezierPath *path = [self bezierPathWithRoundedRect:CGRectMake(0, 0, self.frame.size.width, self.frame.size.height)
                                               topLeftRadius:(CGFloat)self.layer.cornerRadius
                                              topRightRadius:(CGFloat)self.layer.cornerRadius
                                           bottomRightRadius:(CGFloat)self.layer.cornerRadius
                                            bottomLeftRadius:(CGFloat)self.layer.cornerRadius
        ];
        
        CAShapeLayer *shapeLayer = [CAShapeLayer layer];
        shapeLayer.path = path.CGPath;
        shapeLayer.fillColor = [UIColor blackColor].CGColor; // 내부 색상
        shapeLayer.opacity = 0.00f;
        [self.layer addSublayer:shapeLayer];
        self.shapeLayer = shapeLayer;
    }
}

- (void)touchEffect {
    
    self.shapeLayer.opacity = 0.1f;
    
    [self.shapeLayer removeAllAnimations];
}

- (void)touchEndEffect {
    self.shapeLayer.opacity = 0.0f;
    CABasicAnimation *opacityAnimation = [CABasicAnimation animationWithKeyPath:@"opacity"];
    opacityAnimation.fromValue = @(0.1);
    opacityAnimation.toValue = @(0.00);
    opacityAnimation.duration = 0.5;
    opacityAnimation.timingFunction = [CAMediaTimingFunction functionWithName:kCAMediaTimingFunctionEaseInEaseOut];
    opacityAnimation.delegate = self;
    [self.shapeLayer addAnimation:opacityAnimation forKey:@"opacityAnimation"];
}

- (void)animationDidStop:(CAAnimation *)anim finished:(BOOL)flag {
    if (flag) {
        self.shapeLayer.opacity = 0.0f;
    }
}

- (UIBezierPath *)bezierPathWithRoundedRect:(CGRect)rect
                             topLeftRadius:(CGFloat)topLeftRadius
                            topRightRadius:(CGFloat)topRightRadius
                          bottomRightRadius:(CGFloat)bottomRightRadius
                           bottomLeftRadius:(CGFloat)bottomLeftRadius {
    
    UIBezierPath *path = [UIBezierPath bezierPath];
    
    CGPoint topLeft = CGPointMake(CGRectGetMinX(rect), CGRectGetMinY(rect));
    CGPoint topRight = CGPointMake(CGRectGetMaxX(rect), CGRectGetMinY(rect));
    CGPoint bottomRight = CGPointMake(CGRectGetMaxX(rect), CGRectGetMaxY(rect));
    CGPoint bottomLeft = CGPointMake(CGRectGetMinX(rect), CGRectGetMaxY(rect));
    
    // 시작점: 좌측 상단 (모서리 곡선 시작)
    [path moveToPoint:CGPointMake(topLeft.x + topLeftRadius, topLeft.y)];
    
    // 상단 라인 및 우측 상단 곡선
    [path addLineToPoint:CGPointMake(topRight.x - topRightRadius, topRight.y)];
    [path addArcWithCenter:CGPointMake(topRight.x - topRightRadius, topRight.y + topRightRadius)
                    radius:topRightRadius
                startAngle:-M_PI_2
                  endAngle:0
                 clockwise:YES];
    
    // 우측 라인 및 우측 하단 곡선
    [path addLineToPoint:CGPointMake(bottomRight.x, bottomRight.y - bottomRightRadius)];
    [path addArcWithCenter:CGPointMake(bottomRight.x - bottomRightRadius, bottomRight.y - bottomRightRadius)
                    radius:bottomRightRadius
                startAngle:0
                  endAngle:M_PI_2
                 clockwise:YES];
    
    // 하단 라인 및 좌측 하단 곡선
    [path addLineToPoint:CGPointMake(bottomLeft.x + bottomLeftRadius, bottomLeft.y)];
    [path addArcWithCenter:CGPointMake(bottomLeft.x + bottomLeftRadius, bottomLeft.y - bottomLeftRadius)
                    radius:bottomLeftRadius
                startAngle:M_PI_2
                  endAngle:M_PI
                 clockwise:YES];
    
    // 좌측 라인 및 좌측 상단 곡선
    [path addLineToPoint:CGPointMake(topLeft.x, topLeft.y + topLeftRadius)];
    [path addArcWithCenter:CGPointMake(topLeft.x + topLeftRadius, topLeft.y + topLeftRadius)
                    radius:topLeftRadius
                startAngle:M_PI
                  endAngle:-M_PI_2
                 clockwise:YES];
    
    [path closePath]; // 경로 닫기
    return path;
}


@end
