//
//  DevilImageMap.m
//  devilcore
//
//  Created by Mu Young Ko on 2022/08/10.
//

#import "DevilImageMap.h"
#import "WildCardConstructor.h"
#import "DevilUtil.h"
#import "WildCardUtil.h"
#import "DevilPinLayer.h"
#import "DevilExceptionHandler.h"

#define POPUP_TAG_OK 1201
#define POPUP_TAG_CANCEL 1200

#include <math.h>

@interface DevilImageMap()<UIScrollViewDelegate>
@property (nonatomic, retain) UIImageView* imageView;
@property (nonatomic, retain) UIView* contentView;
@property (nonatomic, retain) UIScrollView* scrollView;
@property (nonatomic, retain) UITapGestureRecognizer * singleFingerTap;
@property (nonatomic, retain) UILongPressGestureRecognizer * singleFingerLongTap;
@property (nonatomic, retain) NSString* mode;
@property (nonatomic, retain) id param;
@property (nonatomic, retain) id editingPin;
@property (nonatomic, retain) id insertingPin;
@property (nonatomic, retain) id touchingPin;
@property (nonatomic, retain) DevilPinLayer* pinLayer;

@property BOOL shouldDirectionMove;
@property float min_inset_width;
@property float min_inset_height;

@property (nonatomic, retain) UIView* popupView;


@property void (^pinCallback)(id res);
@property void (^directionCallback)(id res);
@property void (^completeCallback)(id res);
@property void (^actionCallback)(id res);
@property void (^clickCallback)(id res);


@property double touchStartTime;
@property double pinModeChangeTime;
@property int arrowType;
@property int pinFirst;
@property BOOL longClickToMove;
@property BOOL longClickTouching;

@property int longClickTouchingPinFirst;
@property (nonatomic, retain) id longClickKeyList;

@end

@implementation DevilImageMap

float circleWidth = 70;
float borderWidth = 7;

-(void)construct {
    float sw = [UIScreen mainScreen].bounds.size.width;
    float sh = [UIScreen mainScreen].bounds.size.height;
    
    self.imageView = [[UIImageView alloc] init];
    self.imageView.userInteractionEnabled = NO;
    
    self.pinLayer = [[DevilPinLayer alloc] initWithFrame:CGRectMake(0, 0, sw, sh)];
    self.pinLayer.backgroundColor = [UIColor clearColor];
    self.pinLayer.userInteractionEnabled = NO;
    
    self.scrollView = [[UIScrollView alloc] initWithFrame:CGRectMake(0, 0, sw, sh)];
    self.scrollView.bounces = NO;
    self.scrollView.bouncesZoom = NO;
    self.scrollView.clipsToBounds = NO;
    self.scrollView.autoresizesSubviews = NO;
    _scrollView.userInteractionEnabled = YES;
    _scrollView.scrollEnabled = YES;
    
    self.scrollView.maximumZoomScale = 1;
    _scrollView.delegate = self;
    
    _contentView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, sw, sh)];
    _contentView.userInteractionEnabled = NO;
    
    [self addSubview:_scrollView];
    [_scrollView addSubview:_contentView];
    [_contentView addSubview:_imageView];
    [_contentView addSubview:_pinLayer];
    [WildCardConstructor followSizeFromFather:self child:self.scrollView];
    
    _singleFingerTap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(onClickListener:)];
    [self addGestureRecognizer:_singleFingerTap];
    
    _singleFingerLongTap = [[UILongPressGestureRecognizer alloc] initWithTarget:self action:@selector(onClickLongListener:)];
    [self addGestureRecognizer:_singleFingerLongTap];
    
    NSBundle *bundle = [NSBundle bundleForClass:[self class]];
    
    self.arrowType = ARROW_TYPE_ARROW;
    self.pinFirst = PIN_FIRST_PIN;
    self.longClickTouching = self.longClickToMove = NO;
    self.longClickKeyList = [@[] mutableCopy];
    
    
    self.mode = @"normal";
}

-(CGPoint) pinToScreenPoint:(id)pin {
    UIView* rootView = [UIApplication sharedApplication].keyWindow.rootViewController.view;
    float x = [pin[@"x"] floatValue];
    float y = [pin[@"y"] floatValue];
    CGPoint pinPointInScreen = [_contentView convertPoint:CGPointMake(x, y) toView:rootView];
    return pinPointInScreen;
}

