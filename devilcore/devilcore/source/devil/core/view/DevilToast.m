//
//  DevilToast.m
//  devilcore
//
//  Created by Mu Young Ko on 2021/04/28.
//

#import "DevilToast.h"
#import <objc/runtime.h>
#import <QuartzCore/QuartzCore.h>
#import "DevilLang.h"

@interface DevilToast ()

@property (nonatomic, strong) UITextView *textView;
@property (nonatomic, strong, readonly) UIWindow *window;

@end

@implementation DevilToast

static const CGFloat DevilToastDefaultViewAlpha = 0.7f;
static const NSTimeInterval DevilToastDefaultDuration = 3.0;
static const NSTimeInterval DevilToastDefaultFadeInOut = 0.5;
static const NSTimeInterval DevilToastDefaultDelay = 0.0;
static const CGFloat DevilToastDefaultSystemFontSizeIncrement = 2.0;

static const NSString *DevilToastTimerKey = @"DevilToastTimerKey";

- (instancetype)initWithText:(NSString *)text duration:(NSTimeInterval)duration {
    self = [super initWithFrame:CGRectZero];
    if (self) {

        [self setUpTextView];
        [self setDefaultValues];

        self.text = text;
        self.duration = duration;

        UITapGestureRecognizer *tapGestureRecognizer = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(didTap)];
        [self addGestureRecognizer:tapGestureRecognizer];

        [[NSNotificationCenter defaultCenter]
            addObserver:self
               selector:@selector(deviceDidRotate)
                   name:UIDeviceOrientationDidChangeNotification
                 object:nil];
    }
    return self;
}

- (void)show {
    dispatch_async(dispatch_get_main_queue(), ^{
        [self.window addSubview:self];
        float sw = [UIScreen mainScreen].bounds.size.width * 0.8f;
        
        for(UIView* v in [self subviews])
            [v removeFromSuperview];
        
        self.backgroundColor = [UIColor blackColor];
        UILabel* test = [[UILabel alloc] initWithFrame:CGRectMake(50, 200, 100, 20)];
        test.backgroundColor = [UIColor blackColor];
        test.textColor = [UIColor whiteColor];
        test.text = self.text;
        test.font = [UIFont systemFontOfSize:self.fontSize];
        CGRect testrect = [test.text boundingRectWithSize:CGSizeMake(sw, 1000) options:NSStringDrawingUsesLineFragmentOrigin attributes:@{NSFontAttributeName: test.font} context:nil];
        test.frame = CGRectMake(0, 0, testrect.size.width, testrect.size.height);
        [self addSubview:test];
        
        int padding_w = 20;
        int padding_h = 10;
        int w = padding_w + testrect.size.width + padding_w;
        int h = padding_h + testrect.size.height + padding_h;
        
        CGSize actualSize = [UIScreen mainScreen].bounds.size;
        self.frame = CGRectMake(actualSize.width / 2.0f - w / 2.0f,
                                (actualSize.height * 0.85f - h / 2.0f),
                                w, h);
        test.center = CGPointMake(w/2, h/2);
        
        self.layer.cornerRadius = (self.roundEdges ? self.bounds.size.height / 2.0f : 0.0f);
        self.alpha = 0.0;
        [UIView animateWithDuration:self.fadeInTime
            delay:self.delay
            options:(UIViewAnimationOptionCurveEaseInOut) // | UIViewAnimationOptionAllowUserInteraction)
            animations:^{
              self.alpha = self.viewAlpha;
            }
            completion:^(BOOL finished __unused) {
              NSTimer *timer =
                  [NSTimer scheduledTimerWithTimeInterval:self.duration
                                                   target:self
                                                 selector:@selector(timerDidFinish:)
                                                 userInfo:nil
                                                  repeats:NO];
              objc_setAssociatedObject(self, &DevilToastTimerKey, timer,
                                       OBJC_ASSOCIATION_RETAIN_NONATOMIC);
            }];

    });
}

- (void)hide {
    [[NSNotificationCenter defaultCenter] removeObserver:self];
    dispatch_async(dispatch_get_main_queue(), ^{

    [UIView animateWithDuration:self.fadeOutTime
        delay:0.0
        options:(UIViewAnimationOptionCurveEaseInOut)
        animations:^{
          self.alpha = 0.0;
        }
        completion:^(BOOL finished __unused) {
          [self removeFromSuperview];
        }];
    });
}

- (void)cancel {
    [self hide];
}

- (void)timerDidFinish:(id __unused)sender {
    // Call delegate
    [self hide];
}

- (void)didTap {
    // Call delegate
    [self hide];
}

+ (DevilToast *)makeText:(NSString *)text {
    return [[DevilToast alloc] initWithText:trans(text) duration:DevilToastDefaultDuration];
}

+ (DevilToast *)makeText:(NSString *)text duration:(NSTimeInterval)duration {
    return [[DevilToast alloc] initWithText:text duration:duration];
}

#pragma mark - Helpers

- (void)setDefaultValues {
    self.viewAlpha = DevilToastDefaultViewAlpha;
    self.fadeInTime = self.fadeOutTime = DevilToastDefaultFadeInOut;
    self.delay = DevilToastDefaultDelay;
    self.duration = DevilToastDefaultDuration;
    self.layer.masksToBounds = YES;
    self.roundEdges = YES;
    self.fontSize = [UIFont systemFontSize] + DevilToastDefaultSystemFontSizeIncrement;
    //self.insets = UIEdgeInsetsMake(4.0, 5.0, 3.0, 6.0);
}

- (void)setUpTextView {
    self.textView = [[UITextView alloc] init];
    self.textView.backgroundColor = [UIColor blackColor];
    // self.textView.alpha = self.viewAlpha;
    self.textView.textColor = [UIColor whiteColor];
    self.textView.userInteractionEnabled = NO;
    self.textView.font = [UIFont systemFontOfSize:self.fontSize];
    [self addSubview:self.textView];
}

- (void)deviceDidRotate {
    
}

#pragma mark - Pseudo Window

- (nullable UIWindow *)window {
    UIWindow *window = [UIApplication sharedApplication].keyWindow;
    if (!window)
        window = [[UIApplication sharedApplication].windows objectAtIndex:0];
    return window;
}

@end
