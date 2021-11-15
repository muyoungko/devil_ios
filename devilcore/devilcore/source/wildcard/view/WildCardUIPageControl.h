//
//  WildCardUIPageControl.h
//  devilcore
//
//  Created by Mu Young Ko on 2021/11/08.
//

#import <UIKit/UIKit.h>
#import "WildCardMeta.h"

NS_ASSUME_NONNULL_BEGIN

@interface WildCardUIPageControl : UIPageControl
@property(nonatomic, retain) WildCardMeta* meta;
@property(nonatomic, retain) NSString* viewPagerNodeName;
@end

NS_ASSUME_NONNULL_END
