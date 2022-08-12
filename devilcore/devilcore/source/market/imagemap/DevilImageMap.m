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

@property void (^pinCallback)(id res);
@property void (^directionCallback)(id res);
@property void (^completeCallback)(id res);
@property void (^actionCallback)(id res);
@property void (^clickCallback)(id res);


@end

@implementation DevilImageMap

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
    for(UIView* child in children) {
        if(child != self.imageView) {
            id pin = _pinList[index];
            CGRect childRect = [WildCardUtil getGlobalFrame:child];
            
            BOOL click = tappedPoint.x >= childRect.origin.x &&
            tappedPoint.x <= childRect.origin.x + childRect.size.width &&
            tappedPoint.y >= childRect.origin.y &&
            tappedPoint.y <= childRect.origin.y + childRect.size.height;
            
            if(click) {
                if(self.clickCallback)
                    self.clickCallback([@{@"key":pin[@"key"]} mutableCopy]);
                break;
            }
            
            index++;
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
                [self initializeWithImage:image];
            }
        }];
        [task resume];
    } else {
        //ios document path 가 매번 달라진다
        NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
        NSString *documentsDirectory = paths[0];
        NSString* fileName = [DevilUtil getFileName:url];
        NSString* ext = [DevilUtil getFileExt:url];
        NSString *path = [documentsDirectory stringByAppendingFormat:@"/%@.%@", fileName, ext];
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
    
    float sw = [UIScreen mainScreen].bounds.size.width;
    float scale = self.scrollView.minimumZoomScale = sw/image.size.width;
    self.scrollView.contentInset = UIEdgeInsetsMake(sw/2, 0, sw/2, 0);
    
    self.scrollView.contentOffset = CGPointMake(image.size.width/2*scale, image.size.height/2*scale);
    self.scrollView.zoomScale = scale;
}

- (UIView *)hitTest:(CGPoint)point withEvent:(UIEvent *)event {
//    NSLog(@"hitTest");
    if([@"normal" isEqualToString:self.mode])
        return [super hitTest:point withEvent:event];
    else
        return self;
}

- (void)touchesBegan:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event {
    NSLog(@"touchesBegan");
    UITouch *touch = [[event allTouches] anyObject];
    CGPoint touchPoint = [touch locationInView:self];
}
- (void)touchesMoved:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event {
    NSLog(@"touchesMoved");
    UITouch *touch = [[event allTouches] anyObject];
    CGPoint touchPoint = [touch locationInView:self];
}
- (void)touchesEnded:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event {
    NSLog(@"touchesEnded");
    UITouch *touch = [[event allTouches] anyObject];
    CGPoint touchPoint = [touch locationInView:self];
}

float circleWidth = 70;
float borderWidth = 7;

-(void)syncPin {
    id children = [self.contentView subviews];
    for(id child in children) {
        if(child != self.imageView)
           [child removeFromSuperview];
    }
    float z = self.scrollView.zoomScale;
    if(self.pinList) {
        for(id pin in self.pinList) {
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
            
        }
    }
}


-(void)drawLayer:(CALayer *)layer inContext:(CGContextRef)ctx {
    [super drawLayer:layer inContext:ctx];
}

- (void)scrollViewDidScroll:(UIScrollView *)scrollView {
//    NSLog(@"scrollViewDidScroll");
}

- (void)scrollViewWillBeginDragging:(UIScrollView *)scrollView {
    NSLog(@"scrollViewWillBeginDragging");
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
        if(child != self.imageView) {
            id pin = self.pinList[index];
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
        id pin = [@{
//            @"x": _insertingPin.location.x,
//            @"y": _insertingPin.location.x,
//            @"degree": _insertingPin.location.x,
//            @"key": _insertingPin.location.x,
//            @"text": _insertingPin.location.x,
//            @"color": _insertingPin.location.x,
        } mutableCopy];
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
    
}
@end
