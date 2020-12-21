//
//  DevilBaseController.m
//  devilcore
//
//  Created by Mu Young Ko on 2020/12/04.
//

#import "DevilBaseController.h"
//#import "Lottie/Lottie.h"

@interface DevilBaseController ()

@end

@implementation DevilBaseController

- (void)viewDidLoad {
    [super viewDidLoad];
}

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

- (void)showIndicator
{
//    UIView* indicatorBg = [[UIView alloc] initWithFrame:CGRectMake(0, 0, screenWidth, screenHeight)];
//    indicatorBg.backgroundColor = [UIColor colorWithRed:0.1 green:0.1 blue:0.1 alpha:0.3];
//    indicatorBg.tag = 2244;
//    [self.view addSubview:indicatorBg];
//    
//    LOTAnimationView* loading = [LOTAnimationView animationNamed:@"loading" inBundle:[NSBundle mainBundle]];
//    int h = 170;
//    loading.frame = CGRectMake(0, 0 , h, h);
//    loading.userInteractionEnabled = NO;
//    loading.center = self.view.center;
//    loading.tag = 2243;
//    loading.loopAnimation = YES;
//    [loading play];
//    [self.view addSubview:loading];
}

- (void)hideIndicator
{
    while([self.view viewWithTag:2243] != nil)
    {
        [[self.view viewWithTag:2243] removeFromSuperview];
    }
    while([self.view viewWithTag:2244] != nil)
    {
        [[self.view viewWithTag:2244] removeFromSuperview];
    }
}

@end
