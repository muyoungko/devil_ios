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
#import "WildCardUIView.h"

NS_ASSUME_NONNULL_BEGIN

@interface DevilBaseController : UIViewController
{
    int screenWidth, screenHeight;
    CGPoint editingPoint;
    UIView* editingView;
    BOOL editingInFooter;
    BOOL editingNumberKey;
    UIReturnKeyType numberKeyType;
}

@property (nonatomic, retain) DevilBlockDialog* devilBlockDialog;
@property (nonatomic, retain) DevilSelectDialog* devilSelectDialog;
@property (nonatomic, retain) WifiManager* wifiManager;

@property (nonatomic, retain) WildCardUIView* footer;
@property int original_footer_height;
@property int original_footer_y;
@property int keyboard_height;
@property int footer_sketch_height;

- (void)showIndicator;
- (void)hideIndicator;

@end

NS_ASSUME_NONNULL_END
