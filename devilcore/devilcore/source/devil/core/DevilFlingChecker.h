//
//  DevilFlingChecker.h
//  devilcore
//
//  Created by Mu Young Ko on 2022/11/16.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

#define FLING_NONE 0
#define FLING_UP 1
#define FLING_DOWN 2
#define FLING_RIGHT 3
#define FLING_LEFT 4

@interface DevilFlingCheckerItem : NSObject
@property CGPoint point;
@property NSTimeInterval time;
@end


@interface DevilFlingChecker : NSObject

-(void)addTouchPoint:(CGPoint)p;
-(int)getFling;

@end

NS_ASSUME_NONNULL_END
