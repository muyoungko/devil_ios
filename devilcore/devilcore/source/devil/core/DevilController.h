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

@interface DevilController : DevilBaseController<WildCardConstructorInstanceDelegate, WildCardScreenTableViewDelegate, WildCardConstructorLoading>
{
}

-(void)showNavigationBar;
-(void)hideNavigationBar;
-(void)updateMeta;
-(void)tab:(NSString*)screenId;

@property (nonatomic, retain) NSString* screenId;
@property (nonatomic, retain) NSString* dataString;

@property(nonatomic, retain) NSMutableDictionary* data;
@property int viewHeight;
@property int offsetY;
@property (nonatomic, retain) WildCardUIView* mainWc;
@property (nonatomic, retain) UIScrollView* scrollView;
@property (nonatomic, retain) UIView* viewMain;
@property (nonatomic, retain) WildCardScreenTableView* tv;



@end

NS_ASSUME_NONNULL_END
