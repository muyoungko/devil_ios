//
//  HiddenController.m
//  capblapp
//
//  Created by Mu Young Ko on 2023/05/18.
//

#import "CapblSecureViewController.h"
#import "SecureView.h"

@interface CapblSecureViewController ()

@property (nonatomic, retain) SecureView* secureView;

@end

@implementation CapblSecureViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.secureView = [[SecureView alloc] initWithFrame:
                      CGRectMake(0, 0, self.view.frame.size.width, self.view.frame.size.width)];
    
    for(UIView* v in [self.view subviews]) {
        [v removeFromSuperview];
        [self.secureView addSubview:v];
    }
    [self.view addSubview: self.secureView];
    [self.secureView makeSecure];
}


@end
