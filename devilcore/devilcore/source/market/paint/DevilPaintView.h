//
//  DevilPaint.h
//  devilcore
//
//  Created by Mu Young Ko on 2024/02/07.
//  Code is from https://github.com/michalkonturek/SignatureView
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

@interface DevilPaintView : UIImageView

@property (nonatomic, strong) UIColor *bgColor;

@property (nonatomic, strong) UIColor *foregroundLineColor;
@property (nonatomic, strong) UIColor *backgroundLineColor;

@property (nonatomic, assign) CGFloat foregroundLineWidth;
@property (nonatomic, assign) CGFloat backgroundLineWidth;

@property (nonatomic, strong) UILongPressGestureRecognizer *recognizer;

- (void)setLineColor:(UIColor *)color;
- (void)setLineWidth:(CGFloat)width;

- (void)clear;
- (void)clearWithColor:(UIColor *)color;

- (UIImage *)signatureImage;
- (NSData *)signatureData;

- (BOOL)isSigned;

@end

NS_ASSUME_NONNULL_END
