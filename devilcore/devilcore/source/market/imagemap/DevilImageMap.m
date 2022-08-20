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
#include <math.h>

@interface DevilImageMap()<UIScrollViewDelegate>
@property (nonatomic, retain) UIImageView* imageView;
@property (nonatomic, retain) UIView* contentView;
@property (nonatomic, retain) UIScrollView* scrollView;
@property (nonatomic, retain) UITapGestureRecognizer * singleFingerTap;
@property (nonatomic, retain) UIImage* pointerImage;
@property (nonatomic, retain) NSString* mode;
@property (nonatomic, retain) id param;
@property (nonatomic, retain) id editingPin;
@property (nonatomic, retain) id insertingPin;
@property (nonatomic, retain) UIView* editingPinView;
@property (nonatomic, retain) UIView* insertingPinView;
@property (nonatomic, retain) id touchingPin;
@property (nonatomic, retain) UIView* touchingPinView;
@property BOOL shouldDirectionMove;

@property (nonatomic, retain) UIView* popupView;


@property void (^pinCallback)(id res);
@property void (^directionCallback)(id res);
@property void (^completeCallback)(id res);
@property void (^actionCallback)(id res);
@property void (^clickCallback)(id res);


@end

@implementation DevilImageMap

float circleWidth = 70;
float borderWidth = 7;

-(void)construct {
    self.imageView = [[UIImageView alloc] init];
    self.imageView.userInteractionEnabled = NO;
    
    float sw = [UIScreen mainScreen].bounds.size.width;
    float sh = [UIScreen mainScreen].bounds.size.height;
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
    [WildCardConstructor followSizeFromFather:self child:self.scrollView];
    
    _singleFingerTap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(onClickListener:)];
    [self addGestureRecognizer:_singleFingerTap];

    NSBundle *bundle = [NSBundle bundleForClass:[self class]];
    self.pointerImage = [UIImage imageNamed:@"devil_imagemap_pointer.png" inBundle:bundle compatibleWithTraitCollection:nil];

    self.mode = @"normal";
}

-(void)onClickListener:(UIGestureRecognizer *)recognizer {
    NSLog(@"onClickListener");
    CGPoint tappedPoint = [recognizer locationInView:self];
    id children = [self.contentView subviews];
    int index = 0;
    if([@"normal" isEqualToString:self.mode]) {
        for(UIView* child in children) {
            if(child != self.imageView && child != self.popupView) {
                id pin = _pinList[index];
                CGRect childRect = [WildCardUtil getGlobalFrame:child];
                if(CGRectContainsPoint(childRect, tappedPoint)) {
                    if(self.clickCallback)
                        self.clickCallback([@{@"key":pin[@"key"]} mutableCopy]);
                    break;
                }
                
                index++;
            }
        }
    } else if([@"new" isEqualToString:self.mode]) {
        CGPoint mp = [self clickToMapPoint:tappedPoint];
        BOOL inMap = CGRectContainsPoint([WildCardUtil getGlobalFrame:self.contentView], tappedPoint);
        if(inMap) {
            id p = [@{} mutableCopy];
            p[@"x"] = [NSNumber numberWithFloat:mp.x];
            p[@"y"] = [NSNumber numberWithFloat:mp.y];
            p[@"key"] = @"10000";
            p[@"text"] = [NSString stringWithFormat:@"%d", [self.pinList count]+1];
            if(self.param && self.param[@"text"])
                p[@"text"] = self.param[@"text"];

            p[@"color"] = @"#90ff0000";
            p[@"degree"] = @0;
            p[@"hideDirection"] = @TRUE;
            self.insertingPin = p;
            
            [self syncPin];
            
            [self setMode:@"new_direction" : nil];
            
            [self showPopup:tappedPoint :@[@"취소"]];
            
            if(self.pinCallback)
                self.pinCallback([@{@"mode":self.mode} mutableCopy]);
        }
        
    } else if([@"edit" isEqualToString:self.mode]) {
        
    } else if([self isPopupShow] && CGRectContainsPoint([WildCardUtil getGlobalFrame:self.popupView], tappedPoint)) {
        for(UILabel* c in [self.popupView subviews]) {
            if(CGRectContainsPoint([WildCardUtil getGlobalFrame:c], tappedPoint)) {
                if([@"취소" isEqualToString:c.text]) {
                    [self setMode:@"normal" : nil];
                    [self hidePopup];
                } else if([@"완료" isEqualToString:c.text]) {
                    [self complete];
                }
                
                if(self.actionCallback)
                    self.actionCallback([@{
                        @"mode": self.mode,
                        @"key" : c.text,
                    } mutableCopy]);
            }
        }
    }
}