-(CGPoint) mapToClickPoint:(CGPoint)p {
    UIView* rootView = [UIApplication sharedApplication].keyWindow.rootViewController.view;
    float x = p.x;
    float y = p.y;
    CGPoint r = [_contentView convertPoint:CGPointMake(x, y) toView:rootView];
    return r;
}

-(CGPoint) clickToMapPoint:(CGPoint)p {
    return [self convertPoint:p toView:self.contentView];
}


-(BOOL) isNearPin:(id)pin tap:(CGPoint)tappedPoint {
    UIView* rootView = [UIApplication sharedApplication].keyWindow.rootViewController.view;
    float x = [pin[@"x"] floatValue];
    float y = [pin[@"y"] floatValue];
    CGPoint pinPointInScreen = [_contentView convertPoint:CGPointMake(x, y) toView:rootView];
    float w = 40;
    CGRect pinRect = CGRectMake(pinPointInScreen.x -w/2, pinPointInScreen.y-w/2, w, w);
    return CGRectContainsPoint(pinRect, tappedPoint);
}


-(BOOL) isNearPinPoint:(id)pin tap:(CGPoint)tappedPoint {
    
    float x = [pin[@"toX"] floatValue];
    float y = [pin[@"toY"] floatValue];
    
    if(!pin[@"toX"]) {
        float degree = [pin[@"degree"] floatValue] - 90.0f;
        float arrowLength = 29;
        float arrow_angle = degree * M_PI / 180.0f;
        CGPoint fakeArrowTo = (CGPoint){x + cos(arrow_angle) * arrowLength, y + sin(arrow_angle) * arrowLength};
        x = fakeArrowTo.x;
        y = fakeArrowTo.y;
    }
    
    UIView* rootView = [UIApplication sharedApplication].keyWindow.rootViewController.view;
    CGPoint pinPointInScreen = [_contentView convertPoint:CGPointMake(x, y) toView:rootView];
    float w = 40;
    CGRect pinRect = CGRectMake(pinPointInScreen.x -w/2, pinPointInScreen.y-w/2, w, w);
    return CGRectContainsPoint(pinRect, tappedPoint);
}


-(void)onClickLongListener:(UIGestureRecognizer *)recognizer {
    
    CGPoint clickP = [recognizer locationInView:self];
    if(!self.longClickToMove || ![@"normal" isEqualToString:_mode])
        return;
    
    if(recognizer.state == UIGestureRecognizerStateBegan) {
        id map = [@{} mutableCopy];
        for(id key in self.longClickKeyList) {
            map[key] = key;
        }
        
        for(id pin in self.pinList) {
            if(!map[pin[@"key"]])
                continue;
            
            if([self isNearPin:pin tap:clickP]) {
                self.touchingPin = pin;
                self.longClickTouchingPinFirst = PIN_FIRST_POINT;
                self.longClickTouching = YES;
                if(self.touchingPin[@"toX"])
                    [self pinMovePinWithoutToXY:self.touchingPin:clickP];
                else
                    [self pinMovePinWithoutToXY:self.touchingPin:clickP];
                break;
            } else if([self isNearPinPoint:pin tap:clickP]){
                self.touchingPin = pin;
                self.longClickTouchingPinFirst = PIN_FIRST_PIN;
                self.longClickTouching = YES;
                [self pinMovePoint:self.touchingPin:clickP];
                break;
            }
        }
        
    }
    else if(recognizer.state == UIGestureRecognizerStateChanged && self.longClickTouching) {
        if(self.longClickTouchingPinFirst == PIN_FIRST_PIN)
            [self pinMovePoint:self.touchingPin:clickP];
        else if(self.longClickTouchingPinFirst == PIN_FIRST_POINT) {
            if(self.touchingPin[@"toX"])
                [self pinMovePinWithoutToXY:self.touchingPin:clickP];
            else
                [self pinMovePinWithoutToXY:self.touchingPin:clickP];
        }
    }
    else if(recognizer.state == UIGestureRecognizerStateEnded && self.longClickTouching) {
        self.editingPin = self.touchingPin;
        [self complete];
        [self setMode:@"normal" : nil];
        [self hidePopup];
        self.longClickTouching = NO;
    }
}

