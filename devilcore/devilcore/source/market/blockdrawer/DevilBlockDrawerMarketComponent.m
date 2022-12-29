//
//  DevilBlockDrawerMarketComponent.m
//  devilcore
//
//  Created by Mu Young Ko on 2022/11/15.
//

#import "DevilBlockDrawerMarketComponent.h"
#import "MappingSyntaxInterpreter.h"
#import "WildCardUtil.h"
#import "WildCardConstructor.h"
#import "DevilFlingChecker.h"

@interface DevilBlockDrawerMarketComponent()

@property BOOL horizontal;
@property BOOL vertical;
@property BOOL top;
@property BOOL left;
@property BOOL right;
@property BOOL down;

@property float from;
@property float to;

@property (nonatomic, retain) UIView* movingContentView;
@property (nonatomic, retain) DevilFlingChecker* flingChecker;

@property void (^callbackUp)(id res);
@property void (^callbackDown)(id res);

@end

@implementation DevilBlockDrawerMarketComponent

- (void)initialized {
    [super initialized];
}

- (void)created {
    [super created];
    
    NSString* direction = self.marketJson[@"select2"];
    BOOL startHide = [@"Y" isEqualToString:self.marketJson[@"select3"]];
    self.flingChecker = [[DevilFlingChecker alloc] init];
    
    self.vv.userInteractionEnabled = YES;
    [WildCardConstructor userInteractionEnableToParentPath:self.vv depth:10];
    [self.vv addTouchCallback:^(int action, CGPoint p) {
        
        CGPoint pp = [self.vv convertPoint:p toView:nil];
        //NSLog(@"touch %f %f", pp.x, pp.y);
        if(action == TOUCH_ACTION_DOWN) {
            [self touchesBegan:pp];
            [self.flingChecker addTouchPoint:p];
        } else if(action == TOUCH_ACTION_MOVE) {
            [self touchesMoved:pp];
            [self.flingChecker addTouchPoint:p];
        } else if(action == TOUCH_ACTION_UP) {
            [self touchesEnded:pp];
            [self.flingChecker addTouchPoint:p];
        } else if(action == TOUCH_ACTION_CANCEL) {
            [self touchesCancelled:pp];
            [self.flingChecker addTouchPoint:p];
        }
    }];
    
    //CGRect r = [self.vv.superview convertRect:self.vv.frame toView:nil];
    
    _horizontal = _vertical = _left = _top = _down = _right = NO;
    if([@"down" isEqualToString:direction]) {
        _down = _vertical = YES;
    } else if([@"up" isEqualToString:direction]) {
        _top = _vertical = YES;
    } else if([@"left" isEqualToString:direction]) {
        _left = _horizontal = YES;
    } else if([@"right" isEqualToString:direction]) {
        _right = _horizontal = YES;
    }
    
    if(_horizontal) {
        if(_left) {
            self.vv.frame = CGRectMake(self.vv.frame.origin.x, self.vv.frame.origin.y, self.vv.frame.size.width, self.vv.frame.size.height);
            _from = -self.vv.frame.size.width;
            _to = 0;
        } else if(_right) {
            self.vv.frame = CGRectMake(self.vv.frame.origin.x, self.vv.frame.origin.y, self.vv.frame.size.width, self.vv.frame.size.height);
            _from = [self.vv superview].frame.size.width;
            _to = [self.vv superview].frame.size.width - self.vv.frame.size.width;
        }
    } else if(_vertical) {
        if(_top) {
            self.vv.frame = CGRectMake(self.vv.frame.origin.x, self.vv.frame.origin.y, self.vv.frame.size.width, self.vv.frame.size.height);
            _from = -self.vv.frame.size.height;
            _to = 0;
        } else if(_down) {
            self.vv.frame = CGRectMake(self.vv.frame.origin.x, self.vv.frame.origin.y, self.vv.frame.size.width, self.vv.frame.size.height);
            _from = [self.vv superview].frame.size.height;
            _to = [self.vv superview].frame.size.height - self.vv.frame.size.height;
        }
    }
    
    _movingContentView = self.vv;
    
    if(startHide)
        [self naviDown:false];
}

- (void)update:(id)opt {
    [super update:opt];
}



- (void)touchesBegan:(CGPoint)touchPoint
{
    touchStartX = touchPoint.x;
    touchStartY = touchPoint.y;
    touchTime = CACurrentMediaTime();
    
//    if(naviStatus==1)
    {
        uiMenuStartX = _movingContentView.frame.origin.x;
        uiMenuStartY = _movingContentView.frame.origin.y;
    }
}

