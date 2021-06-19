//
//  BaseViewController.m
//  library
//
//  Created by Mu Young Ko on 2018. 10. 31..
//  Copyright © 2018년 sbs cnbc. All rights reserved.
//

#import "BaseController.h"
#import "AppDelegate.h"
#import "Devil.h"
#import <devilcore/devilcore.h>
#import "Lottie/Lottie.h"
#import "JulyUtil.h"

@interface BaseController ()

@property int originalY;
@property (nonatomic, retain) WildCardDrawerView* d;

@end

@implementation BaseController

- (void)viewDidLoad {
    [super viewDidLoad];
    //    self.edgesForExtendedLayout=UIRectEdgeNone;
    //    self.extendedLayoutIncludesOpaqueBars=NO;
    //    self.automaticallyAdjustsScrollViewInsets=NO;
    
    CGRect screenRect = [[UIScreen mainScreen] bounds];
    screenWidth = screenRect.size.width;
    screenHeight = screenRect.size.height;
    
    [self createMainView];
    
    self.navigationController.interactivePopGestureRecognizer.delegate = self;
    self.navigationController.interactivePopGestureRecognizer.enabled = YES;
    
    
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
    
    self.originalY = self.view.frame.origin.y;
}
- (void)viewWillDisappear:(BOOL)animated
{
    [super viewWillDisappear:animated];
    [[NSNotificationCenter defaultCenter] removeObserver:self];
    
    if(self.d)
        [self.d naviDown];
}

- (void)createMainView
{
    [self.view setBackgroundColor:[UIColor whiteColor]];
    self.view.userInteractionEnabled = YES;
    
    _viewMain = [[UIView alloc] initWithFrame:CGRectMake(0,0,screenWidth, screenHeight)];
    _viewMain.userInteractionEnabled = YES;
    _viewMain.backgroundColor = [UIColor whiteColor];
    [self.view addSubview:_viewMain];
    
    _scrollView = [[UIScrollView alloc] initWithFrame:CGRectMake(0,0,screenWidth, screenHeight)];
    _scrollView.userInteractionEnabled = YES;
    _scrollView.bounces = NO;
    [_viewMain addSubview:_scrollView];
    
    if (@available(iOS 11.0, *))
    {
        _scrollView.contentInsetAdjustmentBehavior = UIScrollViewContentInsetAdjustmentNever;
    }
    else
        self.automaticallyAdjustsScrollViewInsets =NO;
}



- (void)textEditing:(NSNotification*)noti
{
    UIView* tf = (UIView*)noti.object;
    editingPoint = [tf convertPoint:tf.frame.origin toView:self.view];
    if(editingView != tf)
    {
        if(editingPoint.y > screenHeight/4)
        {
            [UIView animateWithDuration:0.3f animations:^{
                int toUp = screenHeight/4 - editingPoint.y;
                self.view.frame = CGRectMake(self.view.frame.origin.x, toUp, self.view.frame.size.width, self.view.frame.size.height);
            }];
        }
    }
    editingView = tf;
}
- (void)keyboardWillShow:(NSNotification*)noti
{
    if(editingPoint.y > screenHeight/4)
    {
        int toUp = screenHeight/4 - editingPoint.y;
        self.view.frame = CGRectMake(self.view.frame.origin.x, toUp, self.view.frame.size.width, self.view.frame.size.height);
    }
}

- (void)keyboardWillHide:(NSNotification*)noti
{
    self.view.frame = CGRectMake(self.view.frame.origin.x, self.originalY, self.view.frame.size.width, self.view.frame.size.height);
}


- (void)handleSingleTap:(UITapGestureRecognizer *)recognizer
{
    [self.view endEditing:YES];
}


- (BOOL)gestureRecognizerShouldBegin:(UIGestureRecognizer *)gestureRecognizer {
    return YES;
}

-(void)back:(id)sender
{
    [self.navigationController popViewControllerAnimated:YES];
}





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


- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex
{
    if(alertView.tag == 2243 && buttonIndex == 0)
    {
        [self.navigationController popViewControllerAnimated:YES];
    } else if(alertView.tag == 1244) {
        if(buttonIndex == 0)
            mcallback(NO);
        else
            mcallback(YES);
    }
}

-(BOOL)showAlertError:(id)res
{
    if(res == nil)
    {
        [self showAlert:@"일시적인 오류가 발생하였습니다."];
    }
    else {
        if([@"0" isEqualToString:[NSString stringWithFormat:@"%@", res[@"RSLT_CD"]]])
            return NO;
        if(res[@"error"] != nil)
            [self showAlert:res[@"error"][@"message"]];
        if(res[@"ERR_MSG"] != nil)
            [self showAlert:res[@"ERR_MSG"]];
        else
            [self showAlert:@"일시적인 오류가 발생하였습니다."];
    }
    return YES;
}
-(void)showAlertWithFinish:(NSString*)msg
{
    UIAlertController *alertController = [UIAlertController alertControllerWithTitle:msg
                                                                             message:nil
                                                                      preferredStyle:UIAlertControllerStyleAlert];

    [alertController addAction:[UIAlertAction actionWithTitle:@"확인"
                                                      style:UIAlertActionStyleCancel
                                                    handler:^(UIAlertAction *action) {
        [self.navigationController popViewControllerAnimated:YES];
    }]];
    [self presentViewController:alertController animated:YES completion:^{}];
}

-(void)showAlert:(NSString*)msg
{
    UIAlertController *alertController = [UIAlertController alertControllerWithTitle:msg
                                                                             message:nil
                                                                      preferredStyle:UIAlertControllerStyleAlert];

    [alertController addAction:[UIAlertAction actionWithTitle:@"확인"
                                                      style:UIAlertActionStyleCancel
                                                    handler:^(UIAlertAction *action) {
                                                        
    }]];
    [self presentViewController:alertController animated:YES completion:^{}];
}


-(void)showConfirm:(NSString*)msg complete:(void (^)(BOOL))callback{
    mcallback = callback;
//    UIAlertView *alert = [[UIAlertView alloc]initWithTitle:nil message:msg delegate:self cancelButtonTitle:@"아니오" otherButtonTitles:@"예", nil];
//    alert.tag = 1244;
//    [alert show];
    
    UIAlertController *alertController = [UIAlertController alertControllerWithTitle:msg
                                                                             message:nil
                                                                      preferredStyle:UIAlertControllerStyleAlert];

    [alertController addAction:[UIAlertAction actionWithTitle:@"No"
                                                      style:UIAlertActionStyleCancel
                                                    handler:^(UIAlertAction *action) {
                                                        callback(false);
    }]];
    
    [alertController addAction:[UIAlertAction actionWithTitle:@"Yes"
                                                        style:UIAlertActionStyleDefault
                                                      handler:^(UIAlertAction *action) {
                                                          callback(true);
                                                      }]];
    [self presentViewController:alertController animated:YES completion:^{}];
}

-(BOOL)empty:(NSString*)str
{
    if(str == nil || [str isEqualToString:@""])
    {
        return YES;
    }
    else return NO;
}

-(NSString*)trim:(NSString*)str
{
    if(str == nil || [str isEqualToString:@""])
    {
        return str;
    }
    else
        return [str stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceCharacterSet]];
}


-(void)openMenu {
    [self.d naviUp];
}

-(void)closeMenu {
    [self.d naviDown];
}