-(void)onClickListener:(UIGestureRecognizer *)recognizer {
    CGPoint tappedPoint = [recognizer locationInView:self];
    if([@"normal" isEqualToString:self.mode]) {
        for(id pin in self.pinList) {
            if([self isNearPin:pin tap:tappedPoint]) {
                if(self.clickCallback){
                    self.clickCallback([@{@"key":pin[@"key"]} mutableCopy]);
                    return;
                }
            }
        }
        
        if(self.clickCallback)
            self.clickCallback([@{} mutableCopy]);
    } else if([@"new" isEqualToString:self.mode]) {
        
    } else if([self isPopupShow] && CGRectContainsPoint([WildCardUtil getGlobalFrame:self.popupView], tappedPoint)) {
        for(UIView* c in [self.popupView subviews]) {
            if(CGRectContainsPoint([WildCardUtil getGlobalFrame:c], tappedPoint)) {
                [self hidePopup];
                NSString* key = @"";
                if(c.tag == POPUP_TAG_CANCEL) {
                    [self setMode:@"normal" : nil];
                    key = @"취소";
                } else if(c.tag == POPUP_TAG_OK) {
                    [self complete];
                    key = @"완료";
                }
                
                if(self.actionCallback)
                    self.actionCallback([@{
                        @"mode": self.mode,
                        @"key" : key,
                    } mutableCopy]);
            }
        }
    } else if([@"edit" isEqualToString:self.mode]
              || ( self.editingPin && [@"new_direction" isEqualToString:self.mode])
              || ( self.editingPin && [@"can_complete" isEqualToString:self.mode])
              ) {
        
        CGPoint mp = [self clickToMapPoint:tappedPoint];
        BOOL inMap = CGRectContainsPoint([WildCardUtil getGlobalFrame:self.contentView], tappedPoint);
        if(inMap) {
            float ox = [self.editingPin[@"x"] floatValue];
            float oy = [self.editingPin[@"y"] floatValue];
            self.editingPin[@"x"] = [NSNumber numberWithFloat:mp.x];
            self.editingPin[@"y"] = [NSNumber numberWithFloat:mp.y];
            if(self.editingPin[@"toX"]) {
                self.editingPin[@"toX"] = [NSNumber numberWithFloat:[self.editingPin[@"toX"] floatValue] - (ox - mp.x)];
                self.editingPin[@"toY"] = [NSNumber numberWithFloat:[self.editingPin[@"toY"] floatValue] - (oy - mp.y)];
            }
            
            [self.pinLayer syncPinWithAnimation:self.editingPin[@"key"]];
            [self setMode:@"new_direction" : nil];
            [self showPopup:@[@"취소", @"완료"]];
        }
    }
}
-(void)showImage:(NSString*)url{
    if([url hasPrefix:@"http"]) {
        NSURLSessionConfiguration* configuration = [NSURLSessionConfiguration defaultSessionConfiguration];
        NSURLSession* session = [NSURLSession sessionWithConfiguration:configuration];
        NSURL *URL = [NSURL URLWithString:url];
        NSURLSessionDataTask* task = [session dataTaskWithURL:URL completionHandler:^(NSData * _Nullable data, NSURLResponse * _Nullable response, NSError * _Nullable error) {
            if(error) {
                
            } else {
                UIImage* image = [UIImage imageWithData:data];
                if(image != nil)
                    [self initializeWithImage:image];
            }
        }];
        [task resume];
    } else {
        NSString* path = [DevilUtil replaceUdidPrefixDir:url];
        NSData* mapData = [NSData dataWithContentsOfFile:path];
        UIImage* image = [UIImage imageWithData:mapData];
        [self initializeWithImage:image];
        
    }
    
}

-(void)initializeWithImage:(UIImage*) image {;
    [self.imageView setImage:image];
    //NSLog(@"%lu %f %f", (unsigned long)[mapData length] , image.size.width, image.size.height);
    
    _scrollView.contentSize = CGSizeMake(image.size.width, image.size.height);
    _pinLayer.frame = _contentView.frame = _imageView.frame = CGRectMake(0, 0, image.size.width, image.size.height);
    
    //float sw = [UIScreen mainScreen].bounds.size.width;
    float width_scale = self.frame.size.width/image.size.width;
    float height_scale = self.frame.size.height/image.size.height;
    
    float scale = self.scrollView.minimumZoomScale = width_scale;
    float min_inset_width = self.frame.size.width*0.0f;
    float min_inset_height = self.frame.size.height*0.0f + ( (self.frame.size.height- image.size.height*width_scale) / 2);
    
    if((self.frame.size.width / self.frame.size.height) > (image.size.width / image.size.height)) {
        scale = self.scrollView.minimumZoomScale = height_scale;
        min_inset_width = self.frame.size.width*0.0f + ( (self.frame.size.width - image.size.width*height_scale) / 2);
        min_inset_height = self.frame.size.height*0.0f;
    }
    _min_inset_width = min_inset_width;
    _min_inset_height = min_inset_height;
    
    self.scrollView.contentInset = UIEdgeInsetsMake(min_inset_height, min_inset_width, min_inset_height, min_inset_width);
    self.scrollView.contentOffset = CGPointMake(image.size.width/2*scale, image.size.height/2*scale);
    self.scrollView.zoomScale = scale;
    
    self.pinLayer.zoomScale = scale;
}

