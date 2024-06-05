//
//  ZoomableImageView.h
//  devilcore
//
//  Created by Mu Young Ko on 2024/06/05.
//

#import <UIKit/UIKit.h>
#import "WildCardUIView.h"

NS_ASSUME_NONNULL_BEGIN

@interface ZoomableImageView : UIScrollView<UIScrollViewDelegate>

-(void)makeZoomable:(UIImageView*)imageView;
-(void)updateContentSize;

@end

NS_ASSUME_NONNULL_END
