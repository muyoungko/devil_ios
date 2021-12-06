//
//  WildCardProgressBar.h
//  devilcore
//
//  Created by Mu Young Ko on 2021/04/16.
//

#import <Foundation/Foundation.h>
#import "WildCardUIView.h"
#import "WildCardMeta.h"

@import UIKit;

NS_ASSUME_NONNULL_BEGIN

@interface WildCardProgressBar : NSObject

@property BOOL dragable;
@property BOOL vertical;
@property BOOL moving;
@property (nonatomic, retain) WildCardMeta* meta;
@property (nonatomic, retain) WildCardUIView* progressGroup;
@property (nonatomic, retain) WildCardUIView* cap;
@property (nonatomic, retain) WildCardUIView* bar;
@property (nonatomic, retain) WildCardUIView* bar_bg;
@property (nonatomic, retain) NSString* watch;

@property (nonatomic, retain) NSString* dragUpScript;
@property (nonatomic, retain) NSString* moveScript;

-(void)construct;
-(void)update;

@end

NS_ASSUME_NONNULL_END
