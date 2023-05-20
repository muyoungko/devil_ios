//
//  WildCardUIView.h
//  CloudJsonViewer
//
//  Created by Mu Young Ko on 2018. 6. 18..
//  Copyright © 2018년 Mu Young Ko. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "WildCardMeta.h"

#define GRAVITY_TOP 0
#define GRAVITY_VERTICAL_CENTER 16
#define GRAVITY_BOTTOM 80
#define GRAVITY_LEFT 3
#define GRAVITY_HORIZONTAL_CENTER 1
#define GRAVITY_RIGHT 5
#define GRAVITY_CENTER 17

#define GRAVITY_LEFT_TOP 51
#define GRAVITY_LEFT_VCENTER 19
#define GRAVITY_LEFT_BOTTOM 83

#define GRAVITY_RIGHT_TOP 53
#define GRAVITY_RIGHT_VCENTER 21
#define GRAVITY_RIGHT_BOTTOM 85

#define GRAVITY_HCENTER_TOP 49
#define GRAVITY_HCENTER_BOTTOM 81

#define TOUCH_ACTION_DOWN 1
#define TOUCH_ACTION_MOVE 2
#define TOUCH_ACTION_UP 3
#define TOUCH_ACTION_CANCEL 4

@interface WildCardUIView : UIView

@property (retain, nonatomic) WildCardMeta* meta;
@property (retain, nonatomic) NSString* stringTag;
@property BOOL wrap_width;
@property BOOL wrap_height;
@property BOOL match_height;

@property int alignment;

@property int depth;
@property float rightMargin;
@property float bottomMargin;

@property float paddingLeft;
@property float paddingRight;
@property float paddingTop;
@property float paddingBottom;

@property BOOL cornerRadiusHalf;

@property (retain, nonatomic) NSString* name;

@property (retain, nonatomic) NSMutableDictionary* tags;
@property BOOL passHitTest;

- (void)addTouchCallback:(void (^)(int action, CGPoint p))callback;

/**
 키보드 업 등에 의한 일시적 뷰 위치를 조정할 경우 Jevil.update()에 의한 뷰 frame조정을 받지 않아야한다. 이럴경우 frameUpdateAvoid를 true로 설정한다
 이 경우 WildCardMeta.requestLayout의 영향을 받지 않는다
 */
@property BOOL frameUpdateAvoid;

@end
