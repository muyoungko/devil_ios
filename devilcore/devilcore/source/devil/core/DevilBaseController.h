//
//  DevilBaseController.h
//  devilcore
//
//  Created by Mu Young Ko on 2020/12/04.
//

#import <UIKit/UIKit.h>
#import "WildCardScreenTableView.h"
#import "DevilSelectDialog.h"
#import "DevilBlockDialog.h"
#import "WifiManager.h"

NS_ASSUME_NONNULL_BEGIN

@interface DevilBaseController : UIViewController
{
    int screenWidth, screenHeight;
    CGPoint editingPoint;
    UIView* editingView;
}

@property (nonatomic, retain) DevilBlockDialog* devilBlockDialog;
@property (nonatomic, retain) DevilSelectDialog* devilSelectDialog;
@property (nonatomic, retain) WifiManager* wifiManager;

- (void)showIndicator;
- (void)hideIndicator;

@end

NS_ASSUME_NONNULL_END
