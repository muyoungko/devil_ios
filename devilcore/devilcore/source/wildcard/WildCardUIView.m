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
@property void (^touchCallback)(int action, CGPoint p, NSSet *touches);
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
    if((!self.multipleTouchEnabled && touches.count > 1) || !self.touchCallback)
        return;
    
    UITouch *touch = [touches anyObject];
    CGPoint touchPoint = [touch locationInView:self];
    self.touchCallback(TOUCH_ACTION_CANCEL, touchPoint, touches);
}
- (void)touchesEnded:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event
{
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


@end
