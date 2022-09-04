//
//  DevilHealth.m
//  template1
//
//  Created by Mu Young Ko on 2022/09/02.
//  Copyright © 2022 july. All rights reserved.
//

#import "DevilHealth.h"

@interface DevilHealth ()

@end

@implementation DevilHealth

+ (DevilHealth*)sharedInstance {
    static DevilHealth *sharedInstance = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        sharedInstance = [[self alloc] init];
        sharedInstance.healthStore = [[HKHealthStore alloc] init];
    });
    
    
    [HKHealthStore isHealthDataAvailable];
    
    return sharedInstance;
}

-(NSDate *)beginningOfDay:(NSDate *)date
{
    NSCalendar *cal = [NSCalendar currentCalendar];
    NSDateComponents *components = [cal components:( NSMonthCalendarUnit | NSYearCalendarUnit | NSHourCalendarUnit | NSMinuteCalendarUnit | NSSecondCalendarUnit ) fromDate:date];
    
    [components setHour:0];
    [components setMinute:0];
    [components setSecond:0];
    
    return [cal dateFromComponents:components];
}

-(NSDate *)endOfDay:(NSDate *)date
{
    NSCalendar *cal = [NSCalendar currentCalendar];
    NSDateComponents *components = [cal components:(  NSMonthCalendarUnit | NSYearCalendarUnit | NSHourCalendarUnit | NSMinuteCalendarUnit | NSSecondCalendarUnit ) fromDate:date];
    
    [components setHour:23];
    [components setMinute:59];
    [components setSecond:59];
    
    return [cal dateFromComponents:components];

}


-(void)requestPermission:(id)param callback:(void (^)(id res))callback{
    NSSet <HKQuantityType *> * dataTypes = [NSSet setWithArray:@[
        [HKQuantityType quantityTypeForIdentifier:HKQuantityTypeIdentifierHeartRate],
        [HKQuantityType quantityTypeForIdentifier:HKQuantityTypeIdentifierStepCount],
        [HKQuantityType quantityTypeForIdentifier:HKQuantityTypeIdentifierBodyTemperature],
    ]];
    [self.healthStore requestAuthorizationToShareTypes:nil readTypes:dataTypes completion:^(BOOL success, NSError * _Nullable error) {
        dispatch_async(dispatch_get_main_queue(), ^{
            if (success)
                callback([@{@"r":@TRUE} mutableCopy]);
            else
                callback([@{@"r":@FALSE} mutableCopy]);
        });
        
    }];
}

-(void)requestHealthData:(id)param callback:(void (^)(id res))callback{
    
    id list = [@[] mutableCopy];
    [list addObject:@{
        @"type":HKQuantityTypeIdentifierHeartRate,
    }];
     
    [list addObject:@{
        @"type":HKQuantityTypeIdentifierStepCount,
    }];
    
    int count = (int)[list count];
    __block int success_count = 0;
    for(id m in list) {
        [self requestHealthDataForType:param
                                typeIdentifier:m[@"type"]
                                callback:^(id res) {
            success_count++;
            id r = [@{@"r":@TRUE} mutableCopy];
            r[@"list"] = [@[] mutableCopy];
            if(success_count == count) {
                [r[@"list"] addObject:
                 [@{
                    @"type" : m[@"type"],
                    @"data" : res[@"list"],
                    @"unit" : res[@"unit"],
                 } mutableCopy]
                ];
                callback(r);
            }
        }];
    }
}

-(void)requestHealthDataForType:(id)param typeIdentifier:(HKQuantityTypeIdentifier)typeIdentifier callback:(void (^)(id res))callback{
    NSDateFormatter *df = [[NSDateFormatter alloc]init];
    [df setDateFormat:@"yyyyMMdd"];
    
    NSString* from = param[@"from"];
    if(!from) {
        NSDate *ago = [[NSDate date] addTimeInterval:-60L*60L*24L*10L];
        from = [df stringFromDate:ago];
    }
    
    NSString* to = param[@"to"];
    if(!to) {
        to = [df stringFromDate:[NSDate date]];
    }
    
    NSDate *fromDate = [df dateFromString:from];
    NSDate *toDate = [NSDate date];
        
    HKQuantityType *type = [HKObjectType quantityTypeForIdentifier:typeIdentifier];
    HKStatisticsOptions option = HKStatisticsOptionCumulativeSum;
    if(typeIdentifier == HKQuantityTypeIdentifierHeartRate)
        option = HKStatisticsOptionDiscreteAverage;
    
    // Your interval: sum by hour
    NSDateComponents *intervalComponents = [[NSDateComponents alloc] init];
    intervalComponents.minute = 10;

    NSPredicate *predicate = [HKQuery predicateForSamplesWithStartDate:fromDate endDate:toDate options:HKQueryOptionStrictStartDate];
    HKStatisticsCollectionQuery *query = [[HKStatisticsCollectionQuery alloc] initWithQuantityType:type quantitySamplePredicate:predicate options:option anchorDate:fromDate intervalComponents:intervalComponents];
        query.initialResultsHandler = ^(HKStatisticsCollectionQuery *query, HKStatisticsCollection *result, NSError *error) {
            
            NSDateFormatter *df2 = [[NSDateFormatter alloc]init];
            [df2 setDateFormat:@"yyyyMMddHHmmss"];
            id list = [@[] mutableCopy];
            id slist = [result statistics];
            NSString* unit = @"";
            for(HKStatistics* m in slist) {
                HKQuantity* q;
                if(m.averageQuantity)
                    q = m.averageQuantity;
                if(m.sumQuantity)
                    q = m.sumQuantity;
                
                NSString* s = [df2 stringFromDate:m.startDate];
                NSString* e = [df2 stringFromDate:m.endDate];
                NSString* sq = [NSString stringWithFormat:@"%@", q];
                id ss = [sq componentsSeparatedByString:@" "];
                NSString* sv = ss[0];
                unit = ss[1];
                double v = [sv doubleValue];
                NSLog(@"%@ ~ %@, %@", s, e, q);

                [list addObject:
                     [@{
                        @"s":s,
                        @"e":e,
                        @"q":e,
                        @"v":[NSNumber numberWithDouble:v],
                      } mutableCopy]
                ];
            }
        
            id r = [@{@"r":@TRUE} mutableCopy];
            r[@"list"] = list;
            r[@"unit"] = unit;
            dispatch_async(dispatch_get_main_queue(), ^{
                callback(r);
            });
    };
    
    [self.healthStore executeQuery:query];
}
@end
