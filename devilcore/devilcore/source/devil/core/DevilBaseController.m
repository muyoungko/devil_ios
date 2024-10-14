//
//  DevilBaseController.m
//  devilcore
//
//  Created by Mu Young Ko on 2020/12/04.
//

#import "DevilBaseController.h"
#import "Lottie.h"
#import "WildCardUITextField.h"
#import "DevilLang.h"
#import "WildCardUtil.h"
#import "WildCardConstructor.h"
#import "WildCardEventTracker.h"
#import "DevilSwipeBackGesture.h"

@interface DevilBaseController ()<UIGestureRecognizerDelegate>

@property int originalY;
@property int originalDialogY;
@property (retain, nonatomic) UIView* keypadTop;
@property (retain, nonatomic) UIButton* keypadTopButton;
@property (retain, nonatomic) WildCardUITextField* editingTextField;

@property (retain, nonatomic) UIView* should_up_footer;

@end

@implementation DevilBaseController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    CGRect screenRect = [[UIScreen mainScreen] bounds];
    screenWidth = screenRect.size.width;
    screenHeight = screenRect.size.height;
    self.keyboard_height = 0;
    
    self.retainObject = [@[] mutableCopy];
    UITapGestureRecognizer *singleFingerTap2 =
    [[UITapGestureRecognizer alloc] initWithTarget:self
                                            action:@selector(handleSingleTap:)];
    [self.view addGestureRecognizer:singleFingerTap2];
    
    self.navigationController.interactivePopGestureRecognizer.delegate = [DevilSwipeBackGesture sharedInstance];
    self.navigationController.delegate = [DevilSwipeBackGesture sharedInstance];
    [DevilSwipeBackGesture sharedInstance].nav = self.navigationController;
    self.navigationController.interactivePopGestureRecognizer.enabled = YES;
}
 

-(void)updateFlexScreen {
    
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(keyboardWillShow:) name:UIKeyboardWillShowNotification object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(keyboardDidShow:) name:UIKeyboardDidShowNotification object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(keyboardWillHide:) name:UIKeyboardWillHideNotification object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(textEditing:) name:UITextFieldTextDidBeginEditingNotification object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(textEditing:) name:UITextViewTextDidBeginEditingNotification object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(orientationChanged:) name:UIDeviceOrientationDidChangeNotification object:nil];
    [self updateFlexScreen];
}