- (UIView *)hitTest:(CGPoint)point withEvent:(UIEvent *)event {
    UITouch *touch = [[event allTouches] anyObject];
    CGPoint clickP = point;
    if([self.mode isEqualToString:@"new"])
        return self;
    
    if([self.mode isEqualToString:@"new_direction"] || [self.mode isEqualToString:@"can_complete"]
       || [self.mode isEqualToString:@"edit"]
       ) {
        if(_editingPin) {
            self.touchingPin = _editingPin;
        } else {
            self.touchingPin = _insertingPin;
        }
        
        if([self isNearPin:self.touchingPin tap:clickP]) {
            self.shouldDirectionMove = YES;
            self.touchingPin[@"hideDirection"] = @FALSE;
            return self;
        }
    }
    
    return [super hitTest:point withEvent:event];
}

- (void)insertNewPin:(CGPoint)tappedPoint {
    CGPoint mp = [self clickToMapPoint:tappedPoint];
    BOOL inMap = CGRectContainsPoint([WildCardUtil getGlobalFrame:self.contentView], tappedPoint);
    if(inMap) {
        
        id p = [@{} mutableCopy];
        
        if(self.pinFirst == PIN_FIRST_PIN) {
            p[@"x"] = [NSNumber numberWithFloat:mp.x];
            p[@"y"] = [NSNumber numberWithFloat:mp.y];
            p[@"pinFirst"] = [NSNumber numberWithInt:PIN_FIRST_PIN];
        } else if(self.pinFirst == PIN_FIRST_POINT) {
            p[@"x"] = [NSNumber numberWithFloat:mp.x];
            p[@"y"] = [NSNumber numberWithFloat:mp.y];
            p[@"toX"] = [NSNumber numberWithFloat:mp.x];
            p[@"toY"] = [NSNumber numberWithFloat:mp.y];
            p[@"pinFirst"] = [NSNumber numberWithInt:PIN_FIRST_POINT];
        }
        
        p[@"hideDirection"] = @FALSE;
        
        p[@"key"] = @"10000";
        p[@"text"] = [NSString stringWithFormat:@"%lu", [self.pinList count]+1];
        if(self.param && self.param[@"text"])
            p[@"text"] = self.param[@"text"];
        
        if(self.param[@"color"])
            p[@"color"] = self.param[@"color"];
        else
            p[@"color"] = @"#90ff0000";
        
        p[@"degree"] = @0;
        p[@"arrowType"] = [NSNumber numberWithInt:self.arrowType];
        self.insertingPin = p;
        
        [self syncPin];
        
        if(![self.param[@"autoComplete"] boolValue])
            [self showPopup:@[@"취소"]];
        
        [self setMode:@"new_direction" : self.param];
        if(self.pinCallback)
            self.pinCallback([@{@"mode":self.mode} mutableCopy]);
    }
}

- (void)touchesBegan:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event {
    //NSLog(@"touchesBegan %d", [touches count]);
    UITouch *touch = [[event allTouches] anyObject];
    CGPoint clickP = [touch locationInView:self];
    self.touchStartTime = (double)[NSDate date].timeIntervalSince1970;
    if(self.pinFirst == PIN_FIRST_PIN) {
        if([self.mode isEqualToString:@"new"])
        {
            [self insertNewPin:clickP];
            self.mode = @"new_direction";
            if(_editingPin) {
                self.touchingPin = _editingPin;
            } else {
                self.touchingPin = _insertingPin;
            }
            
            if([self isNearPin:_insertingPin tap:clickP]) {
                self.shouldDirectionMove = YES;
                self.touchingPin[@"hideDirection"] = @FALSE;
            } else
                self.touchingPin[@"hideDirection"] = @TRUE;
        }
    } else if(self.pinFirst == PIN_FIRST_POINT) {
        if([self.mode isEqualToString:@"new"])
        {
            [self insertNewPin:clickP];
            self.mode = @"new_direction";
            if(_editingPin) {
                self.touchingPin = _editingPin;
            } else {
                self.touchingPin = _insertingPin;
            }
            
            self.shouldDirectionMove = YES;
            self.touchingPin[@"hideDirection"] = @FALSE;
        }
    }
    
}