-(CGPoint)clickToMapPoint:(CGPoint)p {
    return [self convertPoint:p toView:self.contentView];
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
    _contentView.frame = _imageView.frame = CGRectMake(0, 0, image.size.width, image.size.height);
    
    //float sw = [UIScreen mainScreen].bounds.size.width;
    float width_scale = self.frame.size.width/image.size.width;
    float height_scale = self.frame.size.height/image.size.height;
    
    float scale = self.scrollView.minimumZoomScale = width_scale;
    float min_inset_width = self.frame.size.width*0.1f;
    float min_inset_height = self.frame.size.height*0.1f + ( (self.frame.size.height- image.size.height*width_scale) / 2);
    
    if((self.frame.size.width / self.frame.size.height) > (image.size.width / image.size.height)) {
        scale = self.scrollView.minimumZoomScale = height_scale;
        min_inset_width = self.frame.size.width*0.1f + ( (self.frame.size.width - image.size.width*height_scale) / 2);
        min_inset_height = self.frame.size.height*0.1f;
    }
    
    self.scrollView.contentInset = UIEdgeInsetsMake(min_inset_height, min_inset_width, min_inset_height, min_inset_width);
    
    self.scrollView.contentOffset = CGPointMake(image.size.width/2*scale, image.size.height/2*scale);
    self.scrollView.zoomScale = scale;
}

- (UIView *)hitTest:(CGPoint)point withEvent:(UIEvent *)event {
    
    UITouch *touch = [[event allTouches] anyObject];
    CGPoint clickP = point;
    if([self.mode isEqualToString:@"new_direction"] || [self.mode isEqualToString:@"can_complete"]) {
        if(_editingPin) {
            self.touchingPin = _editingPin;
            self.touchingPinView = _editingPinView;
        } else {
            self.touchingPin = _insertingPin;
            self.touchingPinView = _insertingPinView;
        }
        
        UIView* rootView = [UIApplication sharedApplication].keyWindow.rootViewController.view;
        CGPoint pinViewP = [self.touchingPinView.superview convertPoint:self.touchingPinView.center toView:rootView];
        if([self distance:clickP:pinViewP] < circleWidth) {
            self.shouldDirectionMove = YES;
            self.touchingPin[@"hideDirection"] = @FALSE;
            return self;
        }
    }
    
    
    return [super hitTest:point withEvent:event];
}

- (void)touchesBegan:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event {
    NSLog(@"touchesBegan");
    UITouch *touch = [[event allTouches] anyObject];
    CGPoint clickP = [touch locationInView:self];
    if([self.mode isEqualToString:@"new_direction"] || [self.mode isEqualToString:@"can_complete"]) {
        if(_editingPin) {
            self.touchingPin = _editingPin;
            self.touchingPinView = _editingPinView;
        } else {
            self.touchingPin = _insertingPin;
            self.touchingPinView = _insertingPinView;
        }
        
        UIView* rootView = [UIApplication sharedApplication].keyWindow.rootViewController.view;
        CGPoint pinViewP = [self.touchingPinView.superview convertPoint:self.touchingPinView.center toView:rootView];
        if([self distance:clickP:pinViewP] < circleWidth) {
            self.shouldDirectionMove = YES;
            self.touchingPin[@"hideDirection"] = @FALSE;
        }
    }
}

    
- (float)distance:(CGPoint)a : (CGPoint)b {
    return sqrt(pow((a.x - b.x), 2) + pow((a.y - b.y), 2));
}

- (void)touchesMoved:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event {
    NSLog(@"touchesMoved");
    UITouch *touch = [[event allTouches] anyObject];
    CGPoint clickP = [touch locationInView:self];
    if(self.shouldDirectionMove && ([self.mode isEqualToString:@"new_direction"] || [self.mode isEqualToString:@"can_complete"])) {
        [self pinDirection:self.touchingPin :self.touchingPinView :clickP];
    }
}

- (void)pinDirection:(id)pin : (UIView*)pinView :(CGPoint)see {
    UIView* rootView = [UIApplication sharedApplication].keyWindow.rootViewController.view;
    CGPoint pinViewP = [pinView.superview convertPoint:pinView.center toView:rootView];
    double r = atan2(see.y - pinViewP.y, see.x - pinViewP.x);
    double degree = r * 180 / M_PI;
    NSLog(@"degree - %f", degree);
    pin[@"degree"] = [NSNumber numberWithInt:(int)degree];
    [pinView viewWithTag:4421].transform = CGAffineTransformMakeRotation(r + M_PI/2);
}

- (void)touchesEnded:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event {
    NSLog(@"touchesEnded");
    UITouch *touch = [[event allTouches] anyObject];
    CGPoint clickP = [touch locationInView:self];
    if([self.mode isEqualToString:@"new_direction"] || [self.mode isEqualToString:@"can_complete"]) {
        [self setMode:@"can_complete" : nil];
        self.shouldDirectionMove = false;
        [self hidePopup];
        UIView* rootView = [UIApplication sharedApplication].keyWindow.rootViewController.view;
        CGPoint pinViewP = [self.touchingPinView.superview convertPoint:self.touchingPinView.center toView:rootView];
        [self showPopup:pinViewP :@[@"취소", @"완료"]];
        if (self.directionCallback)
            self.directionCallback([@{@"mode":self.mode} mutableCopy]);
    }
}

