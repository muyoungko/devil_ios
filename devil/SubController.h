//
//  SubController.h
//  sticar
//
//  Created by Mu Young Ko on 2019. 6. 10..
//  Copyright © 2019년 trix. All rights reserved.
//

#import "BaseController.h"

NS_ASSUME_NONNULL_BEGIN

@interface SubController : BaseController<WildCardConstructorInstanceDelegate, WildCardScreenTableViewDelegate>

@property int viewHeight;
@property int offsetY;
@property (nonatomic, retain) WildCardUIView* mainWc;
@property(nonatomic, retain) UIButton* bottomButton;
@property(nonatomic, retain) UIButton* bottomSecondaryButton;
@property(nonatomic, retain) UIScrollView* scrollView;
@property (nonatomic, retain) WildCardScreenTableView* tv;
@property (nonatomic, retain) UIView* noneView;
@property(nonatomic, retain) NSMutableDictionary* data;

- (void)createWildCardScreenListView:(NSString*)screenName;

- (void)showNavigationBar;
- (void)hideNavigationBar;

- (void)constructScrollView;
- (void)reloadBlock;
- (void)constructBlockUnder:(NSString*)block;
- (void)constructBlockUnderScrollView:(NSString*)block;

- (void)constructBottomBelowViewMain:(NSString*) title;
- (void)constructBottom:(NSString*) title;
- (void)hideBottom;
- (void)constructBottomSecondary:(NSString*) title;
- (void)bottomClick:(id)sender;

- (void)setTitleLogo;
- (void)popToMain:(NSString*)tabName;

- (void)constructRightBackButton:(NSString*)png;
- (void)rightClick:(id)sender;

@end

NS_ASSUME_NONNULL_END