- (float)distance:(CGPoint)a : (CGPoint)b {
    return sqrt(pow((a.x - b.x), 2) + pow((a.y - b.y), 2));
}

- (void)touchesMoved:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event {
    //    NSLog(@"touchesMoved");
    UITouch *touch = [[event allTouches] anyObject];
    CGPoint clickP = [touch locationInView:self];
    if(self.shouldDirectionMove &&
       ([self.mode isEqualToString:@"new_direction"] || [self.mode isEqualToString:@"can_complete"]
        || [self.mode isEqualToString:@"edit"])
       ) {
        
        if(self.pinFirst == PIN_FIRST_PIN)
            [self pinMovePoint:self.touchingPin:clickP];
        else if(self.pinFirst == PIN_FIRST_POINT) {
            [self pinMovePin:self.touchingPin:clickP];
        }
    }
}

- (void)pinMovePinWithoutToXY:(id)pin :(CGPoint)see {
    CGPoint touchMapPoint = [self clickToMapPoint:see];
    float ox = [pin[@"x"] floatValue];
    float oy = [pin[@"y"] floatValue];
    
    pin[@"x"] = [NSNumber numberWithFloat:touchMapPoint.x];
    pin[@"y"] = [NSNumber numberWithFloat:touchMapPoint.y];
    
    if(pin[@"toX"]) {
        float dx = touchMapPoint.x - ox;
        float dy = touchMapPoint.y - oy;
        float toX = [pin[@"toX"] floatValue] + dx;
        float toY = [pin[@"toY"] floatValue] + dy;
        pin[@"toX"] = [NSNumber numberWithFloat:toX];
        pin[@"toY"] = [NSNumber numberWithFloat:toY];
    }
    
    [_pinLayer updatePinDirection:pin[@"key"]];
}

- (void)pinMovePin:(id)pin :(CGPoint)see {
    CGPoint pinBodyScreenPoint = [self mapToClickPoint:CGPointMake([pin[@"toX"] floatValue], [pin[@"toY"] floatValue])];
    
    double r = atan2(pinBodyScreenPoint.y - see.y, pinBodyScreenPoint.x - see.x);
    double degree = r * 180 / M_PI  + 90;
    pin[@"degree"] = [NSNumber numberWithInt:(int)degree];
    CGPoint touchMapPoint = [self clickToMapPoint:see];
    
    CGPoint fromPoint = CGPointMake([pin[@"x"] floatValue], [pin[@"y"] floatValue]);
    CGPoint toPoint = CGPointMake([pin[@"toX"] floatValue], [pin[@"toY"] floatValue]);
    float distance = [DevilPinLayer distance:fromPoint :touchMapPoint];
    float toBeDistance = distance / 1.5;
    
    //최소길이 검사 후 적용
    if(toBeDistance < 29 / _scrollView.zoomScale) {
        toBeDistance = 29 / _scrollView.zoomScale;
    }
    
    touchMapPoint = [DevilPinLayer moveOnLineDistance:toPoint :touchMapPoint  :toBeDistance];
    //    NSLog(@"touchMapPoint (%i, %i)", (int)touchMapPoint.x, (int)touchMapPoint.y);
    
    pin[@"x"] = [NSNumber numberWithFloat:touchMapPoint.x];
    pin[@"y"] = [NSNumber numberWithFloat:touchMapPoint.y];
    
    [_pinLayer updatePinDirection:pin[@"key"]];
}

