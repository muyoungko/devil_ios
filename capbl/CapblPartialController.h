//
//  PartialController.h
//  capblapp
//
//  Created by Mu Young Ko on 2022/03/13.
//

#import <UIKit/UIKit.h>
#import "SecureView.h"

NS_ASSUME_NONNULL_BEGIN

@interface CapblPartialController : UIViewController
- (IBAction)button:(id)sender;
- (IBAction)button2:(id)sender;
@property (weak, nonatomic) IBOutlet UITextField *tf;

@property (weak, nonatomic) IBOutlet UIView *redView;

@end

NS_ASSUME_NONNULL_END
