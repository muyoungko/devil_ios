//
//  DevilBlockDialog.h
//  DevilBlockDialog
//
//  Created by JonyFang on 2018/11/26.
//  Copyright © 2018年 JonyFang. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "WildCardUIView.h"

/**
 DevilBlockDialogShowType
 Controlled how the popup will be presented.
 */
typedef NS_ENUM(NSUInteger, DevilBlockDialogShowType) {
    DevilBlockDialogShowType_None NS_SWIFT_NAME(none),
    DevilBlockDialogShowType_FadeIn NS_SWIFT_NAME(fadeIn),
    DevilBlockDialogShowType_GrowIn NS_SWIFT_NAME(growIn),
    DevilBlockDialogShowType_ShrinkIn NS_SWIFT_NAME(shrinkIn),
    DevilBlockDialogShowType_SlideInFromTop NS_SWIFT_NAME(slideInFromTop),
    DevilBlockDialogShowType_SlideInFromBottom NS_SWIFT_NAME(slideInFromBottom),
    DevilBlockDialogShowType_SlideInFromLeft NS_SWIFT_NAME(slideInFromLeft),
    DevilBlockDialogShowType_SlideInFromRight NS_SWIFT_NAME(slideInFromRight),
    DevilBlockDialogShowType_BounceIn NS_SWIFT_NAME(bounceIn),
    DevilBlockDialogShowType_BounceInFromTop NS_SWIFT_NAME(bounceInFromTop),
    DevilBlockDialogShowType_BounceInFromBottom NS_SWIFT_NAME(bounceInFromBottom),
    DevilBlockDialogShowType_BounceInFromLeft NS_SWIFT_NAME(bounceInFromLeft),
    DevilBlockDialogShowType_BounceInFromRight NS_SWIFT_NAME(bounceInFromRight),
    DevilBlockDialogShowType_GrowFromPoint NS_SWIFT_NAME(growFromPoint)
} NS_SWIFT_NAME(DevilBlockDialog.ShowType);

/**
 DevilBlockDialogDismissType
 Controlled how the popup will be dismissed.
 */
typedef NS_ENUM(NSUInteger, DevilBlockDialogDismissType) {
    DevilBlockDialogDismissType_None NS_SWIFT_NAME(none),
    DevilBlockDialogDismissType_FadeOut NS_SWIFT_NAME(fadeOut),
    DevilBlockDialogDismissType_GrowOut NS_SWIFT_NAME(growOut),
    DevilBlockDialogDismissType_ShrinkOut NS_SWIFT_NAME(shrinkOut),
    DevilBlockDialogDismissType_SlideOutToTop NS_SWIFT_NAME(slideOutToTop),
    DevilBlockDialogDismissType_SlideOutToBottom NS_SWIFT_NAME(slideOutToBottom),
    DevilBlockDialogDismissType_SlideOutToLeft NS_SWIFT_NAME(slideOutToLeft),
    DevilBlockDialogDismissType_SlideOutToRight NS_SWIFT_NAME(slideOutToRight),
    DevilBlockDialogDismissType_BounceOut NS_SWIFT_NAME(bounceOut),
    DevilBlockDialogDismissType_BounceOutToTop NS_SWIFT_NAME(bounceOutToTop),
    DevilBlockDialogDismissType_BounceOutToBottom NS_SWIFT_NAME(bounceOutToBottom),
    DevilBlockDialogDismissType_BounceOutToLeft NS_SWIFT_NAME(bounceOutToLeft),
    DevilBlockDialogDismissType_BounceOutToRight NS_SWIFT_NAME(bounceOutToRight),
    DevilBlockDialogDismissType_ShrinkToPoint NS_SWIFT_NAME(shrinkToPoint)
} NS_SWIFT_NAME(DevilBlockDialog.DismissType);

/**
 DevilBlockDialogHorizontalLayout
 Controlled the layout of the popup in the horizontal direction.
 */
typedef NS_ENUM(NSUInteger, DevilBlockDialogHorizontalLayout) {
    DevilBlockDialogHorizontalLayout_Custom NS_SWIFT_NAME(custom),
    DevilBlockDialogHorizontalLayout_Left NS_SWIFT_NAME(left),
    DevilBlockDialogHorizontalLayout_LeftOfCenter NS_SWIFT_NAME(leftOfCenter),
    DevilBlockDialogHorizontalLayout_Center NS_SWIFT_NAME(center),
    DevilBlockDialogHorizontalLayout_RightOfCenter NS_SWIFT_NAME(rightOfCenter),
    DevilBlockDialogHorizontalLayout_Right NS_SWIFT_NAME(right)
} NS_SWIFT_NAME(DevilBlockDialog.HorizontalLayout);

/**
 DevilBlockDialogVerticalLayout
 Controlled the layout of the popup in the vertical direction.
 */
