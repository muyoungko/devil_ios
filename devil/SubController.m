//
//  SubController.m
//  sticar
//
//  Created by Mu Young Ko on 2019. 6. 10..
//  Copyright © 2019년 trix. All rights reserved.
//

#define SYSTEM_VERSION_GREATER_THAN_OR_EQUAL_TO(v)  ([[[UIDevice currentDevice] systemVersion] compare:v options:NSNumericSearch] != NSOrderedAscending)

#import "SubController.h"

@interface SubController ()

@end

@implementation SubController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.data = [@{} mutableCopy];
    [self constructLeftBackButton];
}

- (void)showNavigationBar{
    [self.navigationController setNavigationBarHidden:NO animated:NO];
    self.offsetY = self.navigationController.navigationBar.frame.size.height + [UIApplication sharedApplication].statusBarFrame.size.height;
    self.viewHeight = screenHeight - self.offsetY;
    self.viewMain.frame = CGRectMake(0, self.offsetY, screenWidth, _viewHeight);
}
- (void)hideNavigationBar{
    [self.navigationController setNavigationBarHidden:YES animated:NO];
    self.offsetY = 0;
    self.viewHeight = screenHeight - self.offsetY;
    self.viewMain.frame = CGRectMake(0, self.offsetY, screenWidth, _viewHeight);
}


- (void)viewWillAppear:(BOOL)animated{
    [super viewWillAppear:animated];
//    [self.navigationController setNavigationBarHidden:NO animated:NO];
//    [self.navigationController.navigationBar setTitleTextAttributes:
//     @{NSForegroundColorAttributeName:[UIColor blackColor]}];
//    if(self.isGrayBG)
//        [self.navigationController.navigationBar setBarTintColor:UIColorFromRGB(0xf9f9f9)];
//    else
//        [self.navigationController.navigationBar setBarTintColor:UIColorFromRGB(0xffffff)];
}


- (UIImage *)imageFromLayer:(CALayer *)layer
{
    UIGraphicsBeginImageContext([layer frame].size);
    
    [layer renderInContext:UIGraphicsGetCurrentContext()];
    UIImage *outputImage = UIGraphicsGetImageFromCurrentImageContext();
    
    UIGraphicsEndImageContext();
    
    return outputImage;
}

- (void)createWildCardScreenListView:(NSString*)screenName{
    self.tv = [[WildCardScreenTableView alloc] initWithScreenId:screenName];
    self.tv.data = self.data;
    self.tv.wildCardConstructorInstanceDelegate = self;
    self.tv.tableViewDelegate = self;
    self.tv.tableFooterView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, screenWidth, 100)];
    self.tv.frame =  CGRectMake(0, 0, self.viewMain.frame.size.width, self.viewMain.frame.size.height);
    [self.viewMain addSubview:self.tv];
}

- (void)constructScrollView{
    self.scrollView = [[UIScrollView alloc] initWithFrame:CGRectMake(0, 0, screenWidth, _viewHeight)];
    [self.viewMain addSubview:self.scrollView];
}

- (void)reloadBlock{
    [WildCardConstructor applyRule:self.mainWc withData:_data];
}

- (void)constructBlockUnder:(NSString*)block{
    NSMutableDictionary* cj = [[WildCardConstructor sharedInstance] getBlockJson:block];
    self.mainWc = [WildCardConstructor constructLayer:self.viewMain withLayer:cj instanceDelegate:self];
    [WildCardConstructor applyRule:self.mainWc withData:_data];
}

- (void)constructBlockUnderScrollView:(NSString*)block{
    NSMutableDictionary* cj = [[WildCardConstructor sharedInstance] getBlockJson:block];
    self.mainWc = [WildCardConstructor constructLayer:self.scrollView withLayer:cj instanceDelegate:self];
    [WildCardConstructor applyRule:self.mainWc withData:_data];
    self.scrollView.contentSize = CGSizeMake(screenWidth, self.mainWc.frame.size.height);
}

- (void)constructLeftBackButton{
    if([self.navigationController.viewControllers count] > 2){
        UIButton *leftButton = [[UIButton alloc] initWithFrame:CGRectMake(0,0, 100,50)];
        leftButton.contentHorizontalAlignment = UIControlContentHorizontalAlignmentLeft;
        [leftButton setImage:[UIImage imageNamed:@"back_black.png"] forState:UIControlStateNormal];
        [leftButton addTarget:self action:@selector(backClick:)
             forControlEvents:UIControlEventTouchUpInside];
        //[leftButton setShowsTouchWhenHighlighted:YES];
        
        self.navigationItem.leftBarButtonItem = [[UIBarButtonItem alloc] initWithCustomView:leftButton];
    }
}

