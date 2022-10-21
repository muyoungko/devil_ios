//
//  DevilPinLayer.m
//  devilcore
//
//  Created by Mu Young Ko on 2022/09/08.
//

#import "DevilPinLayer.h"
#import "WildCardUtil.h"

@interface DevilPinLayer()
@property (nonatomic, retain) id shapes;
@property (nonatomic, retain) id shapeMapArrowLine;
@property (nonatomic, retain) id shapeMapArrowHead;
@property (nonatomic, retain) id shapeMapText;
@property (nonatomic, retain) id shapeMapBody;

@property (nonatomic, retain) NSString* highlightKey;
@end
@implementation DevilPinLayer

float width = 3;
float roundSize = 14;
float arrowLength = 29;
float textSize = 15;

- (void)updatePinDirection:(NSString*)key {
    id pin = nil;
    for(id p in self.pinList) {
        if([p[@"key"] isEqualToString:key]){
            pin = p;
            break;
        }
    }
    if(!pin)
        return;
    
    float x = [pin[@"x"] floatValue];
    float y = [pin[@"y"] floatValue];
    NSLog(@"base Point %d %d", (int)x, (int)y);
    
    float degree = [pin[@"degree"] floatValue] - 90.0f;
    float arrow_angle = degree * M_PI / 180.0f;
    
    CGRect rect = CGRectMake(x-roundSize, y-roundSize, roundSize*2, roundSize*2);
    CGPoint arrowFrom = (CGPoint){x + cos(arrow_angle) * roundSize, y + sin(arrow_angle) * roundSize};
    CGPoint arrowTo = (CGPoint){x + cos(arrow_angle) * arrowLength, y + sin(arrow_angle) * arrowLength};
    NSLog(@"degree - %f, (x,y) =%d,%d arrowFrom=%d,%d arrowTo=%d,%d", degree, (int)x, (int)y, (int)arrowFrom.x, (int)arrowFrom.y, (int)arrowTo.x, (int)arrowTo.y);
    {
        CAShapeLayer *layer = self.shapeMapArrowHead[key];
        [self arrowHead:layer :arrowFrom :arrowTo];
    }
    
    {
        CAShapeLayer *layer = self.shapeMapArrowLine[key];
        UIBezierPath *path = [UIBezierPath new];
        [path moveToPoint:arrowFrom];
        [path addLineToPoint:arrowTo];
        layer.path = path.CGPath;
    }
}

- (void)arrowHead:(CAShapeLayer*)layer :(CGPoint) arrowFrom :(CGPoint) arrowTo {
    UIBezierPath *path = [UIBezierPath new];
    [path moveToPoint:arrowTo];
    
    float from_x = arrowFrom.x;
    float from_y = arrowFrom.y;
    float to_x = arrowTo.x;
    float to_y = arrowTo.y;
    
    float radius = 6; //화살표의 반경(반지름)
    float angle = 60; //화살표 끝이 펼쳐진 각도
    float anglerad = (float) (M_PI*angle/180.0f); //라디안
    float lineangle = (float) (atan2(to_y-from_y,to_x-from_x));
    
    float x1 = (float)(to_x - radius*cos(lineangle - (anglerad / 2.0)));
    float y1 = (float)(to_y - radius*sin(lineangle - (anglerad / 2.0)));
    [path addLineToPoint:(CGPoint){x1,y1}];

    //화살표 중앙 밑날개끝
    float x11 = (float)(to_x - (radius/2.0f)*cos(lineangle));
    float y11 = (float)(to_y - (radius/2.0f)*sin(lineangle));
    [path addLineToPoint:(CGPoint){x11,y11}];

    //화살표 반대쪽날개끝
    float x2 = (float)(to_x - radius*cos(lineangle + (anglerad / 2.0)));
    float y2 = (float)(to_y - radius*sin(lineangle + (anglerad / 2.0)));
    [path addLineToPoint:(CGPoint){x2,y2}];
    
    [path closePath];
    layer.path = path.CGPath;
}

- (void)updateZoom:(float)zoomScale {
    self.zoomScale = zoomScale;
    float z = zoomScale;
    //NSLog(@"updateZoom %f shapes count - %u", z, [self.shapes count]);
    for(CAShapeLayer* layer in self.shapes) {
        layer.transform = CATransform3DMakeScale(1.0f/z, 1.0f/z, 1);
    }
}

- (void)highlight:(NSString*)key {
    self.highlightKey = key;
}

- (void)syncPinWithAnimation:(NSString*)key {
    for(id pin in self.pinList) {
        NSString* mkey = pin[@"key"];
        if([mkey isEqualToString:key]) {
            
            CAShapeLayer *layer = self.shapeMapBody[key];
            CAShapeLayer *layer2 = self.shapeMapArrowLine[key];
            CAShapeLayer *layer3 = self.shapeMapArrowHead[key];
            CAShapeLayer *layer4 = self.shapeMapText[key];
            
            float x = [pin[@"x"] floatValue];
            float y = [pin[@"y"] floatValue];
            
            [CATransaction begin];
            [CATransaction setCompletionBlock:^{
                /**
                 shape에 패스를 새로 넣어줬는데 어딘가 이상한지, 이상한데 화살표가 생긴다
                 그래서 그냥 새로 생성한다
                 */
                [self syncPin];
            }];
            CABasicAnimation* animation = [CABasicAnimation animationWithKeyPath:@"position"];
            animation.cumulative = YES;
            animation.fromValue = [NSValue valueWithCGPoint:layer.position];
            animation.toValue = [NSValue valueWithCGPoint:CGPointMake(x, y)];
            animation.duration = 0.3f;
            
            
            layer.position = CGPointMake(x, y);
            [layer addAnimation:animation forKey:nil];
            
            layer2.position = CGPointMake(x, y);
            [layer2 addAnimation:animation forKey:nil];
            
            layer3.position = CGPointMake(x, y);
            [layer3 addAnimation:animation forKey:nil];
            
            layer4.position = CGPointMake(x, y);
            NSLog(@"to Point %d %d", (int)x, (int)y);
            [layer4 addAnimation:animation forKey:nil];
            [CATransaction commit];
            
            break;
        }
    }
}

