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
#define GRAVITY_BOTTOM 2
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



@interface WildCardUIView : UIView

@property (retain, nonatomic) WildCardMeta* meta;
@property (retain, nonatomic) NSString* stringTag;
@property BOOL wrap_width;
@property BOOL wrap_height;

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









@end
