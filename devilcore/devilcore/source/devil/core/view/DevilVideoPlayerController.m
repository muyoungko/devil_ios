//
//  DevilVideoPlayerController.m
//  devilcore
//
//  Created by Mu Young Ko on 2023/08/08.
//

#import "DevilVideoPlayerController.h"
#import "DevilUtil.h"
#import "JevilInstance.h"
#import "DevilController.h"
#import "DevilSdk.h"

#define BAR_HEIGHT 6
#define HEIGHT 50

@interface DevilVideoPlayerController()<UIGestureRecognizerDelegate>

@property(nonatomic, retain) UIView *bottom_bg;
@property(nonatomic, retain) UIView *bar;
@property(nonatomic, retain) UIView *bar_bg;
@property(nonatomic, retain) UILabel *time_text;
@property(nonatomic, retain) UILabel *time_text_max;
@property(nonatomic, retain) UIButton *full_button;
@property int last_current;
@property int last_duration;
@property BOOL is_full_screen;

@property BOOL before_navigationbar_hidden;
@property (nonatomic, retain) id before_view_info_list;

@property (nonatomic, assign) CGPoint lastPanPoint;
@property BOOL dragging;
@property int dragging_sec;

@property (nonatomic, retain) UIPinchGestureRecognizer *pinchRecognizer;

@end


@implementation DevilVideoPlayerController


-(id)initWithFrame:(CGRect)frame {
    self = [super initWithFrame:CGRectMake(0, 0, 0, 0)];
    
    _bottom_bg = [[UIView alloc] init];
    [self addSubview:_bottom_bg];
    _bottom_bg.backgroundColor = UIColorFromRGBA(0x90000000);
    [self bottomLayout];
    
    _is_full_screen = NO;
    
    _time_text = [[UILabel alloc] initWithFrame:CGRectMake(0, 0, 50, HEIGHT)];
    _time_text.textColor = [UIColor whiteColor];
    _time_text.text = @"00:00";
    _time_text.textAlignment = NSTextAlignmentRight;
    _time_text.font = [UIFont systemFontOfSize:15.0f];
    [_bottom_bg addSubview:_time_text];
    
    
    _time_text_max = [[UILabel alloc] initWithFrame:CGRectMake(_time_text.frame.size.width, 0, 60, HEIGHT)];
    _time_text_max.textColor = [UIColor whiteColor];
    _time_text_max.text = @" / 00:00";
    _time_text_max.textAlignment = NSTextAlignmentLeft;
    _time_text_max.font = [UIFont systemFontOfSize:15.0f];
    [_bottom_bg addSubview:_time_text_max];
    
    NSBundle *bundle = [NSBundle bundleForClass:[self class]];
    
    UIImage* _full_button_image = [[UIImage imageNamed:@"devil_video_full_screen" inBundle:bundle compatibleWithTraitCollection:nil] imageWithRenderingMode:UIImageRenderingModeAlwaysTemplate];
    
    _full_button = [[UIButton alloc] init];
    _full_button.translatesAutoresizingMaskIntoConstraints = NO;
    [_full_button setImage:_full_button_image forState:UIControlStateNormal];
    _full_button.tintColor = [UIColor whiteColor];
    [_full_button addTarget:self action:@selector(full_click:) forControlEvents:UIControlEventTouchUpInside];
    [_bottom_bg addSubview:_full_button];
    [self fullButtonLayout];
    
    _bar_bg = [[UIView alloc] init];
    [_bottom_bg addSubview:_bar_bg];
    _bar_bg.backgroundColor = UIColorFromRGB(0x999999);
    [self barBgLayout];
    
    _bar = [[UIView alloc] initWithFrame:CGRectMake(0, 0, 0, BAR_HEIGHT)];
    [_bar_bg addSubview:_bar];
    _bar.backgroundColor = UIColorFromRGB(0xFF0000);
    
    UIPanGestureRecognizer *panGestureRecognizer = [[UIPanGestureRecognizer alloc] initWithTarget:self action:@selector(handlePan:)];
    [_bottom_bg addGestureRecognizer:panGestureRecognizer];
    
    self.pinchRecognizer = [[UIPinchGestureRecognizer alloc] initWithTarget:self action:@selector(handlePinch:)];
    self.pinchRecognizer.delegate = self;
    [self addGestureRecognizer:self.pinchRecognizer];
    
    return self;
}

