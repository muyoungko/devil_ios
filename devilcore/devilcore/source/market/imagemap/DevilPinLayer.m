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
@property (nonatomic, retain) id shapeMapBody;
@property (nonatomic, retain) id shapeMapArrowLine;
@property (nonatomic, retain) id shapeMapArrowHead;
/**
 실제가 아닌 방향을 나타내기 위한 화살표이며, shapeMapArrow와 둘중에 하나만 표시된다
 arrow는 포인트가 가리키는 실제 좌표이다
 fake는 줌아웃되어 포인트가 몸통 안으로 들어갈경우 방향을 표시하기 위한 포인트이다
 arrow는 전체 scaling 되지 않고 width만 scaling된다
 fake는 전체 scaling된다
 (제거)어떤게 보일지는 fakeOrNot 함수에서 결정하고 그 기준은, arrowTo와 arrwFrom의 거리가 scaling된 radius*2보다 적을 경우 fake가 보이게 된다
 위와 같이 하려했으나 통일성을 위해 특정 줌 스케일 이하인 경우로 변경한다
 */
@property (nonatomic, retain) id shapeMapFakeArrowLine;
@property (nonatomic, retain) id shapeMapFakeArrowHead;


/**
 pin포인트 우선에서는 몸통보다 pin포인트가 중요하다 따라서 최소 길이 유지시 몸통이 뒤로 빠져야한다
 */
@property (nonatomic, retain) id shapeMapFakeArrowPointFirstLine;
@property (nonatomic, retain) id shapeMapFakeBody;


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
    
    //NSLog(@"pin pinFirst %d", pin[@"pinFirst"] );
    
    [self.shapeMapBody[key] removeFromSuperlayer];
    [self.shapeMapArrowLine[key] removeFromSuperlayer];
    [self.shapeMapArrowHead[key] removeFromSuperlayer];
    
    [self.shapeMapFakeArrowLine[key] removeFromSuperlayer];
    [self.shapeMapFakeArrowHead[key] removeFromSuperlayer];
    
    [self.shapeMapFakeBody[key] removeFromSuperlayer];
    [self.shapeMapFakeArrowPointFirstLine[key] removeFromSuperlayer];
    
    [self createArrow:pin];
}

- (float)distance:(CGPoint)a : (CGPoint)b {
    return sqrt(pow((a.x - b.x), 2) + pow((a.y - b.y), 2));
}