- (void)showCustomAlert:(NSString*)title withContentView:(UIView*)content withButtonType:(int)type height:(BOOL)variableHeight
{
    [self showCustomAlert:title withContentView:content withButtonType:type height:variableHeight withTag:0];
}
- (void)showCustomAlert:(NSString*)title withContentView:(UIView*)content withButtonType:(int)type height:(BOOL)variableHeight withTag:(int)tag
{
    if(_dialogView != nil)
        return ;
    
    int screenWidth = [[UIScreen mainScreen] bounds].size.width;
    int screenHeight = [[UIScreen mainScreen] bounds].size.height;
    UIButton *bg = [[UIButton alloc] initWithFrame:CGRectMake(0, 0, screenWidth, screenHeight)];
    bg.alpha = 0.2f;
    bg.backgroundColor = [UIColor colorWithRed:0 green:0 blue:0 alpha:0.4f];
    [bg addTarget:self action:@selector(dismissCustomAlertViewWithCancel:) forControlEvents:UIControlEventTouchUpInside];
    _dialogView = bg;
    
    
    int contentViewWidth = content.frame.size.width;
    int contentViewHeight = screenHeight - 150;
    if(variableHeight)
    {
        contentViewHeight = screenHeight - 150;
    }
    else
    {
        contentViewHeight = content.frame.size.height + 40 + 40;
    }
    
    UIView *contentView = [[UIView alloc] initWithFrame:CGRectMake((screenWidth-contentViewWidth)/2, (screenHeight-contentViewHeight)/2, contentViewWidth, contentViewHeight)];
    contentView.backgroundColor = [UIColor whiteColor];
    [bg addSubview:contentView];
    
    
    [self createPopupGnbView:contentView title:title width:contentViewWidth height:40 tag:tag];
    
    UIScrollView *sv = [[UIScrollView alloc] initWithFrame:CGRectMake(0, 40, contentViewWidth, contentViewHeight - 40 -40)];
    [contentView addSubview:sv];
    
    sv.contentSize = content.frame.size;
    [sv addSubview:content];
    
    
    if(type == BUTTON_TYPE_ONE)
    {
        UIButton *bottomButton = [[UIButton alloc] initWithFrame:CGRectMake(0, contentViewHeight-40, contentViewWidth, 40)];
        bottomButton.backgroundColor = [UIColor colorWithRed:0 green:0 blue:0 alpha:1.0f];
        [bottomButton addTarget:self action:@selector(dismissCustomAlertView:) forControlEvents:UIControlEventTouchUpInside];
        bottomButton.tag = tag;
        [bottomButton setTitle:@"확 인" forState:UIControlStateNormal];
        [bottomButton setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
        [contentView addSubview:bottomButton];
    }
    else
    {
        UIButton *bottomButton = [[UIButton alloc] initWithFrame:CGRectMake(0, contentViewHeight-40, contentViewWidth/2, 40)];
        bottomButton.backgroundColor = [UIColor colorWithRed:0 green:0 blue:0 alpha:1.0f];
        [bottomButton addTarget:self action:@selector(dismissCustomAlertView:) forControlEvents:UIControlEventTouchUpInside];
        bottomButton.tag = tag;
        [bottomButton setTitle:@"확 인" forState:UIControlStateNormal];
        [bottomButton setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
        [bottomButton.titleLabel setFont:[UIFont systemFontOfSize:15]];
        [contentView addSubview:bottomButton];
        
        
        UIButton *bottomButton2 = [[UIButton alloc] initWithFrame:CGRectMake(contentViewWidth/2, contentViewHeight-40, contentViewWidth/2, 40)];
        bottomButton2.tag = tag;
        bottomButton2.backgroundColor = [UIColor colorWithRed:0.4 green:0.4 blue:0.4 alpha:1.0f];
        [bottomButton2 addTarget:self action:@selector(dismissCustomAlertView2:) forControlEvents:UIControlEventTouchUpInside];
        [bottomButton2 setTitle:@"오늘 다시 보지 않기" forState:UIControlStateNormal];
        [bottomButton2 setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
        [bottomButton2.titleLabel setFont:[UIFont systemFontOfSize:13]];
        [contentView addSubview:bottomButton2];
    }
    
    [self.view addSubview:bg];
    [UIView animateWithDuration:0.2f animations:^{
        [bg setAlpha:1.0f];
    }];
}


- (void)dismissCustomAlertView2:(UIButton *)sender
{
    NSString* now = [NSString stringWithFormat:@"%d", (int)[NSDate timeIntervalSinceReferenceDate]];
    [[NSUserDefaults standardUserDefaults] setObject:now forKey:@"PromotionToday"];
    [[NSUserDefaults standardUserDefaults] synchronize];
    [UIView animateWithDuration:0.2f animations:^{
        [_dialogView setAlpha:0.0f];
    }completion:^(BOOL done){
        [_dialogView removeFromSuperview];
        _dialogView = nil;
    }];
}

- (void)dismissCustomAlertView:(UIButton *)sender
{
    [UIView animateWithDuration:0.2f animations:^{
        [_dialogView setAlpha:0.0f];
    }completion:^(BOOL done){
        [_dialogView removeFromSuperview];
        _dialogView = nil;
    }];
}

- (void)dismissCustomAlertViewWithCancel:(UIButton *)sender
{
    [UIView animateWithDuration:0.2f animations:^{
        [_dialogView setAlpha:0.0f];
    }completion:^(BOOL done){
        [_dialogView removeFromSuperview];
        _dialogView = nil;
    }];
}



-(void)createPopupGnbView:(UIView*)parent title:(NSString*)title width:(int)w height:(int)h tag:(int)tag
{
    UIView* gnb = [[UIView alloc]initWithFrame:CGRectMake(0, 0, w, h)];
    [parent addSubview:gnb];
    
    CAGradientLayer *gradient = [CAGradientLayer layer];
    gradient.frame = gnb.bounds;
    gradient.colors = @[(id)[UIColor colorWithRed:117.0f/255.0f green:19.0f/255.0f blue:133.0f/255.0f alpha:1.0f].CGColor,
                        (id)[UIColor colorWithRed:60/255.0f green:32.0f/255.0f blue:136.0f/255.0f alpha:1.0f].CGColor];
    gradient.startPoint = CGPointMake(0.0, 0.5);
    gradient.endPoint = CGPointMake(1.0, 0.5);
    
    [gnb.layer addSublayer:gradient];
    
    UILabel* l = [[UILabel alloc] initWithFrame:CGRectMake(0, 0, w, h)];
    l.textColor = [UIColor whiteColor];
    l.textAlignment = NSTextAlignmentCenter;
    l.text = title;
    l.font = [UIFont systemFontOfSize:16.0f];
    [gnb addSubview:l];
    
    
    UIButton* b = [[UIButton alloc] initWithFrame:CGRectMake(w-40, 5, 30, 30)];
    b.tag = tag;
    [b addTarget:self action:@selector(dismissCustomAlertView:) forControlEvents:UIControlEventTouchUpInside];
    [b setImage:[UIImage imageNamed:@"popupButtonClose.png"] forState:UIControlStateNormal];
    [gnb addSubview:b];
}


- (BOOL)onInstanceCustomAction:(WildCardMeta *)meta function:(NSString *)functionName args:(NSArray *)args view:(WildCardUIView *)node{
    return false;
}



-(BOOL) isPhoneX {
    BOOL r = false;
    if([[UIDevice currentDevice] userInterfaceIdiom] == UIUserInterfaceIdiomPhone) {
        switch ((int)[[UIScreen mainScreen] nativeBounds].size.height) {
            case 1136:
                printf("iPhone 5 or 5S or 5C");
                break;
                
            case 1334:
                printf("iPhone 6/6S/7/8");
                break;
                
            case 1920:
            case 2208:
                printf("iPhone 6+/6S+/7+/8+");
                break;
                
            case 2436:
                r = true;
                printf("iPhone X, XS");
                break;
                
            case 2688:
                r = true;
                printf("iPhone XS Max");
                break;
                
            case 1792:
                r = true;
                printf("iPhone XR");
                break;
                
            default:
                printf("Unknown");
                break;
        }
    }
    
    return r;
}



@end