typedef NS_ENUM(NSUInteger, DevilBlockDialogVerticalLayout) {
    DevilBlockDialogVerticalLayout_Custom NS_SWIFT_NAME(custom),
    DevilBlockDialogVerticalLayout_Top NS_SWIFT_NAME(top),
    DevilBlockDialogVerticalLayout_AboveCenter NS_SWIFT_NAME(aboveCenter),
    DevilBlockDialogVerticalLayout_Center NS_SWIFT_NAME(center),
    DevilBlockDialogVerticalLayout_BelowCenter NS_SWIFT_NAME(belowCenter),
    DevilBlockDialogVerticalLayout_Bottom NS_SWIFT_NAME(bottom)
} NS_SWIFT_NAME(DevilBlockDialog.VerticalLayout);

/**
 DevilBlockDialogMaskType
 Controlled whether to allow interaction with the underlying view.
 */
typedef NS_ENUM(NSUInteger, DevilBlockDialogMaskType) {
    /// Allow interaction with underlying view.
    DevilBlockDialogMaskType_None NS_SWIFT_NAME(none),
    /// Don't allow interaction with underlying view.
    DevilBlockDialogMaskType_Clear NS_SWIFT_NAME(clear),
    /// Don't allow interaction with underlying view, dim background.
    DevilBlockDialogMaskType_Dimmed NS_SWIFT_NAME(dimmed)
} NS_SWIFT_NAME(DevilBlockDialog.MaskType);

/** DevilBlockDialogLayout */
struct DevilBlockDialogLayout {
    DevilBlockDialogHorizontalLayout horizontal;
    DevilBlockDialogVerticalLayout vertical;
};

typedef struct DevilBlockDialogLayout DevilBlockDialogLayout;

extern DevilBlockDialogLayout DevilBlockDialogLayoutMake(DevilBlockDialogHorizontalLayout horizontal, DevilBlockDialogVerticalLayout vertical) NS_SWIFT_NAME(DevilBlockDialogLayout(horizontal:vertical:));

extern DevilBlockDialogLayout const DevilBlockDialogLayout_Center NS_SWIFT_NAME(DevilBlockDialogLayout.Center);

NS_ASSUME_NONNULL_BEGIN

@interface DevilBlockDialog : UIView

@property (nonatomic, retain) WildCardUIView* wc;

/**
 The view you want to appear in popup.
 
 Must provide contentView before or in `-willStartShowing`.
 Must set size of contentView before or in `-willStartShowing`.
 */
@property (nonatomic, strong) UIView *contentView;

/**
 Animation transition for presenting contentView.
 
 @discussion The default value is `DevilBlockDialogShowType_BounceInFromTop`.
 */
@property (nonatomic, assign) DevilBlockDialogShowType showType;
@property (nonatomic, assign) int px;
@property (nonatomic, assign) int py;

/**
 Animation transition for dismissing contentView.
 
 @discussion The default value is `DevilBlockDialogDismissType_BounceOutToBottom`.
 */
@property (nonatomic, assign) DevilBlockDialogDismissType dismissType;

/**
 Mask prevents background touches from passing to underlying views.
 
 @discussion The default value is `DevilBlockDialogMaskType_Dimmed`.
 */
@property (nonatomic, assign) DevilBlockDialogMaskType maskType;

/**
 Overrides alpha value for dimmed mask.
 
 @discussion The default value is `0.5`.
 */
@property (nonatomic, assign) CGFloat dimmedMaskAlpha;

/**
 Overrides animation duration for show in.
 
 @discussion The default value is `0.15`.
 */
@property (nonatomic, assign) CGFloat showInDuration;

/**
 Overrides animation duration for dismiss out.
 
 @discussion The default value is `0.15`.
 */
@property (nonatomic, assign) CGFloat dismissOutDuration;

/**
 If `YES`, the popup will dismiss when background is touched.
 
 @discussion The default value is `YES`.
 */
@property (nonatomic, assign) BOOL shouldDismissOnBackgroundTouch;

/**
 If `YES`, the popup will dismiss when content view is touched.
 
 @discussion The default value is `NO`.
 */
@property (nonatomic, assign) BOOL shouldDismissOnContentTouch;

/**
 A block to be executed when showing animation started.
 The default value is nil.
 */
@property (nonatomic, copy, nullable) void(^willStartShowingBlock)(void);

/**
 A block to be executed when showing animation finished.
 The default value is nil.
 */
@property (nonatomic, copy, nullable) void(^didFinishShowingBlock)(void);

/**
 A block to be executed when dismissing animation started.
 The default value is nil.
 */
@property (nonatomic, copy, nullable) void(^willStartDismissingBlock)(void);

/**
 A block to be executed when dismissing animation finished.
 The default value is nil.
 */
@property (nonatomic, copy, nullable) void(^didFinishDismissingBlock)(void);

/**
 Convenience Initializers
 Create a new popup with `contentView`.
 */
+ (DevilBlockDialog *)popupWithContentView:(UIView *)contentView NS_SWIFT_NAME(init(contentView:));

