//
//  DevilBlockDialog.m
//  devilcore
//
//  Created by Mu Young Ko on 2021/02/01.
//

#import "DevilBlockDialog.h"
#import "WildCardConstructor.h"

@interface DevilBlockDialog()

@property (nonatomic) WildCardUIView *wc;

@end

@implementation DevilBlockDialog

-(id)initWithViewController:(UIViewController*)vc {
    self = [super init];
    self.vc = vc;
    return self;
}

-(void)popup:(NSString*)blockName data:(id)data title:(NSString*)title yes:(NSString*)yes no:(NSString*)no onselect:(void (^)(id res))callback{
    UIAlertController *alertController = [UIAlertController alertControllerWithTitle:nil message:nil preferredStyle:UIAlertControllerStyleAlert];
    
    NSString* blockId = [[WildCardConstructor sharedInstance] getBlockIdByName:blockName];
    id cj = [[WildCardConstructor sharedInstance] getBlockJson:blockId];
    self.wc = [WildCardConstructor constructLayer:nil withLayer:cj];
    [WildCardConstructor applyRule:self.wc withData:data];
    UIViewController* content = [[UIViewController alloc] init];
    
    content.view = self.wc;
    content.preferredContentSize = CGSizeMake(self.wc.frame.size.width,
                                              self.wc.frame.size.height);
    
    for(NSLayoutConstraint* con in alertController.view.constraints){
        if(con.firstAttribute == NSLayoutAttributeWidth){
            [alertController.view removeConstraint:con];
            break;
        }
    }
    NSLayoutConstraint* widthConstraint = [NSLayoutConstraint constraintWithItem:alertController.view attribute:NSLayoutAttributeWidth relatedBy:NSLayoutRelationEqual toItem:nil attribute:NSLayoutAttributeNotAnAttribute multiplier:1 constant:self.wc.frame.size.width];
    [alertController.view addConstraint:widthConstraint];
    
    UIView* firstContainer = [alertController.view subviews][0];
    for(NSLayoutConstraint* con in firstContainer.constraints){
        if(con.firstAttribute == NSLayoutAttributeWidth && con.secondItem == nil){
            [firstContainer removeConstraint:con];
            break;
        }
    }
//    NSLayoutConstraint* widthConstraint2 = [NSLayoutConstraint constraintWithItem:firstContainer attribute:NSLayoutAttributeWidth relatedBy:NSLayoutRelationEqual toItem:alertController.view attribute:NSLayoutAttributeNotAnAttribute multiplier:1 constant:0];
//    [firstContainer addConstraint:widthConstraint2];
    
    alertController.title = title;
    
    [alertController setValue:content forKey:@"contentViewController"];
    UIAlertAction *cancelAction = [UIAlertAction actionWithTitle:no style:UIAlertActionStyleCancel handler:^(UIAlertAction *action) {
        callback(@FALSE);
    }];
    [alertController addAction:cancelAction];
    
    UIAlertAction *yesAction = [UIAlertAction actionWithTitle:yes style:UIAlertActionStyleDefault handler:^(UIAlertAction *action) {
        callback(@TRUE);
    }];
    [alertController addAction:yesAction];
    
    [self.vc presentViewController:alertController animated:YES completion:^{
        alertController.view.superview.userInteractionEnabled = YES;
        [alertController.view.superview addGestureRecognizer:[[UITapGestureRecognizer alloc] initWithTarget: self action: @selector(alertControllerBackgroundTapped)]];
 
    }];
}

- (void)alertControllerBackgroundTapped
{
    [self.vc dismissViewControllerAnimated: YES completion: nil];
}

@end