- (void)handlePinch:(UIPinchGestureRecognizer *)gestureRecognizer {
    CGFloat scale = gestureRecognizer.scale;
    UIView* v = _zoomView;
    CGPoint point = [gestureRecognizer locationInView:self];
    
    // 스케일 값을 최소와 최대 값 사이로 제한
//    CGFloat newScale = v.transform.a * scale;
    if(scale < 1)
        scale = 1;
    if(scale > 3)
        scale = 3;

    
    CGAffineTransform newTransform = CGAffineTransformMakeScale(scale, scale);
    CGFloat deltaX = (v.center.x - point.x)/2 * (scale-1) / scale;
    CGFloat deltaY = (v.center.y - point.y)/2 * (scale-1) / scale;
    
    NSLog(@"WildCardVideoView %.2f %.2f %.2f %.2f %.2f", point.x, point.y, scale, deltaX, deltaY);
    
    newTransform = CGAffineTransformTranslate(newTransform, deltaX, deltaY);
    
    v.layer.anchorPoint = CGPointMake(0.5, 0.5);
    
    v.transform = newTransform;
//    gestureRecognizer.scale = 1.0;
}

- (void)handlePan:(UIPanGestureRecognizer *)gestureRecognizer {
    if (gestureRecognizer.state == UIGestureRecognizerStateBegan) {
        _dragging = true;
        self.lastPanPoint = [gestureRecognizer locationInView:_bottom_bg];
    } else if (gestureRecognizer.state == UIGestureRecognizerStateChanged) {
        CGPoint currentPanPoint = [gestureRecognizer locationInView:_bottom_bg];
        CGFloat deltaX = currentPanPoint.x - self.lastPanPoint.x;
        CGFloat deltaY = currentPanPoint.y - self.lastPanPoint.y;
        
        int delta_sec = deltaX * _last_duration / _bar_bg.frame.size.width;
        int a = _last_current + delta_sec;
        if(a < 0)
            a = 0;
        if(a > _last_duration)
            a = _last_duration;
        _dragging_sec = a;
        [self setTimeCore:a : _last_duration];
    } else if (gestureRecognizer.state == UIGestureRecognizerStateEnded) {
        _dragging = false;
        [self.delegate onSeek:_dragging_sec];
    }
}


-(void)full_click:(id)sender {
    DevilController* dc = (DevilController*)[JevilInstance currentInstance].vc;
    NSString* image_name = @"devil_video_full_screen";
    if(_is_full_screen) {
        [DevilSdk sharedInstance].currentOrientation = UIInterfaceOrientationMaskPortrait;
        [dc toPortrait];
        image_name = @"devil_video_full_screen";
        
        if(!_before_navigationbar_hidden)
            [dc showNavigationBar];
        
        for(id view_info in _before_view_info_list) {
            UIView* view = view_info[@"view"];
            CGRect rect = [view_info[@"frame"] CGRectValue];
            BOOL hidden = [view_info[@"hidden"] boolValue];
            view.frame = rect;
            view.hidden = hidden;
        }
        
        [_before_view_info_list removeAllObjects];
    } else {
        [DevilSdk sharedInstance].currentOrientation = UIInterfaceOrientationMaskLandscape;
        [dc toLandscape];
        image_name = @"devil_video_full_screen_exit";
        
        float sw = [UIScreen mainScreen].bounds.size.width;
        float sh = [UIScreen mainScreen].bounds.size.height;
        
        _before_navigationbar_hidden = dc.navigationController.navigationBarHidden;
        
        [dc hideNavigationBar];
        _before_view_info_list = [[NSMutableArray alloc] init];
        
        UIView* c = [self.fullScreenView superview];
        while(c != dc.view) {
            [_before_view_info_list addObject:@{
                @"view" : c,
                @"frame": [NSValue valueWithCGRect:c.frame],
                @"hidden": [NSNumber numberWithBool:c.hidden],
            }];
            
            c.frame = CGRectMake(0, 0, sh, sw);
            
            c = [c superview];
        }
    }
    
    NSBundle *bundle = [NSBundle bundleForClass:[self class]];
    UIImage* _full_button_image = [[UIImage imageNamed:image_name inBundle:bundle compatibleWithTraitCollection:nil] imageWithRenderingMode:UIImageRenderingModeAlwaysTemplate];
    [_full_button setImage:_full_button_image forState:UIControlStateNormal];
    
    _is_full_screen = !_is_full_screen;
    
    [self setTime:_last_current : _last_duration];
}

