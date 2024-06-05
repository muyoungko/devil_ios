//
//  ZoomableImageView.m
//  devilcore
//
//  Created by Mu Young Ko on 2024/06/05.
//

#import "ZoomableImageView.h"

@interface ZoomableImageView()
@property (nonatomic, retain) UIImageView* imageView;
@end

@implementation ZoomableImageView

/*
 // Only override drawRect: if you perform custom drawing.
 // An empty implementation adversely affects performance during animation.
 - (void)drawRect:(CGRect)rect {
 // Drawing code
 }
 */

-(void)makeZoomable:(UIImageView*)imageView {
    self.imageView = imageView;
    
    self.bounces = NO;
    self.bouncesZoom = NO;
    self.clipsToBounds = NO;
    self.autoresizesSubviews = NO;
    self.userInteractionEnabled = YES;
    self.scrollEnabled = YES;
    self.delegate = self;
    [self addSubview:imageView];
    
    imageView.frame = CGRectMake(0, 0, self.frame.size.width*4, self.frame.size.height*4);
    self.contentSize = imageView.frame.size;
    
    self.minimumZoomScale = 1.0f / 4.0f;
    self.maximumZoomScale = 3;
    self.zoomScale = 1.0f / 4.0f;
    self.showsHorizontalScrollIndicator = NO;
    self.showsVerticalScrollIndicator = NO;
}

-(void)updateContentSize {
    float w = self.imageView.frame.size.width;
    float h = self.imageView.frame.size.height;
    self.imageView.frame = CGRectMake(0, 0, w, h);
    self.contentSize = CGSizeMake(w, h);
    
    self.minimumZoomScale = 1.0f / 4.0f;
    self.maximumZoomScale = 4;
    self.zoomScale = 1.0f / 4.0f;
}

- (void)scrollViewWillEndDragging:(UIScrollView *)scrollView withVelocity:(CGPoint)velocity targetContentOffset:(inout CGPoint *)targetContentOffset {

}

- (UIView *)viewForZoomingInScrollView:(UIScrollView *)scrollView {
    return self.imageView;
}

@end