- (void)uiSet:(float)x {
    
    float toX = _movingContentView.frame.origin.x, toY = _movingContentView.frame.origin.y;
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
    
    //NSLog(@"uiSet %f, %f, %f", x, toX, toY);
    _movingContentView.frame = CGRectMake(toX, toY, _movingContentView.frame.size.width, _movingContentView.frame.size.height);
}

- (void)touchesMoved:(CGPoint)touchPoint
{
    float x = touchPoint.x;
    float y = touchPoint.y;
//    if(naviStatus==1)
    {
        float newUiMenuX = uiMenuStartX-(touchStartX-x);
        float newUiMenuY = uiMenuStartY-(touchStartY-y);
        if(_horizontal)
            [self uiSet:newUiMenuX];
        else
            [self uiSet:newUiMenuY];
    }
}

- (void)touchesEnded:(CGPoint)touchPoint
{
    float x = touchPoint.x;
    float y = touchPoint.y;
    float xv = 0;
    float yv = 0;
    float fast = 100;
    int fling = [self.flingChecker getFling];
    //NSLog(@"fling - %d", fling);
    if(fling > 0) {
        if(_horizontal) {
            if(_left) {
                if(fling == FLING_LEFT)
                    [self naviDown];
                else if(fling == FLING_RIGHT)
                    [self naviUp];
            } else if(_right) {
                if(fling == FLING_LEFT)
                    [self naviUp];
                else if(fling == FLING_RIGHT)
                    [self naviDown];
            }
        } else if(_vertical) {
            if(_top) {
                if(fling == FLING_DOWN)
                    [self naviUp];
                else if(fling == FLING_UP)
                    [self naviDown];
            } else if(_down) {
                if(fling == FLING_DOWN)
                    [self naviDown];
                else if(fling == FLING_UP)
                    [self naviUp];
            }
        }
    }
    else
        if(_horizontal) {
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

- (void)touchesCancelled:(CGPoint)touchPoint
{
    float x = touchPoint.x;
    
//    if(nowTouchTime-touchTime < 0.2f && fabs(touchStartX-x)<10.0f)
//    {
//        if(naviStatus==1)
//        {
//            [self naviDown];
//        }
//    }
//    else
    {
        float newUiMenuX = uiMenuStartX-(touchStartX-x);
        if(naviStatus==1)
        {
            if(newUiMenuX >= -(float)(_movingContentView.frame.size.width)/2.0f)
                [self naviUp];
            else
                [self naviDown];
        }
    }
    pointerId = -1;
}

- (void)naviUpPreview:(int)preview_size {
    
    if(_horizontal) {
        
    } else if(_vertical) {
        if(_top) {
            
        } else if(_down) {
            int to = _from - preview_size;
            [self naviUp:to:false];
        }
    }
}

- (void)naviUp {
    [self naviUp:_to:true];
}

- (void)naviUp:(int)to:(BOOL)call
{
    naviStatus = 1;
    float duration = 0.2f;
    float toX=0, toY=0;
    if(_horizontal) {
        toX = to;
        toY = _movingContentView.frame.origin.y;
    } else {
        toX = _movingContentView.frame.origin.x;
        toY = to;
    }
    
    if(call && self.callbackUp) self.callbackUp(@{});
    
    [UIView animateWithDuration:duration
                          delay:0.0f
                        options:UIViewAnimationOptionCurveEaseOut
                     animations:^{
                         [_movingContentView setFrame:CGRectMake(toX , toY, _movingContentView.frame.size.width, _movingContentView.frame.size.height)];
                     }
                     completion:^(BOOL finished){
                         naviStatus = 1;
        
                     }];
}
- (void)naviDown {
    [self naviDown:true];
}
- (void)naviDown:(BOOL)animation
{
//    if(naviStatus == 0)
//        return ;
 
    naviStatus = 0;
    float duration = 0.2f;
    float toX=0, toY=0;
    if(_horizontal) {
        toX = _from;
        toY = _movingContentView.frame.origin.y;
    } else {
        toX = _movingContentView.frame.origin.x;
        toY = _from;
    }
    
    if(animation){
        [UIView animateWithDuration:duration
                              delay:0.0f
                            options:UIViewAnimationOptionCurveEaseOut
                         animations:^{
                             [_movingContentView setFrame:CGRectMake(toX, toY, _movingContentView.frame.size.width, _movingContentView.frame.size.height)];
            
                         }
                         completion:^(BOOL finished){
            
            if(self.callbackDown) self.callbackDown(@{});
        }];
    } else {
        [_movingContentView setFrame:CGRectMake(toX, toY, _movingContentView.frame.size.width, _movingContentView.frame.size.height)];
    }
}

- (void)callback:(NSString*)command :(void (^)(id res))callback{
    if([@"up" isEqualToString:command]) {
        self.callbackUp = callback;
    } else if([@"down" isEqualToString:command]) {
        self.callbackDown = callback;
    }
}

@end
