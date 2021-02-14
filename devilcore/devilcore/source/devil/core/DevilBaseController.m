//
//  DevilBaseController.m
//  devilcore
//
//  Created by Mu Young Ko on 2020/12/04.
//

#import "DevilBaseController.h"
#import "Lottie.h"


@interface DevilBaseController ()

@property int originalY;

@end

@implementation DevilBaseController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    CGRect screenRect = [[UIScreen mainScreen] bounds];
    screenWidth = screenRect.size.width;
    screenHeight = screenRect.size.height;
    
    UITapGestureRecognizer *singleFingerTap2 =
    [[UITapGestureRecognizer alloc] initWithTarget:self
                                            action:@selector(handleSingleTap:)];
    [self.view addGestureRecognizer:singleFingerTap2];
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(keyboardWillShow:) name:UIKeyboardWillShowNotification object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(keyboardWillHide:) name:UIKeyboardWillHideNotification object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(textEditing:) name:UITextFieldTextDidBeginEditingNotification object:nil];
}

- (void)viewWillDisappear:(BOOL)animated
{
    [super viewWillDisappear:animated];
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

- (void)handleSingleTap:(UITapGestureRecognizer *)recognizer
{
    [self.view endEditing:YES];
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
    UIView* indicatorBg = [[UIView alloc] initWithFrame:CGRectMake(0, 0, screenWidth, screenHeight)];
    indicatorBg.backgroundColor = [UIColor colorWithRed:0.1 green:0.1 blue:0.1 alpha:0.3];
    indicatorBg.tag = 2244;
    [self.view addSubview:indicatorBg];
    
    LOTAnimationView* loading = [LOTAnimationView animationNamed:@"loading" inBundle:[NSBundle mainBundle]];
    int h = 170;
    loading.frame = CGRectMake(0, 0 , h, h);
    loading.userInteractionEnabled = NO;
    loading.center = self.view.center;
    loading.tag = 2243;
    loading.loopAnimation = YES;
    [loading play];
    [self.view addSubview:loading];
}

- (void)textEditing:(NSNotification*)noti
{
    UIView* tf = (UIView*)noti.object;
    editingPoint = [tf convertPoint:tf.frame.origin toView:self.view];
    if(editingView != tf)
    {
        if(self.devilBlockDialog == nil && editingPoint.y > screenHeight/4)
        {
            [UIView animateWithDuration:0.3f animations:^{
                int toUp = screenHeight/4 - editingPoint.y;
                self.view.frame = CGRectMake(self.view.frame.origin.x, toUp, self.view.frame.size.width, self.view.frame.size.height);
            }];
        }
    }
    editingView = tf;
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

- (void)keyboardWillShow:(NSNotification*)noti
{
    //
    if(self.devilBlockDialog == nil &&
       editingPoint.y > screenHeight/4)
    {
        int toUp = screenHeight/4 - editingPoint.y;
        self.view.frame = CGRectMake(self.view.frame.origin.x, toUp, self.view.frame.size.width, self.view.frame.size.height);
    }
}

- (void)keyboardWillHide:(NSNotification*)noti
{
    self.view.frame = CGRectMake(self.view.frame.origin.x, self.originalY, self.view.frame.size.width, self.view.frame.size.height);
}

@end
