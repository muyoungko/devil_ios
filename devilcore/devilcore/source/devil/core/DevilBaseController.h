//
//  DevilBaseController.h
//  devilcore
//
//  Created by Mu Young Ko on 2020/12/04.
//

#import <UIKit/UIKit.h>
#import "DevilSelectDialog.h"
#import "DevilBlockDialog.h"
#import "WifiManager.h"
#import "WildCardUIView.h"

NS_ASSUME_NONNULL_BEGIN

@interface DevilBaseController : UIViewController<UIDocumentInteractionControllerDelegate>
{
    int screenWidth, screenHeight;
    CGPoint editingPoint;
    UIView* editingView;
    BOOL editingInFooter;
    BOOL editingNumberKey;
    UIReturnKeyType numberKeyType;
}

@property (nonatomic, retain) id retainObject;

@property (nonatomic, retain) DevilBlockDialog* devilBlockDialog;
@property (nonatomic, retain) DevilSelectDialog* devilSelectDialog;
@property (nonatomic, retain) WifiManager* wifiManager;

@property int original_footer_height;
@property int original_footer_height_plus_bottom_padding;
@property int original_footer_y;
@property int header_sketch_height;
@property float bottomPadding;
@property BOOL isFooterVariableHeight;
@property int keyboard_height;
@property int footer_sketch_height;
@property BOOL fix_footer;
@property (nonatomic, retain) WildCardUIView* footer;
@property (nonatomic, retain) WildCardUIView* inside_footer;

@property (nonatomic, retain) UIAlertController* activeAlert;
@property CGRect keyboardRect;
@property BOOL keyboardOn;
@property BOOL landscape;

@property (nonatomic, retain) NSString* projectId;
@property (nonatomic, retain) NSString* screenId;
@property (nonatomic, retain) NSString* screenName;

- (void)adjustFooterPositionOnKeyboard;
- (void)keyboardDidShow:(NSNotification*)noti;
- (void)keyboardWillHide:(NSNotification*)noti;
- (void)updateFlexScreen;
- (void)orientationChanged:(NSNotification*)noti;

@end

NS_ASSUME_NONNULL_END