- (void)pinMovePoint:(id)pin :(CGPoint)see {
    CGPoint pinScreenPoint = [self pinToScreenPoint:pin];
    double r = atan2(see.y - pinScreenPoint.y, see.x - pinScreenPoint.x);
    double degree = r * 180 / M_PI  + 90;
    //NSLog(@"degree - %f", degree);
    pin[@"degree"] = [NSNumber numberWithInt:(int)degree];
    
    CGPoint touchMapPoint = [self clickToMapPoint:see];
    
    CGPoint fromPoint = CGPointMake([pin[@"x"] floatValue], [pin[@"y"] floatValue]);
    float distance = [DevilPinLayer distance:fromPoint :touchMapPoint];
    float toBeDistance = distance/1.5;
    
    
    //최소길이 검사 후 적용
    if(toBeDistance < 29 / _scrollView.zoomScale) {
        toBeDistance = 29 / _scrollView.zoomScale;
    }
    
    touchMapPoint = [DevilPinLayer moveOnLineDistance:fromPoint :touchMapPoint :toBeDistance];
    //    NSLog(@"touchMapPoint (%i, %i)", (int)touchMapPoint.x, (int)touchMapPoint.y);
    pin[@"toX"] = [NSNumber numberWithFloat:touchMapPoint.x];
    pin[@"toY"] = [NSNumber numberWithFloat:touchMapPoint.y];
    
    
    //최소시간 검사 후 적용
    double now = (double)[NSDate date].timeIntervalSince1970;
    if(now - self.touchStartTime < self.pinModeChangeTime) {
        pin[@"toX"] = pin[@"toY"] = nil;
    }
    
    [_pinLayer updatePinDirection:pin[@"key"]];
}

- (void)touchesEnded:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event {
    //    NSLog(@"touchesEnded");
    UITouch *touch = [[event allTouches] anyObject];
    CGPoint clickP = [touch locationInView:self];
    if([self.mode isEqualToString:@"new_direction"] || [self.mode isEqualToString:@"can_complete"]
       || [self.mode isEqualToString:@"edit"]) {
        if([self.param[@"autoComplete"] boolValue]) {
            [self complete];
            [self setMode:@"normal" : nil];
            self.shouldDirectionMove = false;
            [self hidePopup];
            if(self.actionCallback)
                self.actionCallback([@{
                    @"mode": self.mode,
                    @"key" : @"완료",
                } mutableCopy]);
        } else {
            [self setMode:@"can_complete" : nil];
            self.shouldDirectionMove = false;
            [self hidePopup];
            [self showPopup:@[@"취소", @"완료"]];
            if (self.directionCallback)
                self.directionCallback([@{@"mode":self.mode} mutableCopy]);
        }
    }
}


-(void)syncPin {
    id children = [self.contentView subviews];
    for(id child in children) {
        if(child != self.imageView && child != self.popupView  && child != _pinLayer)
            [child removeFromSuperview];
    }
    
    _pinLayer.pinList = [self.pinList mutableCopy];
    if(self.insertingPin)
        [_pinLayer.pinList addObject:self.insertingPin];
    
    [_pinLayer setNeedsDisplay];
    [_pinLayer syncPin];
}

- (void)scrollViewDidScroll:(UIScrollView *)scrollView {
    //    NSLog(@"scrollViewDidScroll");
    [self updatePopupPoint];
}

- (void)scrollViewWillBeginDragging:(UIScrollView *)scrollView {
    //    NSLog(@"scrollViewWillBeginDragging");
}

- (UIView *)viewForZoomingInScrollView:(UIScrollView *)scrollView {
    return self.contentView;
}

- (void)scrollViewDidZoom:(UIScrollView *)scrollView {
    //    NSLog(@"scrollViewDidZoom %f", scrollView.zoomScale);
    
    [_pinLayer updateZoom:scrollView.zoomScale];
    //    _pinLayer.zoomScale = scrollView.zoomScale;
    //    [_pinLayer setNeedsDisplay];
    
    float z = scrollView.zoomScale;
    id children = [self.contentView subviews];
    int index = 0;
    for(id child in children) {
        if(child != self.imageView && child != self.popupView  && child != _pinLayer) {
            id pin;
            if(index < [self.pinList count])
                pin = self.pinList[index];
            else
                pin = self.insertingPin;
            
            UIView* pv = child;
            CGPoint p = pv.center;
            pv.frame = CGRectMake(0, 0, circleWidth / z, circleWidth / z);
            pv.center = p;
            
            UIImageView* pi = [pv viewWithTag:4421];
            float angle = [pin[@"degree"] floatValue];
            float radians = angle / 180.0 * M_PI;
            pi.layer.anchorPoint = CGPointMake(0.5, 0.5);
            pi.transform = CGAffineTransformMakeRotation(0);
            pi.frame = CGRectMake(0, 0, circleWidth/z, circleWidth/z);
            pi.transform = CGAffineTransformMakeRotation(radians);
            
            UILabel* text = [pv viewWithTag:4425];
            text.frame = CGRectMake(0, 0, circleWidth/z, circleWidth/z);
            text.transform = CGAffineTransformMakeScale(1.0f/z, 1.0f/z);
            
            index ++;
        }
    }
    
    [self updatePopupPoint];
}

