//
//  DevilController.h
//  devilcore
//
//  Created by Mu Young Ko on 2020/12/04.
//

#import <UIKit/UIKit.h>
#import "DevilBaseController.h"
#import "WildCardConstructor.h"

NS_ASSUME_NONNULL_BEGIN

@interface DevilController : DevilBaseController<WildCardConstructorInstanceDelegate, WildCardScreenTableViewDelegate>
{
    int screenWidth, screenHeight;
}

- (void)showNavigationBar;
- (void)hideNavigationBar;

@property(nonatomic, retain) NSMutableDictionary* data;
@property int viewHeight;
@property int offsetY;
@property (nonatomic, retain) WildCardUIView* mainWc;
@property (nonatomic, retain) UIScrollView* scrollView;
@property (nonatomic, retain) UIView* viewMain;
@property (nonatomic, retain) WildCardScreenTableView* tv;

@property (nonatomic, retain) NSString* screenId;

@end

NS_ASSUME_NONNULL_END