- (void)arrowHead:(CAShapeLayer*)layer :(CGPoint) arrowFrom :(CGPoint) arrowTo :(int)arrowType{
    UIBezierPath *path = [UIBezierPath new];
    [path moveToPoint:arrowTo];
    
    float from_x = arrowFrom.x;
    float from_y = arrowFrom.y;
    float to_x = arrowTo.x;
    float to_y = arrowTo.y;
    
    if(arrowType == ARROW_TYPE_ROUND) {
        float w = width * 1.5f;
        CGRect rect = CGRectMake(arrowTo.x-w, arrowTo.y-w, w*2, w*2);
        layer.path = [UIBezierPath bezierPathWithOvalInRect:rect].CGPath;
    } else {
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
}

- (void)updateZoom:(float)zoomScale {
    self.zoomScale = zoomScale;
    if(zoomScale > self.minPinSizeScale)
        self.zoomScale = self.minPinSizeScale;
    
    float z = self.zoomScale;
    //NSLog(@"updateZoom %f", z);
    
    for(CAShapeLayer* layer in [self.shapeMapBody allObjects]) {
        layer.transform = CATransform3DMakeScale(1.0f/z, 1.0f/z, 1);
    }
    
    for(CAShapeLayer* layer in [self.shapeMapArrowHead allObjects]) {
        layer.transform = CATransform3DMakeScale(1.0f/z, 1.0f/z, 1);
    }
    
    for(CAShapeLayer* layer in [self.shapeMapArrowLine allObjects]) {
        layer.lineWidth = (float)width / z;
    }
    
    for(CAShapeLayer* layer in [self.shapeMapFakeArrowHead allObjects]) {
        layer.transform = CATransform3DMakeScale(1.0f/z, 1.0f/z, 1);
    }
    
    for(CAShapeLayer* layer in [self.shapeMapFakeArrowLine allObjects]) {
        layer.transform = CATransform3DMakeScale(1.0f/z, 1.0f/z, 1);
    }
    
    for(CAShapeLayer* layer in [self.shapeMapFakeBody allObjects]) {
        layer.transform = CATransform3DMakeScale(1.0f/z, 1.0f/z, 1);
    }
    
    for(CAShapeLayer* layer in [self.shapeMapFakeArrowPointFirstLine allObjects]) {
        layer.transform = CATransform3DMakeScale(1.0f/z, 1.0f/z, 1);
    }
    
    
    
    for(id pin in _pinList) {
        [self fakeOrReal:pin];
    }
}

- (void)fakeOrReal:(id)pin {
    float x = [pin[@"x"] floatValue];
    float y = [pin[@"y"] floatValue];
    float distance = [DevilPinLayer distance:CGPointMake(x, y) : [DevilPinLayer getToPointOf:pin]];
    
    int arrowType = ARROW_TYPE_ARROW;
    if(pin[@"arrowType"])
        arrowType = [pin[@"arrowType"] intValue];
    
    int pinFirst = PIN_FIRST_PIN;
    if(pin[@"pinFirst"])
        pinFirst = [pin[@"pinFirst"] intValue];
    
    NSString* key = pin[@"key"];
    if(distance * self.zoomScale > arrowLength) {
        //real 보여주기
        ((CAShapeLayer*)self.shapeMapBody[key]).hidden = NO;
        ((CAShapeLayer*)self.shapeMapArrowLine[key]).hidden = NO;
        ((CAShapeLayer*)self.shapeMapArrowHead[key]).hidden = NO;
        
        ((CAShapeLayer*)self.shapeMapFakeArrowLine[key]).hidden = YES;
        ((CAShapeLayer*)self.shapeMapFakeArrowHead[key]).hidden = YES;
        
        ((CAShapeLayer*)self.shapeMapFakeBody[key]).hidden = YES;
        ((CAShapeLayer*)self.shapeMapFakeArrowPointFirstLine[key]).hidden = YES;
    } else {
        
        //pin first fake 보여주기
        if(pinFirst == PIN_FIRST_PIN) {
            
            ((CAShapeLayer*)self.shapeMapBody[key]).hidden = NO;
            ((CAShapeLayer*)self.shapeMapArrowLine[key]).hidden = YES;
            ((CAShapeLayer*)self.shapeMapArrowHead[key]).hidden = YES;
            
            ((CAShapeLayer*)self.shapeMapFakeArrowLine[key]).hidden = NO;
            ((CAShapeLayer*)self.shapeMapFakeArrowHead[key]).hidden = NO;
            
            ((CAShapeLayer*)self.shapeMapFakeBody[key]).hidden = YES;
            ((CAShapeLayer*)self.shapeMapFakeArrowPointFirstLine[key]).hidden = YES;
        }
        //point first fake 보여주기
        else if(pinFirst == PIN_FIRST_POINT) {
            
            ((CAShapeLayer*)self.shapeMapBody[key]).hidden = YES;
            ((CAShapeLayer*)self.shapeMapArrowLine[key]).hidden = YES;
            ((CAShapeLayer*)self.shapeMapArrowHead[key]).hidden = NO;
            
            ((CAShapeLayer*)self.shapeMapFakeArrowLine[key]).hidden = YES;
            ((CAShapeLayer*)self.shapeMapFakeArrowHead[key]).hidden = YES;
            
            ((CAShapeLayer*)self.shapeMapFakeBody[key]).hidden = NO;
            ((CAShapeLayer*)self.shapeMapFakeArrowPointFirstLine[key]).hidden = NO;
        }
    }
    
    
//    ((CAShapeLayer*)self.shapeMapBody[key]).hidden = YES;
//    ((CAShapeLayer*)self.shapeMapArrowLine[key]).hidden = YES;
//    ((CAShapeLayer*)self.shapeMapArrowHead[key]).hidden = YES;
//
//    ((CAShapeLayer*)self.shapeMapFakeArrowLine[key]).hidden = YES;
//    ((CAShapeLayer*)self.shapeMapFakeArrowHead[key]).hidden = YES;
//
//    ((CAShapeLayer*)self.shapeMapFakeBody[key]).hidden = YES;
//    ((CAShapeLayer*)self.shapeMapFakeArrowPointFirstLine[key]).hidden = YES;
}

- (void)highlight:(NSString*)key {
    self.highlightKey = key;
}

- (void)syncPinWithAnimation:(NSString*)key {
    for(id pin in self.pinList) {
        NSString* mkey = pin[@"key"];
        if([mkey isEqualToString:key]) {
            
            float x = [pin[@"x"] floatValue];
            float y = [pin[@"y"] floatValue];
            pin[@"degree"] =
                [NSNumber numberWithInt:
                     [DevilPinLayer getDegree:CGPointMake(x,y) :[DevilPinLayer getToPointOf:pin]] + 90
                ];
            
            [CATransaction begin];
            [CATransaction setCompletionBlock:^{
                /**
                 shape에 패스를 새로 넣어줬는데 어딘가 이상한지, 이상한데 화살표가 생긴다
                 그래서 그냥 새로 생성한다
                 */
                [self syncPin];
            }];
            
            CAShapeLayer *layer = self.shapeMapBody[key];
            
            //NSLog(@"to Point %d %d", (int)x, (int)y);
            
            float dx = x - layer.position.x;
            float dy = y - layer.position.y;
            
            [self fakeOrReal:pin];
            
            [self startMoveAnimation:self.shapeMapBody[key] dx:dx dy:dy];
            [self startMoveAnimation:self.shapeMapArrowLine[key] dx:dx dy:dy];
            [self startMoveAnimation:self.shapeMapArrowHead[key] dx:dx dy:dy];
            [self startMoveAnimation:self.shapeMapFakeArrowLine[key] dx:dx dy:dy];
            [self startMoveAnimation:self.shapeMapFakeArrowHead[key] dx:dx dy:dy];
            [self startMoveAnimation:self.shapeMapFakeBody[key] dx:dx dy:dy];
            [self startMoveAnimation:self.shapeMapFakeArrowPointFirstLine[key] dx:dx dy:dy];
            
            [CATransaction commit];
            
            break;
        }
    }
}

- (CABasicAnimation*)startMoveAnimation:(CALayer*)layer dx:(float)dx dy:(float)dy {
    CABasicAnimation* animation = [CABasicAnimation animationWithKeyPath:@"position"];
    animation.cumulative = YES;
    animation.fromValue = [NSValue valueWithCGPoint:layer.position];
    float x = layer.position.x+dx;
    float y = layer.position.y+dy;
    animation.toValue = [NSValue valueWithCGPoint:CGPointMake(x, y)];
    animation.duration = 0.3f;
    
    layer.position = CGPointMake(x, y);
    [layer addAnimation:animation forKey:nil];
    return animation;
}

- (void)createArrow:(id)pin {
    float z = self.zoomScale;
    
    NSString* color = pin[@"color"];
    NSString* key = pin[@"key"];
    
    UIColor *c = [WildCardUtil colorWithHexString:color];
    
    BOOL highlight = [key isEqualToString:self.highlightKey];
    BOOL selected = [pin[@"selected"] boolValue];
    BOOL hideDirection = [pin[@"hideDirection"] boolValue];
    float x = [pin[@"x"] floatValue];
    float y = [pin[@"y"] floatValue];
    NSString* text = pin[@"text"];
    int arrowType = ARROW_TYPE_ARROW;
    if(pin[@"arrowType"])
        arrowType = [pin[@"arrowType"] intValue];
    
    float degree = [pin[@"degree"] floatValue] - 90.0f;
    float arrow_angle = degree * M_PI / 180.0f;
    float flip_arrow_angle = (degree-180.0f) * M_PI / 180.0f;
    
    CGRect rect = CGRectMake(x-roundSize, y-roundSize, roundSize*2, roundSize*2);
    CGPoint arrowTo = [DevilPinLayer getToPointOf:pin];
    CGRect rectTo = CGRectMake(arrowTo.x-roundSize, arrowTo.y-roundSize, roundSize*2, roundSize*2);
    CGPoint arrowFrom = (CGPoint){x + cos(arrow_angle) * roundSize, y + sin(arrow_angle) * roundSize};
    CGPoint fakeArrowTo = (CGPoint){x + cos(arrow_angle) * arrowLength, y + sin(arrow_angle) * arrowLength};
    
    CGPoint fakeXY = (CGPoint){arrowTo.x + cos(flip_arrow_angle) * arrowLength, arrowTo.y + sin(flip_arrow_angle) * arrowLength};
    float fakeX = fakeXY.x;
    float fakeY = fakeXY.y;
    CGPoint fakeArrowFrom = (CGPoint){fakeX + cos(arrow_angle) * roundSize, fakeY + sin(arrow_angle) * roundSize};
    CGRect fakeRect = CGRectMake(fakeX-roundSize, fakeY-roundSize, roundSize*2, roundSize*2);
    CGRect arrowToRect = CGRectMake(arrowTo.x-roundSize, arrowTo.y-roundSize, roundSize*2, roundSize*2);
    
    /**
     shape 의 확대축소
     확대 축소시 bounds를 중심으로 position의 위치가 축소 시 멀어졌다가 확대 시 가까워진다
     */
    
    //페이크 화살표 머리 - PIN FIRST
    {
        CAShapeLayer *layer = [[CAShapeLayer alloc] init];
        layer.fillColor = c.CGColor;
        layer.strokeColor = c.CGColor;
        
        layer.borderWidth = 0;
        layer.lineWidth = width;
        layer.bounds = rect;
        
        if(!hideDirection)
            [self arrowHead:layer : arrowFrom : fakeArrowTo: arrowType];
        
        layer.position = CGPointMake(x, y);
        layer.transform = CATransform3DMakeScale(1.0f/z, 1.0f/z, 1);
        [self.layer insertSublayer:layer atIndex:0];
        
        [self.shapes addObject:layer];
        self.shapeMapFakeArrowHead[key] = layer;
    }
    
    //페이크 화살표 몸통 - PIN FIRST
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
            [path addLineToPoint:fakeArrowTo];
            layer.path = path.CGPath;
        }
        
        layer.position = CGPointMake(x, y);
        layer.transform = CATransform3DMakeScale(1.0f/z, 1.0f/z, 1);
        [self.layer insertSublayer:layer atIndex:0];
        
        [self.shapes addObject:layer];
        self.shapeMapFakeArrowLine[key] = layer;
    }
    
    
    //페이크 화살표 몸통 - POINT FIRST
    {
        CAShapeLayer *layer = [[CAShapeLayer alloc] init];
        layer.fillColor = c.CGColor;
        layer.strokeColor = c.CGColor;
        
        layer.borderWidth = 0;
        layer.lineWidth = width;
        layer.bounds = arrowToRect;
        
        if(!hideDirection) {
            UIBezierPath *path = [UIBezierPath new];
            [path moveToPoint:arrowTo];
            [path addLineToPoint:fakeArrowFrom];
            layer.path = path.CGPath;
        }
        
        layer.position = CGPointMake(arrowTo.x, arrowTo.y);
        layer.transform = CATransform3DMakeScale(1.0f/z, 1.0f/z, 1);
        [self.layer insertSublayer:layer atIndex:0];
        
        [self.shapes addObject:layer];
        self.shapeMapFakeArrowPointFirstLine[key] = layer;
    }
    
    //몸통(FAKE)
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
        layer.path = [UIBezierPath bezierPathWithOvalInRect:fakeRect].CGPath;
        layer.bounds = arrowToRect;
        layer.position = CGPointMake(arrowTo.x, arrowTo.y);
        layer.transform = CATransform3DMakeScale(1.0f/z, 1.0f/z, 1);
        layer.masksToBounds = NO;
        [self.layer insertSublayer:layer atIndex:0];
        [self.shapes addObject:layer];
        self.shapeMapFakeBody[key] = layer;
        
        {
            CATextLayer* layer = [CATextLayer new];
            layer.string = text;
            layer.font = (__bridge CFTypeRef _Nullable)([UIFont boldSystemFontOfSize:textSize]);
            layer.fontSize = textSize;
            layer.frame = arrowToRect;
            layer.position = fakeXY;
            layer.contentsScale = [UIScreen mainScreen].scale;
            layer.anchorPoint = CGPointMake(0.5, 0.32);
            layer.alignmentMode = kCAAlignmentCenter;
            if(selected || highlight)
                layer.foregroundColor = [UIColor whiteColor].CGColor;
            else
                layer.foregroundColor = c.CGColor;
            layer.transform = CATransform3DMakeScale(1, 1, 1);
            
            [self.shapeMapFakeBody[key] addSublayer:layer];
        }
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
//            layer.transform = CATransform3DMakeScale(1.0f/z, 1.0f/z, 1);
            
            [self.shapeMapBody[key] insertSublayer:layer atIndex:0];
        }
    }
    
    //화살표 머리
    {
        CAShapeLayer *layer = [[CAShapeLayer alloc] init];
        layer.fillColor = c.CGColor;
        layer.strokeColor = c.CGColor;
        layer.borderWidth = 0;
        layer.lineWidth = width;
        layer.bounds = rectTo;
        
        if(!hideDirection)
            [self arrowHead:layer : arrowFrom: arrowTo:arrowType];
        
        layer.position = CGPointMake(arrowTo.x, arrowTo.y);
        
        layer.transform = CATransform3DMakeScale(1.0f/z, 1.0f/z, 1);
        [self.layer insertSublayer:layer atIndex:0];
        
        [self.shapes addObject:layer];
        self.shapeMapArrowHead[key] = layer;
    }
    
    //화살표 라인
    {
        CAShapeLayer *layer = [[CAShapeLayer alloc] init];
        layer.fillColor = c.CGColor;
        layer.strokeColor = c.CGColor;
        
        layer.borderWidth = 0;
        layer.lineWidth = (float)width / z;
        layer.bounds = rect;
        
        if(!hideDirection) {
            UIBezierPath *path = [UIBezierPath new];
            [path moveToPoint:arrowFrom];
            [path addLineToPoint:arrowTo];
            layer.path = path.CGPath;
        }
        
        layer.position = CGPointMake(x, y);
        //layer.transform = CATransform3DMakeScale(1.0f/z, 1.0f/z, 1);
        [self.layer insertSublayer:layer atIndex:0];
        
        [self.shapes addObject:layer];
        self.shapeMapArrowLine[key] = layer;
    }
    
    
    [self fakeOrReal:pin];
}

