//
//  WildCardUIView.m
//  CloudJsonViewer
//
//  Created by Mu Young Ko on 2018. 6. 18..
//  Copyright © 2018년 Mu Young Ko. All rights reserved.
//

#import "WildCardUIView.h"
#import "WildCardConstructor.h"

@interface WildCardUIView()
@property void (^touchCallback)(int action, CGPoint p);
@end

@implementation WildCardUIView


//-(void)drawRect:(CGRect)rect{
//    [super drawRect:rect];
//}

- (NSString *)description
{
    NSString *s = [super description];
    return [NSString stringWithFormat:@"%@ name : %@",s,  _name];
}

- (UIView *)hitTest:(CGPoint)point withEvent:(UIEvent *)event {
    if(self.touchCallback)
        return self;
    else
        return [super hitTest:point withEvent:event];
}

- (void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event
{
    if(touches.count > 1)
        return;
    
    if(!self.touchCallback)
        return;
    
    UITouch *touch = [touches anyObject];
    CGPoint touchPoint = [touch locationInView:self];
    self.touchCallback(TOUCH_ACTION_DOWN, touchPoint);
    
    return ;
}

- (void)touchesMoved:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event {
    if(touches.count > 1 || !self.touchCallback)
        return;
    
    UITouch *touch = [touches anyObject];
    CGPoint touchPoint = [touch locationInView:self];
    self.touchCallback(TOUCH_ACTION_MOVE, touchPoint);
}

- (void)touchesCancelled:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event
{
    if(touches.count > 1 || !self.touchCallback)
        return;
    
    UITouch *touch = [touches anyObject];
    CGPoint touchPoint = [touch locationInView:self];
    self.touchCallback(TOUCH_ACTION_CANCEL, touchPoint);
}
- (void)touchesEnded:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event
{
    if(touches.count > 1 || !self.touchCallback)
        return;
    
    UITouch *touch = [touches anyObject];
    CGPoint touchPoint = [touch locationInView:self];
    self.touchCallback(TOUCH_ACTION_UP, touchPoint);
}

- (instancetype)init
{
    self = [super init];
    if (self) {
        self.alignment = GRAVITY_LEFT | GRAVITY_TOP;
        self.wrap_width = NO;
        self.wrap_height = NO;
        self.cornerRadiusHalf = NO;
        self.tags = [@{} mutableCopy];
    }
    return self;
}

- (void)setFrame:(CGRect)frame
{
    [super setFrame:frame];
    if(_cornerRadiusHalf)
    {
        self.layer.cornerRadius = frame.size.height / 2.0f;
    }
}

- (void)addTouchCallback:(void (^)(int action, CGPoint p))callback {    
    self.touchCallback = callback;
}

 

//- (void)drawRect:(CGRect)rect
//{
//    [super drawRect:rect];
////    CGContextRef ctx = UIGraphicsGetCurrentContext();
////    CGContextSaveGState(ctx);
////
////
////    CGPathRef clippath = [UIBezierPath bezierPathWithRoundedRect:CGRectMake(x,y, width, height) cornerRadius:6].CGPath;
////    CGContextAddPath(ctx, clippath);
////
////    CGContextSetFillColorWithColor(ctx, self.color.CGColor);
////
////    CGContextClosePath(ctx);
////    CGContextFillPath(ctx);
////
////    [self.color set];
////
////
////    [_path closePath]; // Implicitly does a line between p4 and p1
////    [_path fill]; // If you want it filled, or...
////    [_path stroke]; // ...if you want to draw the outline.
////    CGContextRestoreGState(ctx);
//}

@end
