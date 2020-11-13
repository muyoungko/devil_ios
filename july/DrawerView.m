//
//  DrawerView.m
//  sticar
//
//  Created by Mu Young Ko on 2019. 6. 14..
//  Copyright © 2019년 trix. All rights reserved.
//

#import "DrawerView.h"

@implementation DrawerView

- (instancetype)initWithFrame:(CGRect)frame{
    self = [super initWithFrame:frame];
    
    self.userInteractionEnabled = NO;
    
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
//    [_viewMenu addGestureRecognizer:singleFingerTap];
    
    _viewMenu = [[UIView alloc] initWithFrame:CGRectMake(-screenWidth,0,screenWidth, screenHeight)];
    [self addSubview:_viewMenu];
    //_viewMenu.userInteractionEnabled = YES;
    
//    UIGestureRecognizer* g = [[UIGestureRecognizer alloc] initWithTarget:self action:@selector(handleGesture:)];
//    [self addGestureRecognizer:g];
    
    return self;
}

- (void)handleGesture:(UIGestureRecognizer *)gestureRecognizer{
    NSLog(@"handleGesture");
}

//- (BOOL)pointInside:(CGPoint)point withEvent:(UIEvent *)event
//{
//    NSLog(@"pointInside %d", [event.allTouches count]);
//    //if(event.UIEventType == UEventType)
//    return YES;
//}
//
//- (UIView *)hitTest:(CGPoint)point withEvent:(UIEvent *)event{
//    NSLog(@"hitTest %d", [event.allTouches count]);
//    return [super hitTest:point withEvent:event];
//}

- (void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event
{
    NSLog(@"touchesBegan");
    if(touches.count > 1)
        return;
    UITouch *touch = [touches anyObject];
    CGPoint touchPoint = [touch locationInView:self];
    
    touchStartX = touchPoint.x;
    touchTime = CACurrentMediaTime();
    
    if(naviStatus==1)
    {
        uiMenuStartX = _viewMenu.frame.origin.x;
    }
}

- (void)touchesMoved:(NSSet *)touches withEvent:(UIEvent *)event
{
    if(touches.count > 1)
        return;
    
    UITouch *touch = [touches anyObject];
    CGPoint touchPoint = [touch locationInView:self];
    
    float x = touchPoint.x;
    if(naviStatus==1)
    {
        float newUiMenuX = uiMenuStartX-(touchStartX-x);
        if(newUiMenuX<=0 && newUiMenuX >= -_viewMenu.frame.size.width)
        {
            _viewMenu.frame = CGRectMake(newUiMenuX
                                         , _viewMenu.frame.origin.y
                                         , _viewMenu.frame.size.width
                                         , _viewMenu.frame.size.height);
            
            _viewModal.alpha = MODAL_ALPHA*(
                                            (_viewMenu.frame.size.width+newUiMenuX)/
                                            _viewMenu.frame.size.width);
        }
        else if(newUiMenuX>0)
        {
            touchStartX = x;
            uiMenuStartX = _viewMenu.frame.origin.x;
        }
        else
        {
            _viewMenu.frame = CGRectMake(-_viewMenu.frame.size.width
                                         , _viewMenu.frame.origin.y
                                         , _viewMenu.frame.size.width
                                         , _viewMenu.frame.size.height);
            
            
            touchStartX = x;
            uiMenuStartX = _viewMenu.frame.origin.x;
        }
    }
}
- (void)touchesEnded:(NSSet *)touches withEvent:(UIEvent *)event
{
    if(touches.count > 1)
        return;
    
    double nowTouchTime = CACurrentMediaTime();
    
    UITouch *touch = [touches anyObject];
    CGPoint touchPoint = [touch locationInView:self];
    float x = touchPoint.x;
    
    if(nowTouchTime-touchTime <0.2f && fabs(touchStartX-x)<10.0f)
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
            if(newUiMenuX >= -(float)(_viewMenu.frame.size.width)/2.0f)
                [self naviUp];
            else
                [self naviDown];
        }
    }
    pointerId = -1;
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
            if(newUiMenuX >= -(float)(_viewMenu.frame.size.width)/2.0f)
                [self naviUp];
            else
                [self naviDown];
        }
    }
    pointerId = -1;
}




- (void)naviUp
{
    self.userInteractionEnabled = YES;
    naviStatus = 1;
    float duration = (-_viewMenu.frame.origin.x) / _viewMenu.frame.size.width*0.3f;
    [UIView animateWithDuration:duration
                          delay:0.0f
                        options:UIViewAnimationOptionCurveEaseOut
                     animations:^{
                         [_viewMenu setFrame:CGRectMake(0 , _viewMenu.frame.origin.y, _viewMenu.frame.size.width, _viewMenu.frame.size.height)];
                         _viewModal.alpha = MODAL_ALPHA;
                     }
                     completion:^(BOOL finished){
                         naviStatus = 1;
                     }];
}

- (void)naviDown
{
    self.userInteractionEnabled = NO;
    if(naviStatus == 0)
        return ;
 
    naviStatus = 0;
    float duration = 0.3f;
    [UIView animateWithDuration:duration
                          delay:0.0f
                        options:UIViewAnimationOptionCurveEaseOut
                     animations:^{
                         //412 <-> 460
                         CGRect screenRect = [[UIScreen mainScreen] bounds];
                         CGFloat screenWidth = screenRect.size.width;
                         CGFloat screenHeight = screenRect.size.height;
                        
                         [_viewMenu setFrame:CGRectMake(
                                                        -_viewMenu.frame.size.width
                                                        , _viewMenu.frame.origin.y, _viewMenu.frame.size.width, _viewMenu.frame.size.height)];
                         _viewModal.alpha = 0.0f;
                     }
                     completion:nil];
    [self endEditing:YES];
}




- (void)modalTap:(UITapGestureRecognizer *)recognizer
{
    [self naviDown];
}



@end