- (void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
    self.originalY = self.view.frame.origin.y;
    
    [[WildCardEventTracker sharedInstance] onScreen:self.projectId screenId:self.screenId screenName:self.screenName];
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

- (UIWindow*)aWindow {
    UIWindow *window = [UIApplication sharedApplication].keyWindow;
    if (!window)
        window = [[UIApplication sharedApplication].windows objectAtIndex:0];
    return window;
}

- (void)showIndicator
{
    UIWindow* window = [self aWindow];
    if([window viewWithTag:2243] == nil) {
        UIView* indicatorBg = [[UIView alloc] initWithFrame:CGRectMake(0, 0, screenWidth, screenHeight)];
        indicatorBg.backgroundColor = [UIColor colorWithRed:0.1 green:0.1 blue:0.1 alpha:0.0];
        indicatorBg.autoresizingMask = UIViewAutoresizingFlexibleWidth |
                                UIViewAutoresizingFlexibleHeight |
                                UIViewAutoresizingFlexibleTopMargin |
                                UIViewAutoresizingFlexibleLeftMargin |
                                UIViewAutoresizingFlexibleRightMargin |
                                UIViewAutoresizingFlexibleBottomMargin;
        indicatorBg.tag = 2244;
        [window addSubview:indicatorBg];
        [WildCardConstructor followSizeFromFather:window child:indicatorBg];
        
        UITapGestureRecognizer *singleFingerTap =
        [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(hideIndicator)];
        [indicatorBg addGestureRecognizer:singleFingerTap];
        
        LOTAnimationView* loading = [LOTAnimationView animationNamed:@"loading" inBundle:[NSBundle mainBundle]];
        int h = 170;
        loading.frame = CGRectMake(0, 0 , h, h);
        loading.userInteractionEnabled = NO;
        
        CGRect screenRect = [[UIScreen mainScreen] bounds];
        int sw = screenRect.size.width;
        int sh = screenRect.size.height;
        
        loading.center = CGPointMake(sw/2, sh/2);
        loading.tag = 2243;
        loading.loopAnimation = YES;
        [loading play];
        [window addSubview:loading];
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

- (void)keyboardWillShow:(NSNotification*)noti
{
    if(self.devilBlockDialog == nil &&
       editingPoint.y > screenHeight/4)
    {
        // int toUp = screenHeight/3 - editingPoint.y;
        //self.view.frame = CGRectMake(self.view.frame.origin.x, toUp, self.view.frame.size.width, self.view.frame.size.height);
    }
}

- (void)adjustFooterPositionOnKeyboard {
    //이미 keyboard가 내려갔는지 검사
    if(self.keyboardOn) {
        CGRect rect = self.keyboardRect;
        float viewGap = self.view.frame.origin.y - self.originalY;
        int toUp = self.view.frame.size.height - rect.size.height - self.original_footer_height - viewGap;
        self.should_up_footer.frame = CGRectMake(self.should_up_footer.frame.origin.x, toUp, self.should_up_footer.frame.size.width, self.should_up_footer.frame.size.height);
    }
}


- (void)keyboardDidShow:(NSNotification*)noti {
    self.keyboardOn = true;
    NSValue* keyboardFrameBegin = [noti.userInfo valueForKey:UIKeyboardFrameEndUserInfoKey];
    CGRect rect = [keyboardFrameBegin CGRectValue];
    self.keyboardRect = rect;
    if(self.should_up_footer && !self.fix_footer) {
        [UIView animateWithDuration:0.15f animations:^{
            float viewGap = self.view.frame.origin.y - self.originalY;
            int toUp = self.view.frame.size.height - rect.size.height - self.original_footer_height - viewGap;
            self.should_up_footer.frame = CGRectMake(self.should_up_footer.frame.origin.x, toUp, self.should_up_footer.frame.size.width, self.should_up_footer.frame.size.height);
        }];
    } 
    
    
    if(editingNumberKey && self.should_up_footer == nil) {
        if(self.keypadTop == nil) {
            CGRect screenRect = [[UIScreen mainScreen] bounds];
            int sw = screenRect.size.width;
            int sh = screenRect.size.height;
            int h = 45;
            int bw = 70;
            self.keypadTop = [[UIView alloc] initWithFrame:CGRectMake(0,sh, sw, h)];
            self.keypadTop.backgroundColor = UIColorFromRGBA(0x20000000);
            [self.view addSubview:self.keypadTop];
            
            self.keypadTopButton = [[UIButton alloc] initWithFrame:CGRectMake(sw-bw-10, 5, bw, h-10)];
            NSString* text = trans(@"OK");
            if(self.editingTextField.returnKeyType == UIReturnKeySearch)
                text = @"검색";
            else if(self.editingTextField.returnKeyType == UIReturnKeyNext)
                text = @"다음";
            
            [self.keypadTopButton setTitle:text forState:UIControlStateNormal];
            [self.keypadTopButton addTarget:self  action:@selector(doneClick) forControlEvents:UIControlEventTouchUpInside];
            self.keypadTopButton.layer.cornerRadius = 6.0;
            [self.keypadTopButton setBackgroundColor:UIColorFromRGB(0x0071e3)];
            [self.keypadTop addSubview:self.keypadTopButton];
        }
        
        NSValue* keyboardFrameBegin = [noti.userInfo valueForKey:UIKeyboardFrameEndUserInfoKey];
        CGRect rect = [keyboardFrameBegin CGRectValue];
        self.keypadTop.hidden = NO;
        float viewGap = self.view.frame.origin.y - self.originalY;
        int toUp = screenHeight - rect.size.height - self.keypadTop.frame.size.height - viewGap;
        self.keypadTop.frame = CGRectMake(self.keypadTop.frame.origin.x, toUp, self.keypadTop.frame.size.width, self.keypadTop.frame.size.height);
    }
    
    if(self.devilBlockDialog && [[self.devilBlockDialog subviews] count] > 1){
        CGRect absolute_rect = [editingView convertRect:editingView.frame toView:nil];
        NSValue* keyboardFrameBegin = [noti.userInfo valueForKey:UIKeyboardFrameEndUserInfoKey];
        CGRect rect = [keyboardFrameBegin CGRectValue];
        int toUp = rect.origin.y - absolute_rect.origin.y - 50;
        UIView* movingDialogView = [self.devilBlockDialog subviews][1];
        if(toUp < 0 && movingDialogView)
            self.originalDialogY = movingDialogView.frame.origin.y;
            [UIView animateWithDuration:0.15f animations:^{
                movingDialogView.frame = CGRectMake(movingDialogView.frame.origin.x,
                                                     movingDialogView.frame.origin.y + toUp,
                                                     movingDialogView.frame.size.width,
                                                     movingDialogView.frame.size.height);
            }];
   }
}

- (BOOL)isInPopupView:(UIView*)view {
    if(self.devilBlockDialog)
        return YES;
    
    return NO;
}


- (void)textEditing:(NSNotification*)noti
{
    if(self.footer)
        self.should_up_footer = self.footer;
    else if(self.inside_footer)
        self.should_up_footer = self.inside_footer;

    UIView* tf = (UIView*)noti.object;
    editingNumberKey = NO;
    numberKeyType = nil;
    if([tf isKindOfClass:[WildCardUITextField class]]) {
        self.editingTextField = (WildCardUITextField*)tf;
        if(self.editingTextField.keyboardType == UIKeyboardTypeNumberPad || self.editingTextField.keyboardType == UIKeyboardTypeDecimalPad ) {
            editingNumberKey = YES;
            numberKeyType = self.editingTextField.returnKeyType;
        }
    }
    
    editingInFooter = NO;
    UIView* parent = [tf superview];
    for(int i=0;parent!= nil && i<10;i++) {
        if(parent == self.should_up_footer) {
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
            //아이패드의 경우 키보드가 작아서 화면을 올릴 필요가 없다
            if(self.devilBlockDialog == nil && editingPoint.y > screenHeight/4 && ![WildCardConstructor isTablet])
            {
                [UIView animateWithDuration:0.3f animations:^{
                    int toUp = screenHeight/4 - editingPoint.y;
                    int minY = -200;
                    if(toUp < minY)
                        toUp = minY;
                        
                    self.view.frame = CGRectMake(self.view.frame.origin.x, toUp, self.view.frame.size.width, self.view.frame.size.height);
                }];
            }
        }
        editingView = tf;
    }
    
    if(!editingNumberKey && self.keypadTop) {
        self.keypadTop.hidden = YES;
    }
}

- (void)keyboardWillHide:(NSNotification*)noti {
    self.keyboardOn = NO;
    self.keypadTop.hidden = YES; 
    if(self.should_up_footer)
        self.should_up_footer.frame = CGRectMake(self.should_up_footer.frame.origin.x, self.original_footer_y, self.should_up_footer.frame.size.width, self.should_up_footer.frame.size.height);
    editingView = nil;
    self.view.frame = CGRectMake(self.view.frame.origin.x, self.originalY, self.view.frame.size.width, self.view.frame.size.height);
    
    if(self.devilBlockDialog && [[self.devilBlockDialog subviews] count] > 1){
        UIView* movingDialogView = [self.devilBlockDialog subviews][1];
        if(movingDialogView)
            [UIView animateWithDuration:0.15f animations:^{
                movingDialogView.frame = CGRectMake(movingDialogView.frame.origin.x,
                                                    self.originalDialogY,
                                                     movingDialogView.frame.size.width,
                                                     movingDialogView.frame.size.height);
            }];
   }
    
}


- (void)dotClick {
    if(self.editingTextField) {
        self.editingTextField.text = [NSString stringWithFormat:@"%@.", self.editingTextField.text];
    }
}

- (void)doneClick {
    if(self.editingTextField) {
        [self.editingTextField doneClick];
    }
    [self.view endEditing:YES];
}

- (UIViewController *)documentInteractionControllerViewControllerForPreview:(UIDocumentInteractionController *)controller{
    return self;
}

-(BOOL)accessibilityScroll:(UIAccessibilityScrollDirection)direction {

    if (direction == UIAccessibilityScrollDirectionRight) {
      //Previous Page

    } else if (direction == UIAccessibilityScrollDirectionLeft) {
     //Next Page
    }

    return YES;
}

-(void)alertFinish:(NSString *)msg {
    UIAlertController *alertController = [UIAlertController alertControllerWithTitle:msg
                                                                             message:nil
                                                                      preferredStyle:UIAlertControllerStyleAlert];

    [alertController addAction:[UIAlertAction actionWithTitle:trans(@"OK")
                                                      style:UIAlertActionStyleCancel
                                                    handler:^(UIAlertAction *action) {
       [self.navigationController popViewControllerAnimated:YES];
    }]];
    [self presentViewController:alertController animated:YES completion:^{}];
}


-(void)orientationChanged:(NSNotification*)noti {
    
}
@end
