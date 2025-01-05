//
//  DevilLoadingManager.m
//  devilcore
//
//  Created by Mu Young Ko on 2025/01/05.
//

#import "DevilLoadingManager.h"
#import <Lottie/Lottie.h>
#import "WildCardUtil.h"

@interface DevilLoadingManager()
@property (nonatomic, retain) UIView* indicatorBg;
@property (nonatomic, retain) LOTAnimationView* loading;
@end

@implementation DevilLoadingManager
-(id)init{
    self = [super init];
    if(self) {
        [self createViews:nil];
    }
    return self;
}


-(id)initWithLottieJson:(NSData*)data{
    self = [super init];
    if(self) {
        [self createViews:data];
    }
    return self;
}

-(void)startLoading{
    [self showIndicator];
}

-(void)stopLoading{
    [self hideIndicator];
}

- (UIWindow*)aWindow {
    UIWindow *window = [UIApplication sharedApplication].keyWindow;
    if (!window)
        window = [[UIApplication sharedApplication].windows objectAtIndex:0];
    return window;
}

- (void)createViews:(NSData*)lottie
{
    CGRect screenRect = [[UIScreen mainScreen] bounds];
    int sw = screenRect.size.width;
    int sh = screenRect.size.height;
    
    UIView* indicatorBg = [[UIView alloc] initWithFrame:CGRectMake(0, 0, sw, sh)];
    indicatorBg.backgroundColor = [UIColor colorWithRed:0.1 green:0.1 blue:0.1 alpha:0.0];
    indicatorBg.autoresizingMask = UIViewAutoresizingFlexibleWidth |
                            UIViewAutoresizingFlexibleHeight |
                            UIViewAutoresizingFlexibleTopMargin |
                            UIViewAutoresizingFlexibleLeftMargin |
                            UIViewAutoresizingFlexibleRightMargin |
                            UIViewAutoresizingFlexibleBottomMargin;
    indicatorBg.tag = 2244;
    
    UITapGestureRecognizer *singleFingerTap =
    [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(hideIndicator)];
    [indicatorBg addGestureRecognizer:singleFingerTap];
    
    LOTAnimationView* loading;
    
    if(lottie) {
        NSError* error;
        NSDictionary *animationJSON = [NSJSONSerialization JSONObjectWithData:lottie options:0 error:&error];
        loading = [LOTAnimationView animationFromJSON:animationJSON];
    } else
        loading = [LOTAnimationView animationNamed:@"loading" inBundle:[NSBundle mainBundle]];
    
    int w = 170;
    int h = loading.frame.size.height / loading.frame.size.width * w;
    loading.frame = CGRectMake(0, 0 , w, h);
    loading.userInteractionEnabled = NO;
    
    loading.center = CGPointMake(sw/2, sh/2);
    loading.tag = 2243;
    loading.loopAnimation = YES;
    
    self.loading = loading;
    self.indicatorBg = indicatorBg;
}

- (void)showIndicator {
    UIWindow* window = [self aWindow];
    if([window viewWithTag:2243] == nil) {
        [window addSubview:self.indicatorBg];
        [WildCardUtil followSizeFromFather:window child:self.indicatorBg];
        [window addSubview:self.loading];
        [self.loading play];
    }
}

- (void)hideIndicator
{
    UIWindow* window = [self aWindow];
    while([window viewWithTag:2243] != nil)
    {
        [[window viewWithTag:2243] removeFromSuperview];
    }
    while([window viewWithTag:2244] != nil)
    {
        [[window viewWithTag:2244] removeFromSuperview];
    }
}

@end
