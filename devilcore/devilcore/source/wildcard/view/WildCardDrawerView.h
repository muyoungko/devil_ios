//
//  WildCardDrawerView.h
//  sticar
//
//  Created by Mu Young Ko on 2019. 6. 14..
//  Copyright © 2019년 trix. All rights reserved.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

#define MENU_WIDTH 320
#define MODAL_ALPHA 0.7f

@interface WildCardDrawerView : UIView
{
    int screenWidth, screenHeight;
    int naviStatus;
    int pointerId;
    float touchStartX;
    double touchTime;
    float uiMenuStartX;
}

@property (nonatomic, retain) UIView* viewModal;
@property (nonatomic, retain) UIView* viewMenu;

- (void)naviDown;
- (void)naviUp;

@end

NS_ASSUME_NONNULL_END