- (void)syncPin {
    
    for(id layer in self.shapes) {
        [layer removeFromSuperlayer];
    }
    self.shapeMapArrowLine = [@{} mutableCopy];
    self.shapeMapArrowHead = [@{} mutableCopy];
    self.shapeMapFakeArrowLine = [@{} mutableCopy];
    self.shapeMapFakeArrowHead = [@{} mutableCopy];
    self.shapeMapBody = [@{} mutableCopy];
    self.shapes = [@[] mutableCopy];
    
    self.shapeMapFakeBody = [@{} mutableCopy];
    self.shapeMapFakeArrowPointFirstLine = [@{} mutableCopy];
    
    float z = self.zoomScale;
    
    //NSLog(@"syncPin pin lneght = %lu", (unsigned long)[_pinList count]);
    int index = 0;
    
    for(id pin in self.pinList) {
        [self createArrow:pin];
        index ++;
        //NSLog(@"pin %@ %@ %@", pin[@"text"] , color, c);
    }
}

+ (CGPoint)getToPointOf:(id)pin {
    
    if(pin[@"toX"] && pin[@"toY"]) {
        float toX = [pin[@"toX"] floatValue];
        float toY = [pin[@"toY"] floatValue];
        CGPoint r = CGPointMake(toX, toY);
        return r;
    } else {
        
        float degree = [pin[@"degree"] floatValue] - 90.0f;
        float arrow_angle = degree * M_PI / 180.0f;
        float x =[pin[@"x"] floatValue];
        float y =[pin[@"y"] floatValue];
        CGPoint r = (CGPoint){x + cos(arrow_angle) * arrowLength, y + sin(arrow_angle) * arrowLength};
        return r;
    }
}
+ (CGPoint)moveOnLineDistance:(CGPoint)arrowFrom :(CGPoint) arrowTo :(float)distance {
    double angle = atan2(arrowTo.y - arrowFrom.y, arrowTo.x - arrowFrom.x);
    CGPoint r = (CGPoint){arrowFrom.x + cos(angle) * distance, arrowFrom.y + sin(angle) * distance};
    return r;
}

+ (CGPoint)moveOnLineDistanceWithDegree:(CGPoint)arrowFrom :(double) degree :(float)distance {
    float angle = degree * M_PI / 180.0f;
    CGPoint r = (CGPoint){arrowFrom.x + cos(angle) * distance, arrowFrom.y + sin(angle) * distance};
    return r;
}

+ (float)distance:(CGPoint)a : (CGPoint)b {
    return sqrt(pow((a.x - b.x), 2) + pow((a.y - b.y), 2));
}

+ (float)getDegree:(CGPoint)from : (CGPoint)to {
    double r = atan2(to.y - from.y, to.x - from.x);
    double degree = r * 180 / M_PI;
    return degree;
}

@end