-(void)finished {
    [self setTime:_last_duration :_last_duration];
}

-(void)setTime:(int)current :(int)duration {
    _last_current = current;
    _last_duration = duration;
    if(!_dragging)
        [self setTimeCore:current :duration];
}

-(void)setTimeCore:(int)current :(int)duration {
    {
        int sec = current;
        NSString* t = @"";
        if(sec >= 3600)
            t = [NSString stringWithFormat:@"%02d:%02d:%02d", sec/3600, (sec%3600)/60, sec % 60];
        else
            t = [NSString stringWithFormat:@"%02d:%02d", (sec%3600)/60, sec % 60];
        _time_text.text = t;
    }
    
    {
        int sec = duration;
        NSString* t = @"";
        if(sec >= 3600)
            t = [NSString stringWithFormat:@" / %02d:%02d:%02d", sec/3600, (sec%3600)/60, sec % 60];
        else
            t = [NSString stringWithFormat:@" / %02d:%02d", (sec%3600)/60, sec % 60];
        _time_text_max.text = t;
    }
    
    if(duration > 0) {
        float rate = (float)current / duration;
        float w = rate * _bar_bg.frame.size.width;
        _bar.frame = CGRectMake(0, 0, w, _bar.frame.size.height);
    } else {
        _bar.frame = CGRectMake(0, 0, 0, _bar.frame.size.height);
    }
}





-(void)barBgLayout {
    _bar_bg.translatesAutoresizingMaskIntoConstraints = NO;
    // tv 뷰의 왼쪽 마진 제약 추가
    NSLayoutConstraint *leftConstraint = [NSLayoutConstraint constraintWithItem:_bar_bg
                                                                      attribute:NSLayoutAttributeLeading
                                                                      relatedBy:NSLayoutRelationEqual
                                                                         toItem:_bottom_bg
                                                                      attribute:NSLayoutAttributeLeading
                                                                     multiplier:1.0
                                                                       constant:_time_text.frame.size.width + _time_text_max.frame.size.width + 7
    ]; // 왼쪽 마진 80

    // tv 뷰의 오른쪽 마진 제약 추가
    NSLayoutConstraint *rightConstraint = [NSLayoutConstraint constraintWithItem:_bar_bg
                                                                       attribute:NSLayoutAttributeTrailing
                                                                       relatedBy:NSLayoutRelationEqual
                                                                          toItem:_bottom_bg
                                                                       attribute:NSLayoutAttributeTrailing
                                                                      multiplier:1.0
                                                                        constant:-HEIGHT -7]; // 오른쪽 마진 40

    // tv 뷰의 상단 위치 제약 추가 (여기서는 높이 제약은 없음)
    NSLayoutConstraint *topConstraint = [NSLayoutConstraint constraintWithItem:_bar_bg
                                                                     attribute:NSLayoutAttributeTop
                                                                     relatedBy:NSLayoutRelationEqual
                                                                        toItem:_bottom_bg
                                                                     attribute:NSLayoutAttributeTop
                                                                    multiplier:1.0
                                                                      constant:(HEIGHT-BAR_HEIGHT)/2];

    // tv 뷰의 하단 위치 제약 추가 (여기서는 높이 제약은 없음)
    NSLayoutConstraint *bottomConstraint = [NSLayoutConstraint constraintWithItem:_bar_bg
                                                                        attribute:NSLayoutAttributeBottom
                                                                        relatedBy:NSLayoutRelationEqual
                                                                           toItem:_bottom_bg
                                                                        attribute:NSLayoutAttributeBottom
                                                                       multiplier:1.0
                                                                         constant:-(HEIGHT-BAR_HEIGHT)/2];

    // 위에서 생성한 제약들을 활성화
    [NSLayoutConstraint activateConstraints:@[leftConstraint, rightConstraint, topConstraint, bottomConstraint]];
}