- (void)syncPin {

    for(id layer in self.shapes) {
        [layer removeFromSuperlayer];
    }
    self.shapeMapArrowLine = [@{} mutableCopy];
    self.shapeMapArrowHead = [@{} mutableCopy];
    self.shapeMapText = [@{} mutableCopy];
    self.shapeMapBody = [@{} mutableCopy];
    self.shapes = [@[] mutableCopy];
    
    float z = self.zoomScale;
    
    //NSLog(@"syncPin pin lneght = %lu", (unsigned long)[_pinList count]);
    int index = 0;
    
    for(id pin in self.pinList) {
        NSString* color = pin[@"color"];
        NSString* key = pin[@"key"];

        UIColor *c = [WildCardUtil colorWithHexString:color];

        BOOL highlight = [key isEqualToString:self.highlightKey];
        BOOL selected = [pin[@"selected"] boolValue];
        BOOL hideDirection = [pin[@"hideDirection"] boolValue];
        float x = [pin[@"x"] floatValue];
        float y = [pin[@"y"] floatValue];
        NSString* text = pin[@"text"];
        
        float degree = [pin[@"degree"] floatValue] - 90.0f;
        float arrow_angle = degree * M_PI / 180.0f;
        
        CGRect rect = CGRectMake(x-roundSize, y-roundSize, roundSize*2, roundSize*2);
        CGPoint arrowFrom = (CGPoint){x + cos(arrow_angle) * roundSize, y + sin(arrow_angle) * roundSize};
        CGPoint arrowTo = (CGPoint){x + cos(arrow_angle) * arrowLength, y + sin(arrow_angle) * arrowLength};
        
        
        //화살표 머리
        {
            CAShapeLayer *layer = [[CAShapeLayer alloc] init];
            layer.fillColor = c.CGColor;
            layer.strokeColor = c.CGColor;

            layer.borderWidth = 0;
            layer.lineWidth = width;
            layer.bounds = rect;
            
            if(!hideDirection)
                [self arrowHead:layer : arrowFrom : arrowTo];
            
            layer.position = CGPointMake(x, y);
            layer.transform = CATransform3DMakeScale(1.0f/z, 1.0f/z, 1);
            [self.layer insertSublayer:layer atIndex:0];
            
            [self.shapes addObject:layer];
            self.shapeMapArrowHead[key] = layer;
        }
        
        //화살표 몸통
        {
            CAShapeLayer *layer = [[CAShapeLayer alloc] init];
            layer.fillColor = c.CGColor;
            layer.strokeColor = c.CGColor;

            layer.borderWidth = 0;
            layer.lineWidth = width;
            layer.bounds = rect;
            
            if(!hideDirection) {
                UIBezierPath *path = [UIBezierPath new];
                [path moveToPoint:arrowFrom];
                [path addLineToPoint:arrowTo];
                layer.path = path.CGPath;
            }
            
            layer.position = CGPointMake(x, y);
            layer.transform = CATransform3DMakeScale(1.0f/z, 1.0f/z, 1);
            [self.layer insertSublayer:layer atIndex:0];
            
            [self.shapes addObject:layer];
            self.shapeMapArrowLine[key] = layer;
        }
        
        //텍스트
        {
            CATextLayer* layer = [CATextLayer new];
            layer.string = text;
            layer.font = (__bridge CFTypeRef _Nullable)([UIFont boldSystemFontOfSize:textSize]);
            layer.fontSize = textSize;
            layer.frame = rect;
            layer.position = CGPointMake(x, y);
            layer.contentsScale = [UIScreen mainScreen].scale;
            layer.anchorPoint = CGPointMake(0.5, 0.32);
            layer.alignmentMode = kCAAlignmentCenter;
            if(selected || highlight)
                layer.foregroundColor = [UIColor whiteColor].CGColor;
            else
                layer.foregroundColor = c.CGColor;
            layer.transform = CATransform3DMakeScale(1.0f/z, 1.0f/z, 1);

            [self.layer insertSublayer:layer atIndex:0];
            [self.shapes addObject:layer];
            self.shapeMapText[key] = layer;
        }

        //몸통
        {
            CAShapeLayer *layer = [[CAShapeLayer alloc] init];
            if(selected || highlight) {
                layer.fillColor = c.CGColor;
                layer.strokeColor = c.CGColor;
            } else {
                layer.fillColor = [UIColor whiteColor].CGColor;
                layer.strokeColor = c.CGColor;
            }
            

            layer.borderWidth = 0;
            layer.lineWidth = width;
            layer.path = [UIBezierPath bezierPathWithOvalInRect:rect].CGPath;
            layer.bounds = rect;
            layer.position = CGPointMake(x, y);
            layer.transform = CATransform3DMakeScale(1.0f/z, 1.0f/z, 1);
            [self.layer insertSublayer:layer atIndex:0];
            [self.shapes addObject:layer];
            self.shapeMapBody[key] = layer;
        }
        
        index ++;
        
        //NSLog(@"pin %@ %@ %@", pin[@"text"] , color, c);
    }
}

@end