- (void)backClick:(id)sender{
    [self.navigationController popViewControllerAnimated:YES];
}

- (void)constructBottomBelowViewMain:(NSString*) title{
    int h = 120;
    UIButton *button = [[UIButton alloc] initWithFrame:CGRectMake(25, self.mainWc.frame.size.height - 20, screenWidth-50, h)];
    
    [button setTitle:title forState:UIControlStateNormal];
    [button setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    button.titleLabel.font = [UIFont boldSystemFontOfSize:18];
    [button setBackgroundImage:[UIImage imageNamed:@"btn_main"] forState:UIControlStateNormal];
    [button addTarget:self action:@selector(bottomClick:) forControlEvents:UIControlEventTouchUpInside];
    button.contentEdgeInsets = UIEdgeInsetsMake(0, 0, 19, 0);
    self.bottomButton = button;
    
    [self.viewMain addSubview:button];
}

- (void)constructBottom:(NSString*) title
{
    int h = 60;
    UIButton *button = [[UIButton alloc] initWithFrame:CGRectMake(25, screenHeight - 40 - h, screenWidth-50, h)];
    
    [button setTitle:title forState:UIControlStateNormal];
    [button setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    button.titleLabel.font = [UIFont boldSystemFontOfSize:18];
    [button setBackgroundColor:UIColorFromRGB(0xFF6A74)];
    //[button setBackgroundImage:[UIImage imageNamed:@"btn_main"] forState:UIControlStateNormal];
    [button addTarget:self action:@selector(bottomClick:) forControlEvents:UIControlEventTouchUpInside];
    //button.contentEdgeInsets = UIEdgeInsetsMake(0, 0, 19, 0);
    self.bottomButton = button;
    
    [self.view addSubview:button];
}
- (void)hideBottom {
    if(self.bottomButton)
        self.bottomButton.hidden = YES;
}
- (void)bottomClick:(id)sender{
    
}

- (void)constructBottomSecondary:(NSString*) title
{
    int h = 50;
    UIButton *button = [[UIButton alloc] initWithFrame:CGRectMake(25, screenHeight - 50 - h, screenWidth-50, h)];
    
    [button setTitle:title forState:UIControlStateNormal];
    button.titleLabel.font = [UIFont boldSystemFontOfSize:18];
    [button setTitleColor:UIColorFromRGB(0x4C69FF) forState:UIControlStateNormal];
    [button setBackgroundImage:[UIImage imageNamed:@"btn_secondary"] forState:UIControlStateNormal];
    [button addTarget:self action:@selector(bottomClick:) forControlEvents:UIControlEventTouchUpInside];
    self.bottomSecondaryButton = button;
    
    [self.view addSubview:button];
}


- (void)cellUpdated:(int)index view:(WildCardUIView *)v{
    
}

- (void)constructRightBackButton:(NSString*)png{
    UIButton *rightButton = [[UIButton alloc] initWithFrame:CGRectMake(0,0, 30,30)];
    rightButton.contentHorizontalAlignment = UIControlContentHorizontalAlignmentRight;
    [rightButton setImage:[UIImage imageNamed:png] forState:UIControlStateNormal];
    [rightButton addTarget:self action:@selector(rightClick:)
         forControlEvents:UIControlEventTouchUpInside];
    //[leftButton setShowsTouchWhenHighlighted:YES];
    
    //self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc] initWithCustomView:rightButton];
    
//    UIButton *rightButton2 = [[UIButton alloc] initWithFrame:CGRectMake(0,0, 30,30)];
//    rightButton2.contentHorizontalAlignment = UIControlContentHorizontalAlignmentRight;
//    [rightButton2 setImage:[UIImage imageNamed:png] forState:UIControlStateNormal];
//    [rightButton2 addTarget:self action:@selector(rightClick:)
//         forControlEvents:UIControlEventTouchUpInside];
         
    self.navigationItem.rightBarButtonItems = @[ 
        [[UIBarButtonItem alloc] initWithCustomView:rightButton],
        //[[UIBarButtonItem alloc] initWithCustomView:rightButton2]
    ];
}

- (void)rightClick:(id)sender{
    
}

-(BOOL)onInstanceCustomAction:(WildCardMeta *)meta function:(NSString*)functionName args:(NSArray*)args view:(WildCardUIView*) node{
    return false;
}
@end
