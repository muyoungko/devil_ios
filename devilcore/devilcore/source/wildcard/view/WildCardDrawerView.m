//
//  WildCardDrawerView.m
//  sticar
//
//  Created by Mu Young Ko on 2019. 6. 14..
//  Copyright © 2019년 trix. All rights reserved.
//

#import "WildCardDrawerView.h"
#import "WildCardUIView.h"

@interface WildCardDrawerView ()

@end

@implementation WildCardDrawerView

- (instancetype)initWithFrame:(CGRect)frame{
    self = [super initWithFrame:frame];
    
    self.userInteractionEnabled = YES;
    
    screenWidth = [[UIScreen mainScreen] bounds].size.width;
    screenHeight = [[UIScreen mainScreen] bounds].size.height;
    
    _viewModal = [[UIView alloc] initWithFrame:CGRectMake(0,0,screenWidth, screenHeight)];
    [self addSubview:_viewModal];
    _viewModal.backgroundColor = [UIColor blackColor];
    _viewModal.alpha = 0.0f;
    
//    UITapGestureRecognizer *singleFingerTap =
//    [[UITapGestureRecognizer alloc] initWithTarget:self
//                                            action:@selector(modalTap:)];
//    [_viewModal addGestureRecognizer:singleFingerTap];
//    [_contentView addGestureRecognizer:singleFingerTap];
    
//    _contentView = [[UIView alloc] initWithFrame:CGRectMake(-screenWidth,0,screenWidth, screenHeight)];
//    [self addSubview:_contentView];
    //_contentView.userInteractionEnabled = YES;
    
//    UIGestureRecognizer* g = [[UIGestureRecognizer alloc] initWithTarget:self action:@selector(handleGesture:)];
//    [self addGestureRecognizer:g];
    
    return self;
}

- (void)constructContentView:(UIView*)contentView show:(NSString*)show offset:(int)offset{
    if([@"right" isEqualToString:show]) {
        self.left = false;
        self.horizontal = true;
    } else if([@"top" isEqualToString:show]) {
        self.top = true;
        self.horizontal = false;
    } else if([@"bottom" isEqualToString:show]) {
        self.top = false;
        self.horizontal = false;
    }
    
    self.contentView = contentView;
    [self addSubview:contentView];
    
    CGRect frame = contentView.frame;
    float x=0,y=0;
    float menuWidth = frame.size.width;
    float menuHeight = frame.size.height;
    float sw = [UIScreen mainScreen].bounds.size.width;
    float sh = [UIScreen mainScreen].bounds.size.height;
    if(self.horizontal) {
        if (self.left) {
            self.from = x = -menuWidth;
            self.to = 0;
        } else {
            self.from = x = sw;
            self.to = sw - menuWidth;
        }
    } else {
        if (self.top) {
            self.from = y = -menuHeight + offset;
            self.to = 0;
        } else {
            self.from = y = sh - offset;
            self.to = sh - menuHeight;
        }
    }
    contentView.frame = CGRectMake(x, y, menuWidth, menuHeight);
}


- (void)naviUp
{
    naviStatus = 1;
    float duration = 0.2f;
    float toX=0, toY=0;
    if(_horizontal) {
        toX = _to;
    } else {
        toY = _to;
    }
    
    [UIView animateWithDuration:duration
                          delay:0.0f
                        options:UIViewAnimationOptionCurveEaseOut
                     animations:^{
                         [_contentView setFrame:CGRectMake(toX , toY, _contentView.frame.size.width, _contentView.frame.size.height)];
                         _viewModal.alpha = MODAL_ALPHA;
                     }
                     completion:^(BOOL finished){
                         naviStatus = 1;
                     }];
}

- (void)naviDown
{
    if(naviStatus == 0)
        return ;
 
    naviStatus = 0;
    float duration = 0.2f;
    float toX=0, toY=0;
    if(_horizontal) {
        toX = _from;
    } else {
        toY = _from;
    }
    [UIView animateWithDuration:duration
                          delay:0.0f
                        options:UIViewAnimationOptionCurveEaseOut
                     animations:^{
                         //412 <-> 460
                         CGRect screenRect = [[UIScreen mainScreen] bounds];
                         CGFloat screenWidth = screenRect.size.width;
                         CGFloat screenHeight = screenRect.size.height;
                        
                         [_contentView setFrame:CGRectMake(toX, toY, _contentView.frame.size.width, _contentView.frame.size.height)];
                         _viewModal.alpha = 0.0f;
                     }
                     completion:nil];
    [self endEditing:YES];
}




- (void)modalTap:(UITapGestureRecognizer *)recognizer
{
    [self naviDown];
}

- (void)handleGesture:(UIGestureRecognizer *)gestureRecognizer{
    NSLog(@"handleGesture");
}

