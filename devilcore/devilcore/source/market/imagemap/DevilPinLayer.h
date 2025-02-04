//
//  DevilPinLayer.h
//  devilcore
//
//  Created by Mu Young Ko on 2022/09/08.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

#define ARROW_TYPE_ARROW 0
#define ARROW_TYPE_ROUND 1

#define PIN_FIRST_PIN 0
#define PIN_FIRST_POINT 1

@interface DevilPinLayer : UIView

@property (nonatomic, retain) id pinList;
@property float zoomScale;
@property float minPinSizeScale;

- (void)highlight:(NSString*)key;
- (void)syncPinWithAnimation:(NSString*)key;
- (void)syncPin;
- (void)updateZoom:(float)zoomScale;
- (void)updatePinDirection:(NSString*)key;
+ (CGPoint)getToPointOf:(id)pin;
+ (CGPoint)moveOnLineDistance:(CGPoint)arrowFrom :(CGPoint) arrowTo :(float)distance;
+ (CGPoint)moveOnLineDistanceWithDegree:(CGPoint)arrowFrom :(double) degree :(float)distance;
+ (float)distance:(CGPoint)a : (CGPoint)b;
+ (float)getDegree:(CGPoint)from : (CGPoint)to;
    
@end

NS_ASSUME_NONNULL_END