-(UIView*)addPinView:(id)pin {
    float z = self.scrollView.zoomScale;
    UIView* pv = [[UIView alloc] init];
    pv.frame = CGRectMake(0, 0, circleWidth/z, circleWidth/z);
    pv.center = CGPointMake([pin[@"x"] floatValue], [pin[@"y"] floatValue]);
    
//            pv.layer.borderWidth = borderWidth;
//            pv.layer.borderColor = [UIColor blueColor].CGColor;
    
    UIImageView* pi = [[UIImageView alloc] initWithImage:self.pointerImage];
    pi.tag = 4421;
    pi.image = [pi.image imageWithRenderingMode:UIImageRenderingModeAlwaysTemplate];
    pi.frame = CGRectMake(0, 0, circleWidth/z, circleWidth/z);
    pi.tintColor = [WildCardUtil colorWithHexString:pin[@"color"]];
    
    float angle = [pin[@"degree"] floatValue];
    float radians = angle / 180.0 * M_PI;
    pi.layer.anchorPoint = CGPointMake(0.5, 0.5);
    pi.transform = CGAffineTransformMakeRotation(radians);
    [pv addSubview:pi];
    
    UILabel* text = [[UILabel alloc] initWithFrame:CGRectMake(0, 0, circleWidth/z, circleWidth/z)];
    text.font = [UIFont boldSystemFontOfSize:20];
    text.tag = 4425;
    text.textColor = [UIColor blackColor];
    text.text = pin[@"text"];
    text.textAlignment = NSTextAlignmentCenter;
    text.transform = CGAffineTransformMakeScale(1.0f/z, 1.0f/z);
    [pv addSubview:text];
    
    [_contentView addSubview:pv];
    
    return pv;
}

-(void)syncPin {
    id children = [self.contentView subviews];
    for(id child in children) {
        if(child != self.imageView && child != self.popupView)
           [child removeFromSuperview];
    }
    if(self.pinList) {
        for(id pin in self.pinList) {
            [self addPinView:pin];
        }
        if(self.insertingPin) {
            self.insertingPinView = [self addPinView:self.insertingPin];
        }
    }
}


-(void)drawLayer:(CALayer *)layer inContext:(CGContextRef)ctx {
    [super drawLayer:layer inContext:ctx];
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
    
    float z = scrollView.zoomScale;
    id children = [self.contentView subviews];
    int index = 0;
    for(id child in children) {
        if(child != self.imageView && child != self.popupView) {
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
    
}

- (void)setMode:(NSString*)mode :(id)param {
    if([@"normal" isEqualToString:mode]) {
        self.editingPin = self.insertingPin = nil;
    }
    self.mode = mode;
    self.param = param;
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
        
    }
}

-(void)hidePopup {
    [self.popupView removeFromSuperview];
    self.popupView = nil;
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
            screenPoint = [self centerOfRect:[WildCardUtil getGlobalFrame:_insertingPinView]];
        } else if(_editingPin) {
            screenPoint = [self centerOfRect:[WildCardUtil getGlobalFrame:_editingPinView]];
        }
            
        float pw = 90;
        float ph = 50;
        float gap = 30;
        float x = screenPoint.x + gap;
        float y = screenPoint.y;
        float sw = [UIScreen mainScreen].bounds.size.width;
//        if(x > sw - pw)
//            x = screenPoint.x - pw - gap;
        self.popupView.frame = CGRectMake(x, y, self.popupView.frame.size.width, self.popupView.frame.size.height);
    }
}
-(void)showPopup:(CGPoint)screenPoint :(id)selection {
    float pw = 90;
    float ph = 50;
    float gap = 30;
    
    UIView* popup = [[UIView alloc] initWithFrame:CGRectMake(0, 0, pw, ph * [selection count] )];
    popup.backgroundColor = [UIColor whiteColor];
    popup.layer.cornerRadius = 5;
    popup.layer.shadowOffset = CGSizeMake(5, 5);
    popup.layer.shadowRadius = 5;
    popup.layer.shadowOpacity = [WildCardUtil alphaWithHexString:@"#90000000"];
    popup.layer.shadowColor = [WildCardUtil colorWithHexString:@"#90000000"].CGColor;
    
    int index = 0;
    for(NSString* s in selection) {
        UILabel* text = [[UILabel alloc] initWithFrame:CGRectMake(0, index*ph, pw, ph)];
        text.font = [UIFont boldSystemFontOfSize:20];
        text.textColor = [WildCardUtil colorWithHexString:@"#333333"];
        text.text = s;
        text.textAlignment = NSTextAlignmentCenter;
        [popup addSubview:text];
        index ++;
    }
    [self addSubview:popup];
    self.popupView = popup;
    [self updatePopupPoint];
}

-(BOOL)isPopupShow {
    return self.popupView != nil;
}
@end