- (UIView *)hitTest:(CGPoint)point withEvent:(UIEvent *)event{
    if(naviStatus == 1) {
        if(CGRectContainsPoint(self.contentView.frame, point)) {
            UIView* r = [super hitTest:point withEvent:event];
            return r;
        } else
            return self;
    } else {
        if(CGRectContainsPoint(self.contentView.frame, point)) {
            UIView* r = [super hitTest:point withEvent:event];
            return r;
        } else
            return nil;
    }
}

- (void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event
{
    NSLog(@"touchesBegan %@", ((WildCardUIView*)self.contentView).name);
    if(touches.count > 1)
        return;
    UITouch *touch = [touches anyObject];
    CGPoint touchPoint = [touch locationInView:self];
    
    touchStartX = touchPoint.x;
    touchStartY = touchPoint.y;
    touchTime = CACurrentMediaTime();
    
    if(naviStatus==1)
    {
        uiMenuStartX = _contentView.frame.origin.x;
        uiMenuStartY = _contentView.frame.origin.y;
    }
}

- (void)uiSet:(float)x {
    float rate = (x-_from) / (_to-_from) ;
    if(rate < 0)
        rate = 0;
    else if(rate > MODAL_ALPHA)
        rate = MODAL_ALPHA;
    _viewModal.alpha = (rate * MODAL_ALPHA);
    
    float toX = 0, toY = 0;
    if(_horizontal) {
        if (_left) {
            if (x < _from)
                toX = _from;
            else if (x > _to)
                toX = _to;
            else
                toX = x;
        } else {
            if (x > _from)
                toX = _from;
            else if (x < _to)
                toX = _to;
            else
                toX = x;
        }
    } else {
        if (_top) {
            if (x < _from)
                toY = _from;
            else if (x > _to)
                toY =  _to;
            else
                toY =  x;
        } else {
            if (x > _from)
                toY = _from;
            else if (x < _to)
                toY = _to;
            else
                toY = (int) x;
        }
    }
    _contentView.frame = CGRectMake(toX,toY, _contentView.frame.size.width, _contentView.frame.size.height);
}

- (void)touchesMoved:(NSSet *)touches withEvent:(UIEvent *)event
{
    
    if(touches.count > 1)
        return;
    
    UITouch *touch = [touches anyObject];
    NSLog(@"touchesMoved %f", touch.force);
    CGPoint touchPoint = [touch locationInView:self];
    
    float x = touchPoint.x;
    float y = touchPoint.y;
    if(naviStatus==1)
    {
        float newUiMenuX = uiMenuStartX-(touchStartX-x);
        float newUiMenuY = uiMenuStartY-(touchStartY-y);
        if(_horizontal)
            [self uiSet:newUiMenuX];
        else
            [self uiSet:newUiMenuY];
    }
}

- (void)touchesEnded:(NSSet *)touches withEvent:(UIEvent *)event
{
    NSLog(@"touchesEnded %@", ((WildCardUIView*)self.contentView).name);
    if(touches.count > 1)
        return;
    
    double nowTouchTime = CACurrentMediaTime();
    
    UITouch *touch = [touches anyObject];
    CGPoint touchPoint = [touch locationInView:self];
    float x = touchPoint.x;
    float y = touchPoint.y;
    float xv = 0;
    float yv = 0;
    float fast = 100;
    if(nowTouchTime-touchTime <0.2f) {
        if(naviStatus == 1)
            [self naviDown];
        else
            [self naviUp];
    }
    else if(_horizontal) {
        if(_left) {
            if (xv < -fast)
                [self naviDown];
            else if (xv > fast)
                [self naviUp];
            else
                [self judge:x];
        } else if(!_left) {
            if (xv < -fast)
                [self naviUp];
            else if (xv > fast)
                [self naviDown];
            else
                [self judge:x];
        }
    } else {
        if(_top) {
            if (yv < -fast)
                [self naviDown];
            else if (yv > fast)
                [self naviUp];
            else
                [self judge:y];
        } else if(!_top) {
            if (yv < -fast)
                [self naviUp];
            else if (yv > fast)
                [self naviDown];
            else
                [self judge:y];
        }
    }
    pointerId = -1;
}

- (void)judge:(float)x {
    if(fabs(_from-x) < fabs(_to-x))
        [self naviDown];
    else
        [self naviUp];
}

- (void)touchesCancelled:(NSSet *)touches withEvent:(UIEvent *)event
{
    if(touches.count > 1)
        return;
    
    double nowTouchTime = CACurrentMediaTime();
    
    UITouch *touch = [touches anyObject];
    CGPoint touchPoint = [touch locationInView:self];
    float x = touchPoint.x;
    
    if(nowTouchTime-touchTime < 0.2f && fabs(touchStartX-x)<10.0f)
    {
        if(naviStatus==1)
        {
            [self naviDown];
        }
    }
    else
    {
        float newUiMenuX = uiMenuStartX-(touchStartX-x);
        if(naviStatus==1)
        {
            if(newUiMenuX >= -(float)(_contentView.frame.size.width)/2.0f)
                [self naviUp];
            else
                [self naviDown];
        }
    }
    pointerId = -1;
}



@end
