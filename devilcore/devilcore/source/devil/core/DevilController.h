//
//  DevilController.h
//  devilcore
//
//  Created by Mu Young Ko on 2020/12/04.
//

#import <UIKit/UIKit.h>
#import "DevilBaseController.h"
#import "WildCardConstructor.h"
@import JavaScriptCore;

NS_ASSUME_NONNULL_BEGIN

@interface DevilController : DevilBaseController<WildCardConstructorInstanceDelegate, WildCardScreenTableViewDelegate, WildCardConstructorLoading,
UIDocumentInteractionControllerDelegate>
{
}

-(void)showNavigationBar;
-(void)hideNavigationBar;
-(void)updateMeta;
-(void)tab:(NSString*)screenId;
-(void)onResume;
-(void)finish;
-(void)alertFinish:(NSString*)msg;
-(WildCardUIView*)findView:(NSString*)name;
@property (nonatomic, retain) JevilCtx* jevil;
@property (nonatomic, retain) NSString* projectId;
@property (nonatomic, retain) NSString* screenId;
@property (nonatomic, retain) NSString* screenName;
@property (nonatomic, retain) id startData;

@property(nonatomic, retain) NSMutableDictionary* data;
@property int viewHeight;
@property int offsetY;
@property (nonatomic, retain) WildCardUIView* mainWc;
@property (nonatomic, retain) UIScrollView* scrollView;
@property (nonatomic, retain) UIView* viewMain;
@property (nonatomic, retain) UIView* viewExtend;
@property (nonatomic, retain) WildCardScreenTableView* tv;

@property BOOL (^onBackPressCallback)();

-(void)debugView;

@end

NS_ASSUME_NONNULL_END
