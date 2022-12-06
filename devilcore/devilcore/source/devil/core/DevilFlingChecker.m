//
//  DevilFlingChecker.m
//  devilcore
//
//  Created by Mu Young Ko on 2022/11/16.
//

#import "DevilFlingChecker.h"

@implementation DevilFlingCheckerItem
@end

@interface DevilFlingChecker()
@property (nonatomic, retain) NSMutableArray* list;
@end

@implementation DevilFlingChecker
- (instancetype)init{
    self = [super init];
    self.list = [@[] mutableCopy];
    return self;
}
-(void)addTouchPoint:(CGPoint)p {
    DevilFlingCheckerItem* item = [[DevilFlingCheckerItem alloc] init];
    NSTimeInterval now = [NSDate date].timeIntervalSince1970;
    item.point = p;
    item.time = now;
    int removeIndex = 0;
    for(DevilFlingCheckerItem* c in _list) {
        if(now - c.time >1.0f) {
            removeIndex++;
        }
    }
    for(int i=0;i<removeIndex;i++)
        [_list removeObjectAtIndex:0];
        
    [_list addObject:item];
}

-(int)getFling {
    NSTimeInterval end = ((DevilFlingCheckerItem*)[_list lastObject]).time;
    NSTimeInterval start = ((DevilFlingCheckerItem*)[_list firstObject]).time;
    
    float minx = 10000, maxx = 0;
    float miny = 10000, maxy = 0;
    float directionVertical = 0, directionHorizontal = 0;
    DevilFlingCheckerItem* pre;
    for(DevilFlingCheckerItem* c in _list) {
        if(minx > c.point.x)
            minx = c.point.x;
        if(maxx < c.point.x)
            maxx = c.point.x;
        if(miny > c.point.y)
            miny = c.point.y;
        if(maxy < c.point.y)
            maxy = c.point.y;
        
        if(pre) {
            directionHorizontal += c.point.x - pre.point.x;
            directionVertical += c.point.y - pre.point.y;
        }
        pre = c;
    }
    
    float distanceHorizontal = maxx - minx;
    float distanceVertical = maxy - miny;
    float vHorizontal = distanceHorizontal /(end-start);
    float vVertical = distanceVertical /(end-start);
    
    if(vHorizontal > vVertical) {
        if(vHorizontal > 50) {
            if(directionHorizontal > 0)
                return FLING_RIGHT;
            else
                return FLING_LEFT;
        }
    } else {
        if(vVertical > 50) {
            if(directionVertical > 0)
                return FLING_DOWN;
            else
                return FLING_UP;
        }
    }
    
    return FLING_NONE;
}


@end
