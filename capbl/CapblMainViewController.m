//
//  ViewController.m
//  capblapp
//
//  Created by Mu Young Ko on 2022/03/13.
//

#import "CapblMainViewController.h"
#import "CapblWebController.h"
#import "CapblPartialController.h"
#import "CapblTableController.h"
#import "CapblSecureViewController.h"

#define UIColorFromRGB(rgbValue) \
[UIColor colorWithRed:((float)((rgbValue & 0xFF0000) >> 16))/255.0 \
green:((float)((rgbValue & 0x00FF00) >>  8))/255.0 \
blue:((float)((rgbValue & 0x0000FF) >>  0))/255.0 \
alpha:1.0]

@interface CapblMainViewController ()

@end

@implementation CapblMainViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    // Do any additional setup after loading the view.
    [[NSBundle mainBundle] loadNibNamed:@"CapblMainViewController" owner:self options:nil];
    self.title = @"MAIN";
    [self constructHeader];
}

- (IBAction)onClickView:(id)sender {
    CapblSecureViewController* w = [[CapblSecureViewController alloc] init];
    [self.navigationController pushViewController:w animated:YES];
}

- (IBAction)onClickTableView:(id)sender {
    CapblTableController* w = [[CapblTableController alloc] init];
    [self.navigationController pushViewController:w animated:YES];
}

- (IBAction)onClickPartialView:(id)sender {
    CapblPartialController* w = [[CapblPartialController alloc] init];
    [self.navigationController pushViewController:w animated:YES];
}

- (IBAction)onClickWeb:(id)sender {
    [CapblWebController goUrlAbsolute:self url:@"https://www.google.co.kr"];
}

-(void)constructHeader {
    [self.navigationController.navigationBar setBarTintColor:UIColorFromRGB(0xffffff)];
    [self.navigationController.navigationBar setBackgroundColor:UIColorFromRGB(0xffffff)];
    [self.navigationController.navigationBar setAlpha:1.0f];
    [[UINavigationBar appearance] setBarStyle:UIBarStyleBlackOpaque];
    [[UINavigationBar appearance] setAlpha:1.0f];
    [self.navigationController.navigationBar setTranslucent:true];
    
    self.navigationController.navigationBar.titleTextAttributes = @{
        NSForegroundColorAttributeName : UIColorFromRGB(0x000000),
    };

}

@end