- (void)callback:(NSString*)command :(void (^)(id res))callback{
    if([command isEqualToString:@"pin"])
        self.pinCallback = callback;
    else if([command isEqualToString:@"direction"])
        self.directionCallback = callback;
    else if([command isEqualToString:@"complete"])
        self.completeCallback = callback;
    else if([command isEqualToString:@"action"])
        self.actionCallback = callback;
    else if([command isEqualToString:@"click"])
        self.clickCallback = callback;
}

- (void)relocation:(NSString*)key {
    for(id pin in self.pinList) {
        if([key isEqualToString:pin[@"key"]]) {
            self.editingPin = pin;
            [self setMode:@"edit": nil];
            [self focus:pin[@"key"]];
            [self.pinLayer highlight:pin[@"key"]];
            break;
        }
    }
}

- (void)setMode:(NSString*)mode :(id)param {
    if([@"normal" isEqualToString:mode]) {
        [_pinLayer.pinList removeObject:self.insertingPin];
        self.editingPin = self.insertingPin = nil;
        [self.pinLayer highlight:nil];
    }
    self.mode = mode;
    self.param = param;
}

- (void)config:(id)param {
    if(param[@"pinModeChangeTime"]) {
        self.pinModeChangeTime = [param[@"pinModeChangeTime"] intValue] / 1000.0f;
    } else
        self.pinModeChangeTime = 1.0f;
    
    if(param[@"minPinSizeScale"])
        self.pinLayer.minPinSizeScale = [param[@"minPinSizeScale"] floatValue];
    else
        self.pinLayer.minPinSizeScale = 10000;
    
    if([@"round" isEqualToString:param[@"arrowType"]])
        self.arrowType = ARROW_TYPE_ROUND;
    else
        self.arrowType = ARROW_TYPE_ARROW;
    
    if([@"pin" isEqualToString:param[@"pinFirst"]])
        self.pinFirst = PIN_FIRST_PIN;
    else if([@"point" isEqualToString:param[@"pinFirst"]])
        self.pinFirst = PIN_FIRST_POINT;
    
    if(param[@"longClickToMove"])
        self.longClickToMove = [param[@"longClickToMove"] boolValue];
    
    if(param[@"longClickKeyList"])
        self.longClickKeyList = param[@"longClickKeyList"];
}

- (void)complete {
    if(self.insertingPin) {
        id pin = self.insertingPin;
        [self hidePopup];
        _insertingPin = nil;
        [self setMode:@"normal" : nil];
        if(self.completeCallback)
            self.completeCallback([@{
                @"list":self.pinList,
                @"type":@"new",
                @"pin":pin,
            } mutableCopy]);
    } else if (self.editingPin) {
        id pin = self.editingPin;
        self.editingPin = nil;
        [self hidePopup];
        [self setMode:@"normal":nil];
        if(self.completeCallback)
            self.completeCallback([@{
                @"list":self.pinList,
                @"type":@"edit",
                @"pin":pin,
            } mutableCopy]);
    }
}

-(void)hidePopup {
    if(self.popupView) {
        [self.popupView removeFromSuperview];
        self.popupView = nil;
    }
}

-(CGPoint)centerOfRect:(CGRect)rect {
    float x = rect.origin.x + rect.size.width/2;
    float y = rect.origin.y + rect.size.height/2;
    return CGPointMake(x, y);
}

