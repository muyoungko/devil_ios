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

@class MetaAndViewResult;

@interface DevilController : DevilBaseController<WildCardConstructorInstanceDelegate,
UIDocumentInteractionControllerDelegate, UIScrollViewDelegate>
{
}

-(void)showNavigationBar;
-(void)hideNavigationBar;
-(void)updateMeta;
-(void)tab:(NSString*)screenId;
-(void)onResume;
-(void)onPause;
-(void)finish;
-(void)alertFinish:(NSString*)msg;
-(WildCardUIView*)findView:(NSString*)name;
-(MetaAndViewResult*)findViewWithMeta:(NSString*)name;
-(void)adjustFooterHeight;
-(void)setActiveAlertMessage:(NSString*)msg;
-(void)closeActiveAlertMessage;
-(void) addFixedView:(id)layer x:(float)x y:(float)y :(UIView*)fixNodeView;
-(void)toLandscape;
-(void)toPortrait;
-(void)startLoading;
-(void)stopLoading;

@property (nonatomic, retain) JevilCtx* jevil;
@property (nonatomic, retain) id startData;

@property(nonatomic, retain) JSValue* data;
@property int viewHeight;
@property int offsetY;
@property (nonatomic, retain) WildCardUIView* mainWc;
@property (nonatomic, retain) UIScrollView* scrollView;
@property (nonatomic, retain) UIView* viewMain;
@property (nonatomic, retain) UIView* fixedViewContainer;
@property (nonatomic, retain) UIView* fixedView;
@property BOOL (^onBackPressCallback)();
@property BOOL blockOrientationChange;

-(void)debugView;
@property (nonatomic, retain) NSMutableDictionary* viewPagerReservedSelectedIndexMap;
@property (nonatomic, retain) NSMutableDictionary* viewPagerReservedSelectedCallbackMap;

@end

@interface MetaAndViewResult : NSObject
@property (nonatomic, retain) WildCardMeta* meta;
@property (nonatomic, retain) WildCardUIView* view;
@end

NS_ASSUME_NONNULL_END