-(void)fullButtonLayout {
    _full_button.translatesAutoresizingMaskIntoConstraints = NO;
    // tv 뷰의 가로 너비 제약 (고정된 값)
    NSLayoutConstraint *widthConstraint = [NSLayoutConstraint constraintWithItem:_full_button
                                                                       attribute:NSLayoutAttributeWidth
                                                                       relatedBy:NSLayoutRelationEqual
                                                                          toItem:nil
                                                                       attribute:NSLayoutAttributeNotAnAttribute
                                                                      multiplier:1.0
                                                                        constant:HEIGHT];


    // 우측 정렬을 위한 제약 추가
    NSLayoutConstraint *bottomConstraint = [NSLayoutConstraint constraintWithItem:_full_button
                                                                        attribute:NSLayoutAttributeRight
                                                                        relatedBy:NSLayoutRelationEqual
                                                                           toItem:_bottom_bg
                                                                        attribute:NSLayoutAttributeRight
                                                                       multiplier:1.0
                                                                         constant:0.0];

    // 세로 너비 제약 (고정된 값)
    NSLayoutConstraint *heightConstraint = [NSLayoutConstraint constraintWithItem:_full_button
                                                                       attribute:NSLayoutAttributeHeight
                                                                       relatedBy:NSLayoutRelationEqual
                                                                          toItem:nil
                                                                       attribute:NSLayoutAttributeNotAnAttribute
                                                                      multiplier:1.0
                                                                        constant:HEIGHT];
    
    // 위에서 생성한 제약들을 활성화
    [NSLayoutConstraint activateConstraints:@[widthConstraint, bottomConstraint, heightConstraint]];
}


-(void)bottomLayout {
    _bottom_bg.translatesAutoresizingMaskIntoConstraints = NO;
    // tv 뷰의 가로 너비 제약 (고정된 값)
    NSLayoutConstraint *widthConstraint = [NSLayoutConstraint constraintWithItem:_bottom_bg
                                                                       attribute:NSLayoutAttributeWidth
                                                                       relatedBy:NSLayoutRelationEqual
                                                                          toItem:self
                                                                       attribute:NSLayoutAttributeWidth
                                                                      multiplier:1.0
                                                                        constant:0.0];


    // 하단 정렬을 위한 제약 추가
    NSLayoutConstraint *bottomConstraint = [NSLayoutConstraint constraintWithItem:_bottom_bg
                                                                        attribute:NSLayoutAttributeBottom
                                                                        relatedBy:NSLayoutRelationEqual
                                                                           toItem:self
                                                                        attribute:NSLayoutAttributeBottom
                                                                       multiplier:1.0
                                                                         constant:0.0];

    // 세로 너비 제약 (고정된 값)
    NSLayoutConstraint *heightConstraint = [NSLayoutConstraint constraintWithItem:_bottom_bg
                                                                       attribute:NSLayoutAttributeHeight
                                                                       relatedBy:NSLayoutRelationEqual
                                                                          toItem:nil
                                                                       attribute:NSLayoutAttributeNotAnAttribute
                                                                      multiplier:1.0
                                                                        constant:HEIGHT];
    
    // 위에서 생성한 제약들을 활성화
    [NSLayoutConstraint activateConstraints:@[widthConstraint, bottomConstraint, heightConstraint]];
}


@end
