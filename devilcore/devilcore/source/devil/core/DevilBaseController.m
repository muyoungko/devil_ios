//
//  DevilBaseController.m
//  devilcore
//
//  Created by Mu Young Ko on 2020/12/04.
//

#import "DevilBaseController.h"
#import "Lottie.h"
#import "WildCardUITextField.h"

@interface DevilBaseController ()

@property int originalY;
@property (retain, nonatomic) UIView* keypadTop;
@property (retain, nonatomic) UIButton* keypadTopButton;
@property (retain, nonatomic) WildCardUITextField* editingTextField;

@end

@implementation DevilBaseController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    CGRect screenRect = [[UIScreen mainScreen] bounds];
    screenWidth = screenRect.size.width;
    screenHeight = screenRect.size.height;
    self.keyboard_height = 0;
    UITapGestureRecognizer *singleFingerTap2 =
    [[UITapGestureRecognizer alloc] initWithTarget:self
                                            action:@selector(handleSingleTap:)];
    [self.view addGestureRecognizer:singleFingerTap2];
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(keyboardWillShow:) name:UIKeyboardWillShowNotification object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(keyboardDidShow:) name:UIKeyboardDidShowNotification object:nil];
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
    if(self.devilBlockDialog == nil &&
       editingPoint.y > screenHeight/4)
    {
        int toUp = screenHeight/4 - editingPoint.y;
        self.view.frame = CGRectMake(self.view.frame.origin.x, toUp, self.view.frame.size.width, self.view.frame.size.height);
    }
}

- (void)keyboardDidShow:(NSNotification*)noti {
    if(self.footer) {
        NSValue* keyboardFrameBegin = [noti.userInfo valueForKey:UIKeyboardFrameEndUserInfoKey];
        CGRect rect = [keyboardFrameBegin CGRectValue];
        
        [UIView animateWithDuration:0.15f animations:^{
            float viewGap = self.view.frame.origin.y - self.originalY;
            int toUp = screenHeight - rect.size.height - self.original_footer_height - viewGap;
            self.footer.frame = CGRectMake(self.footer.frame.origin.x, toUp, self.footer.frame.size.width, self.footer.frame.size.height);
        }];
    }
    
    if(editingNumberKey) {
        if(self.keypadTop == nil) {
            CGRect screenRect = [[UIScreen mainScreen] bounds];
            int sw = screenRect.size.width;
            int sh = screenRect.size.height;
            int h = 45;
            int bw = 70;
            self.keypadTop = [[UIView alloc] initWithFrame:CGRectMake(0,sh, sw, h)];
            self.keypadTop.backgroundColor = [UIColor lightGrayColor];
            [self.view addSubview:self.keypadTop];
            
            self.keypadTopButton = [[UIButton alloc] initWithFrame:CGRectMake(sw-bw-10, 5, bw, h-10)];
            NSString* text = @"확인";
            if(self.editingTextField.returnKeyType == UIReturnKeySearch)
                text = @"검색";
            else if(self.editingTextField.returnKeyType == UIReturnKeyNext)
                text = @"다음";
            
            [self.keypadTopButton setTitle:text forState:UIControlStateNormal];
            [self.keypadTopButton addTarget:self.editingTextField  action:@selector(doneClick) forControlEvents:UIControlEventTouchUpInside];
            [self.keypadTop addSubview:self.keypadTopButton];
            
        }
        
        NSValue* keyboardFrameBegin = [noti.userInfo valueForKey:UIKeyboardFrameEndUserInfoKey];
        CGRect rect = [keyboardFrameBegin CGRectValue];
        self.keypadTop.hidden = NO;
        float viewGap = self.view.frame.origin.y - self.originalY;
        int toUp = screenHeight - rect.size.height - self.keypadTop.frame.size.height - viewGap;
        self.keypadTop.frame = CGRectMake(self.keypadTop.frame.origin.x, toUp, self.keypadTop.frame.size.width, self.keypadTop.frame.size.height);
    }
}

- (void)textEditing:(NSNotification*)noti
{
    UIView* tf = (UIView*)noti.object;
    editingNumberKey = NO;
    numberKeyType = nil;
    if([tf isKindOfClass:[WildCardUITextField class]]) {
        self.editingTextField = (WildCardUITextField*)tf;
        if(self.editingTextField.keyboardType == UIKeyboardTypeNumberPad ) {
            editingNumberKey = YES;
            numberKeyType = self.editingTextField.returnKeyType;
        }
    }
    
    editingInFooter = NO;
    UIView* parent = [tf superview];
    for(int i=0;parent!= nil && i<10;i++) {
        if(parent == self.footer) {
            editingInFooter = YES;
            break;
        }
        parent = [parent superview];
    }
    
    if(editingInFooter) {
    } else {
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
}

- (void)keyboardWillHide:(NSNotification*)noti {
    self.keypadTop.hidden = YES;
    if(self.footer)
        self.footer.frame = CGRectMake(self.footer.frame.origin.x, self.original_footer_y, self.footer.frame.size.width, self.footer.frame.size.height);
    
    self.view.frame = CGRectMake(self.view.frame.origin.x, self.originalY, self.view.frame.size.width, self.view.frame.size.height);
}


@end