/**
 Convenience Initializers
 Create a new popup with custom values.
 
 @param contentView The view you want to appear in popup.
 @param showType    The default value is `DevilBlockDialogShowType_BounceInFromTop`.
 @param dismissType The default value is `DevilBlockDialogDismissType_BounceOutToBottom`.
 @param maskType    The default value is `DevilBlockDialogMaskType_Dimmed`.
 @param shouldDismissOnBackgroundTouch  The default value is `YES`.
 @param shouldDismissOnContentTouch     The default value is `NO`.
 */
+ (DevilBlockDialog *)popupWithContentView:(UIView *)contentView
                         showType:(DevilBlockDialogShowType)showType
                      dismissType:(DevilBlockDialogDismissType)dismissType
                         maskType:(DevilBlockDialogMaskType)maskType
         dismissOnBackgroundTouch:(BOOL)shouldDismissOnBackgroundTouch
            dismissOnContentTouch:(BOOL)shouldDismissOnContentTouch NS_SWIFT_NAME(init(contetnView:showType:dismissType:maskType:dismissOnBackgroundTouch:dismissOnContentTouch:));

/**
 Dismiss all the popups in the app.
 */
+ (void)dismissAllPopups NS_SWIFT_NAME(dismissAll());

/**
 Dismiss the popup for contentView.
 */
+ (void)dismissPopupForView:(UIView *)view animated:(BOOL)animated NS_SWIFT_NAME(dismiss(contentView:animated:));

/**
 Dismiss super popup.
 Iterate over superviews until you find a `DevilBlockDialog` and dismiss it.
 */
+ (void)dismissSuperPopupIn:(UIView *)view animated:(BOOL)animated NS_SWIFT_NAME(dismissSuperPopup(inView:animated:));

/**
 Show popup with center layout.
 `DevilBlockDialogVerticalLayout_Center` & `DevilBlockDialogHorizontalLayout_Center`
 Showing animation is determined by `showType`.
 */
- (void)show;

/**
 Show popup with specified layout.
 Showing animation is determined by `showType`.
 */
- (void)showWithLayout:(DevilBlockDialogLayout)layout NS_SWIFT_NAME(show(layout:));

/**
 Show and then dismiss popup after `duration`.
 If duration is `0.0` or `less`, it will be considered infinity.
 */
- (void)showWithDuration:(NSTimeInterval)duration NS_SWIFT_NAME(show(duration:));

/**
 Show popup with specified `layout` and then dismissed after `duration`.
 If duration is `0.0` or `less`, it will be considered infinity.
 */
- (void)showWithLayout:(DevilBlockDialogLayout)layout duration:(NSTimeInterval)duration NS_SWIFT_NAME(show(layout:duration:));

/**
 Show popup at point in view's coordinate system.
 If view is nil, will use screen base coordinates.
 */
- (void)showAtCenterPoint:(CGPoint)point inView:(UIView *)view NS_SWIFT_NAME(show(center:inView:));

/**
 Show popup at point in view's coordinate system and then dismissed after duration.
 If view is nil, will use screen base coordinates.
 If duration is `0.0` or `less`, it will be considered infinity.
 */
- (void)showAtCenterPoint:(CGPoint)point inView:(UIView *)view duration:(NSTimeInterval)duration NS_SWIFT_NAME(show(center:inView:duration:));

/**
 Dismiss popup.
 Use `dismissType` if animated is `YES`.
 */
- (void)dismissAnimated:(BOOL)animated NS_SWIFT_NAME(dismiss(animated:));

#pragma mark - ReadOnly Properties
@property (nonatomic, strong, readonly) UIView *backgroundView;
@property (nonatomic, strong, readonly) UIView *containerView;
@property (nonatomic, assign, readonly) BOOL isBeingShown;
@property (nonatomic, assign, readonly) BOOL isShowing;
@property (nonatomic, assign, readonly) BOOL isBeingDismissed;

+ (UIButton*)getButton:(CGRect)rect :(NSString*)name;
- (void)dismiss;
- (void)dismissWithCallback:(BOOL)yes;
- (void)update;

+ (DevilBlockDialog *)popup:(NSString*)blockName data:(id)data title:(NSString*)title yes:(NSString*)yes no:(NSString*)no show:(NSString*)show onselect:(void (^)(BOOL yes, id res))callback;
+ (DevilBlockDialog *)popup:(NSString*)blockName data:(id)data title:(NSString*)title yes:(NSString*)yes no:(NSString*)no show:(NSString*)show delegate:(id)wildCardConstructorInstanceDelegate onselect:(void (^)(BOOL yes, id res))callback;
+ (DevilBlockDialog *)popup:(NSString*)blockName data:(id)data title:(NSString*)titleText yes:(NSString*)yes no:(NSString*)no show:(NSString*)show  param:(id)param delegate:(id)wildCardConstructorInstanceDelegate onselect:(void (^)(BOOL yes, id res))callback;
- (void)buttonClick:(UIView*)sender;

@property void (^callback)(BOOL yes, id res);
@property (nonatomic, retain) NSString* yes_node_name;
@property (nonatomic, retain) NSString* no_node_name;
@property BOOL auto_dismiss;

@end

NS_ASSUME_NONNULL_END
