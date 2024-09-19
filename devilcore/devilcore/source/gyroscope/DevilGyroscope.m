//
//  DevilGyroscope.m
//  devilcore
//
//  Created by Mu Young Ko on 2024/09/12.
//

#import "DevilGyroscope.h"
#import "ZipUtil.h"
#import "DevilExceptionHandler.h"
@import CoreMotion;


@implementation DevilGyroscopeValue
+(DevilGyroscopeValue*)new:(NSTimeInterval)t :(float)x :(float)y :(float)z {
    DevilGyroscopeValue* r = [[DevilGyroscopeValue alloc] init];
    r.t = t;
    r.x = x;
    r.y = y;
    r.z = z;
    return r;
}
@end

@interface DevilGyroscope ()

@property void (^callback)(id res);
@property (nonatomic, retain) id param;
@property (nonatomic, retain) CMMotionManager *motionManager;
@property (nonatomic, retain) NSMutableArray* cachedList;
@property int interval;
@property double last;
@end

@implementation DevilGyroscope

+ (DevilGyroscope*)sharedInstance {
    static DevilGyroscope *sharedInstance = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        sharedInstance = [[self alloc] init];
        sharedInstance.cachedList = [@[] mutableCopy];
    });
    return sharedInstance;
}

-(void)startGyroscope:(id)param callback:(void (^)(id res))callback{
    if(self.motionManager == nil)
        self.motionManager = [[CMMotionManager alloc] init];
    if ([self.motionManager isGyroAvailable]) {
        self.motionManager.gyroUpdateInterval = 0.1;

        [_cachedList removeAllObjects];
        
        if ([param objectForKey:@"delay"] != nil) {
            NSString *delay = param[@"delay"];
            if ([delay isEqualToString:@"fast"]) {
                self.motionManager.gyroUpdateInterval = 0.01;
            }
        }
        
        self.interval = 1000;
        if ([param objectForKey:@"interval"] != nil) {
            self.interval = [param[@"interval"] intValue];
        }

        
        // 자이로스코프 업데이트 시작
        [self.motionManager startGyroUpdatesToQueue:[NSOperationQueue mainQueue]
                                        withHandler:^(CMGyroData *gyroData, NSError *error) {
            if (error) {
                NSLog(@"자이로스코프 업데이트 중 오류 발생: %@", error);
            } else {
                // 자이로스코프 데이터를 가져옴
                unsigned long long t = gyroData.timestamp * 1000000000;
                NSLog(@"%llu X: %.2f, Y: %.2f, Z: %.2f", t, gyroData.rotationRate.x, gyroData.rotationRate.y, gyroData.rotationRate.z);
                __block DevilGyroscopeValue* d = [DevilGyroscopeValue new:gyroData.timestamp
                                                                   :gyroData.rotationRate.x
                                                                   :gyroData.rotationRate.y
                                                                         :gyroData.rotationRate.z];
                [self.cachedList addObject:d];
                
                double now = (double)[NSDate date].timeIntervalSince1970;
                if((now - self.last)* 1000 > self.interval) {
                    self.last = now;
                    
                    dispatch_async(dispatch_get_main_queue(), ^{
                        @try {
                            callback(@{
                                @"r":@TRUE,
                                @"event":@"collect",
                                @"t": [NSString stringWithFormat:@"%llu", t],
                                @"x": @(d.x),
                                @"y": @(d.y),
                                @"z": @(d.z)
                            });
                        }@catch(NSException*e){
                            [DevilExceptionHandler handle:e];
                        }
                    });
                }
            }
        }];
        
        callback(@{
            @"r":@TRUE,
            @"event":@"start",
        });
    } else {
        NSLog(@"자이로스코프를 사용할 수 없습니다.");
    }
}
-(void)stopGyroscope{
    if (self.motionManager != nil && [self.motionManager isGyroActive]) {;
        self.motionManager.gyroUpdateInterval = 100;
        dispatch_async(dispatch_get_main_queue(), ^{
            [self.motionManager stopGyroUpdates];
            self.motionManager = nil; // 필요시 해제
        });
    }
}

-(NSArray*)getData:(id)param {
    id r = [@[] mutableCopy];
    
    long last_ms = 10000;
    if(param[@"last_ms"])
        last_ms = [param[@"last_ms"] intValue];
    long sample = 100;
    if(param[@"sample"])
        sample = [param[@"sample"] intValue];
    
    // cachedList에서 마지막 값의 t 값 가져오기
    CMGyroData *g = [self.cachedList lastObject];
    NSTimeInterval start = g.timestamp;
    int end_index = 0;

    // 리스트를 역순으로 순회하며 end_index 찾기
    for (int i = (int)[self.cachedList count] - 1; i >= 0; i--) {
        CMGyroData *m = self.cachedList[i];
        if ((start - m.timestamp) * 1000 > last_ms) {
            end_index = (int)i;
            break;
        }
    }

    long range_count = [self.cachedList count] - end_index;

    for (int i = 0; i < sample; i++) {
        int index = (int)(end_index + range_count / sample * i);
        if (index < [self.cachedList count]) {
            CMGyroData *m = self.cachedList[index];
            unsigned long long t = m.timestamp * 1000000000;
            NSDictionary *jsonObject = @{
                @"t": [NSString stringWithFormat:@"%llu", t],
                @"x": @(m.rotationRate.x),
                @"y": @(m.rotationRate.y),
                @"z": @(m.rotationRate.z)
            };
            [r addObject:jsonObject];
        }
    }

    return r;
}

-(void)getZipData:(id)param callback:(void (^)(id res))callback{
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_HIGH, 0), ^{
        
        int len = (int)self.cachedList.count;
        NSUInteger bufferSize = len * (sizeof(double) + sizeof(float) * 3);
        NSMutableData *byteBuffer = [NSMutableData dataWithLength:0];
        
        __block NSMutableDictionary *res = [NSMutableDictionary dictionary];
        for (int i=0;i<len;i++) {
            DevilGyroscopeValue *m = [self.cachedList objectAtIndex:i];
            long t = m.t;
            float x = m.x;
            float y = m.y;
            float z = m.z;
            
            [byteBuffer appendBytes:&t length:sizeof(t)];
            [byteBuffer appendBytes:&x length:sizeof(x)];
            [byteBuffer appendBytes:&y length:sizeof(y)];
            [byteBuffer appendBytes:&z length:sizeof(z)];
        }
        
        NSData* compressedData = [ZipUtil compress:byteBuffer];
        res[@"r"] = @(YES);
        res[@"compress_byte_len"] = @([compressedData length]);
        NSString* base64 = [compressedData base64EncodedStringWithOptions:0];
        
        res[@"event"] = @"zip";
        res[@"value"] = base64;
        
        // 첫 번째 값 추가
        DevilGyroscopeValue *first = self.cachedList[0];
        unsigned long long t = first.t * 1000000000;
        res[@"first"] = @{
            @"t": [NSString stringWithFormat:@"%llu", t],
            @"x": @(first.x),
            @"y": @(first.y),
            @"z": @(first.z)
        };
        res[@"byte_len"] = @(bufferSize);
        res[@"len"] = @(len);
        
        dispatch_async(dispatch_get_main_queue(), ^{
            @try {
                callback(res);
            }@catch(NSException*e){
                [DevilExceptionHandler handle:e];
            }
        });
    });
}

@end