-(void)updatePopupPoint {
    if(self.popupView) {
        
        CGPoint screenPoint;
        if(_insertingPin) {
            screenPoint = [self pinToScreenPoint:_insertingPin];
        } else if(_editingPin) {
            screenPoint = [self pinToScreenPoint:_editingPin];
        }
            
        float gap = 27;
        float x = screenPoint.x + gap;
        float y = screenPoint.y - (35*2)/2;
        self.popupView.frame = CGRectMake(x, y, self.popupView.frame.size.width, self.popupView.frame.size.height);
    }
}
-(void)showPopup:(id)selection {
    
    [self hidePopup];
    
    float pw = 35;
    float ph = 35;
    float gap = 5;
    
    UIView* popup = [[UIView alloc] initWithFrame:CGRectMake(0, 0, pw,
                                                             ph * [selection count] + gap*([selection count]-1)
                                                             )];
    popup.backgroundColor = [UIColor clearColor];
    
//    popup.backgroundColor = [UIColor whiteColor];
//    popup.layer.cornerRadius = 5;
//    popup.layer.shadowOffset = CGSizeMake(5, 5);
//    popup.layer.shadowRadius = 5;
//    popup.layer.shadowOpacity = [WildCardUtil alphaWithHexString:@"#90000000"];
//    popup.layer.shadowColor = [WildCardUtil colorWithHexString:@"#90000000"].CGColor;
    
    int index = 0;
    NSBundle *bundle = [NSBundle bundleForClass:[self class]];
    for(NSString* s in selection) {
//        UILabel* text = [[UILabel alloc] initWithFrame:CGRectMake(0, index*ph, pw, ph)];
//        text.font = [UIFont boldSystemFontOfSize:20];
//        text.textColor = [WildCardUtil colorWithHexString:@"#333333"];
//        text.text = s;
//        text.textAlignment = NSTextAlignmentCenter;
//        [popup addSubview:text];
        
        
        
        float bh = ph*0.8f;
        UIView* button = [[UIView alloc] initWithFrame:CGRectMake(0, 0, bh, bh)];
        button.center = CGPointMake(pw/2, index*ph + ph/2 + gap*(index-1));
        button.backgroundColor = [UIColor whiteColor];
        button.layer.cornerRadius = bh/2;
        button.layer.shadowOffset = CGSizeMake(5, 5);
        button.layer.shadowRadius = 5;
        button.layer.shadowOpacity = [WildCardUtil alphaWithHexString:@"#90000000"];
        button.layer.shadowColor = [WildCardUtil colorWithHexString:@"#90000000"].CGColor;

        NSString* imageName = @"";
        if([@"취소" isEqualToString:s]) {
            button.tag = POPUP_TAG_CANCEL;
            imageName = @"devil_imagemap_cancel";
        } else {
            button.tag = POPUP_TAG_OK;
            imageName = @"devil_imagemap_ok";
        }
        
        UIImage* image = [UIImage imageNamed:imageName inBundle:bundle compatibleWithTraitCollection:nil];
        UIImageView* imageView = [[UIImageView alloc] initWithImage:image];
        imageView.backgroundColor = [UIColor whiteColor];
        imageView.center = CGPointMake(bh/2, bh/2);
        [button addSubview:imageView];
        
         
        [popup addSubview:button];
        index ++;
    }
    [self addSubview:popup];
    self.popupView = popup;
    [self updatePopupPoint];
}

-(BOOL)isPopupShow {
    return self.popupView != nil;
}

-(void)focus:(NSString*)key {
    @try{
        id pin = nil;
        for(id p in self.pinList) {
            if([p[@"key"] isEqualToString:key]) {
                pin = p;
                break;
            }
        }
        
        if(pin == nil)
            @throw [NSException exceptionWithName:@"Devil Image Map" reason:[NSString stringWithFormat:@"Key not found - %@", key] userInfo:nil];
        
        float sw = self.scrollView.frame.size.width;
        float sh = self.scrollView.frame.size.height;
        
        float x = ([pin[@"x"] floatValue]) * self.scrollView.zoomScale - sw/2;
        float y = ([pin[@"y"] floatValue]) * self.scrollView.zoomScale - sh/2;

        if(x < -_min_inset_width)
            x = -_min_inset_width;
        if(y < -_min_inset_height)
            y = -_min_inset_height;
        
        float max_x = self.scrollView.contentSize.width - sw;
        float max_y = self.scrollView.contentSize.height - sh;

        if(x > max_x)
            x = max_x;
//        if(y > max_y)
//            y = max_y;
        
        [self.scrollView setContentOffset:CGPointMake(x, y) animated:YES];
    }@catch(NSException* e) {
        [DevilExceptionHandler handle:e];
    }
}

- (void)scrollViewDidEndDragging:(UIScrollView *)scrollView willDecelerate:(BOOL)decelerate {
//    NSLog(@"contentOffset (%f, %f) %f contentSize (%f, %f)", _scrollView.contentOffset.x, _scrollView.contentOffset.y , _scrollView.zoomScale, _scrollView.contentSize.width, _scrollView.contentSize.height );
}

@end
