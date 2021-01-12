//
//  WildCardUIView.m
//  CloudJsonViewer
//
//  Created by Mu Young Ko on 2018. 6. 18..
//  Copyright © 2018년 Mu Young Ko. All rights reserved.
//

#import "WildCardUIView.h"
#import "WildCardConstructor.h"

@implementation WildCardUIView


//-(void)drawRect:(CGRect)rect{
//    [super drawRect:rect];
//}

- (NSString *)description
{
    NSString *s = [super description];
    return [NSString stringWithFormat:@"%@ name : %@",s,  _name];
}
- (void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event
{
    NSString* instanceKey = [NSString stringWithFormat:@"%lx", (long)self];
    NSLog(@"WC - touchesBegan %@ %@", _name , instanceKey);
    return ;
}
- (void)touchesCancelled:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event
{
    
}
- (void)touchesEnded:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event
{
    
}

- (instancetype)init
{
    self = [super init];
    if (self) {
        self.alignment = GRAVITY_LEFT | GRAVITY_TOP;
        self.wrap_width = NO;
        self.wrap_height = NO;
        self.cornerRadiusHalf = NO;
        self.tags = [@{} mutableCopy];
    }
    return self;
}

- (void)setFrame:(CGRect)frame
{
    [super setFrame:frame];
    if(_cornerRadiusHalf)
    {
        self.layer.cornerRadius = frame.size.height / 2.0f;
    }
}

//- (void)drawRect:(CGRect)rect
//{
//    [super drawRect:rect];
////    CGContextRef ctx = UIGraphicsGetCurrentContext();
////    CGContextSaveGState(ctx);
////
////
////    CGPathRef clippath = [UIBezierPath bezierPathWithRoundedRect:CGRectMake(x,y, width, height) cornerRadius:6].CGPath;
////    CGContextAddPath(ctx, clippath);
////
////    CGContextSetFillColorWithColor(ctx, self.color.CGColor);
////
////    CGContextClosePath(ctx);
////    CGContextFillPath(ctx);
////
////    [self.color set];
////
////
////    [_path closePath]; // Implicitly does a line between p4 and p1
////    [_path fill]; // If you want it filled, or...
////    [_path stroke]; // ...if you want to draw the outline.
////    CGContextRestoreGState(ctx);
//}




@end
