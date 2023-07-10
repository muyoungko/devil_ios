//
//  PartialController.m
//  capblapp
//
//  Created by Mu Young Ko on 2022/03/13.
//

#import "CapblPartialController.h"
#import "SecureView.h"

@interface CapblPartialController () <UITextFieldDelegate>

@property (retain, nonatomic) SecureView *secureView;

@end

@implementation CapblPartialController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.title = @"Partial View Scure";
    [[NSBundle mainBundle] loadNibNamed:@"CapblPartialController" owner:self options:nil];
    
    self.secureView = [[SecureView alloc] initWithFrame:self.redView.frame];
    [self.redView removeFromSuperview];
    self.redView.frame = CGRectMake(0, 0, self.redView.frame.size.width, self.redView.frame.size.height);
    [self.secureView addSubview:self.redView];
    [self.view addSubview:self.secureView];
    
    
    [self.secureView makeSecure];
}


- (IBAction)button:(id)sender {
    
}

- (IBAction)button2:(id)sender {
    NSLog(@"first responder ? %@", self.tf.isFirstResponder?@"yes":@"no");
    [self.view endEditing:YES];
}

@end
