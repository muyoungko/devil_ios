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
        [HKQuantityType quantityTypeForIdentifier:HKQuantityTypeIdentifierDistanceWalkingRunning],
        [HKQuantityType quantityTypeForIdentifier:HKQuantityTypeIdentifierBodyMassIndex],
        [HKQuantityType quantityTypeForIdentifier:HKQuantityTypeIdentifierBodyFatPercentage],
        [HKQuantityType quantityTypeForIdentifier:HKQuantityTypeIdentifierOxygenSaturation],
        [HKQuantityType quantityTypeForIdentifier:HKQuantityTypeIdentifierBloodPressureSystolic],
        [HKQuantityType quantityTypeForIdentifier:HKQuantityTypeIdentifierBloodPressureDiastolic],
        [HKCategoryType categoryTypeForIdentifier:HKCategoryTypeIdentifierSleepAnalysis],
        [HKCategoryType categoryTypeForIdentifier:HKCategoryTypeIdentifierSleepChanges],
        
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
    [list addObject:@{
        @"type":HKQuantityTypeIdentifierDistanceWalkingRunning,
    }];
    [list addObject:@{
        @"type":HKQuantityTypeIdentifierBodyMassIndex,
    }];
    [list addObject:@{
        @"type":HKQuantityTypeIdentifierBodyFatPercentage,
    }];
    [list addObject:@{
        @"type":HKQuantityTypeIdentifierOxygenSaturation,
    }];
    [list addObject:@{
        @"type":HKQuantityTypeIdentifierBloodPressureSystolic,
    }];
    [list addObject:@{
        @"type":HKQuantityTypeIdentifierBloodPressureDiastolic,
    }];
    [list addObject:@{
        @"type":HKCategoryTypeIdentifierSleepAnalysis,
    }];
//    [list addObject:@{
//        @"type":HKCategoryTypeIdentifierSleepChanges,
//    }];
    
    int count = (int)[list count];
    __block int success_count = 0;
    __block id r = [@{@"r":@TRUE} mutableCopy];
    r[@"list"] = [@[] mutableCopy];
    for(id m in list) {
        [self requestHealthDataForType:param
                                typeIdentifier:m[@"type"]
                                callback:^(id res) {
            success_count++;
            [r[@"list"] addObject:
             [@{
                @"type" : m[@"type"],
                @"data" : res[@"list"],
                @"unit" : res[@"unit"],
             } mutableCopy]
            ];
            if(success_count == count) {
                for(id a in r[@"list"]) {
                    NSLog(@"%@ count - %d", a[@"type"], (int)[a[@"data"] count]);
                }
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
    NSPredicate *predicate = [HKQuery predicateForSamplesWithStartDate:fromDate endDate:toDate options:HKQueryOptionStrictStartDate];
    
    if(typeIdentifier == HKCategoryTypeIdentifierSleepAnalysis || typeIdentifier == HKCategoryTypeIdentifierSleepChanges) {
        HKObjectType* type = [HKObjectType categoryTypeForIdentifier:typeIdentifier];
        HKSampleQuery* query = [[HKSampleQuery alloc] initWithSampleType:type predicate:predicate limit:10000 sortDescriptors:nil resultsHandler:^(HKSampleQuery * _Nonnull query, NSArray<__kindof HKSample *> * _Nullable results, NSError * _Nullable error) {
            
            NSDateFormatter *df2 = [[NSDateFormatter alloc]init];
            [df2 setDateFormat:@"yyyyMMddHHmmss"];
            id list = [@[] mutableCopy];
            
            for(HKCategorySample* m in results) {
                NSInteger value = m.value;
                NSString* s = [df2 stringFromDate:m.startDate];
                NSString* e = [df2 stringFromDate:m.endDate];
                NSString* sv = @"";
                if(value == HKCategoryValueSleepAnalysisInBed) {
                    sv = @"inbed";
                } else if(value == HKCategoryValueSleepAnalysisAsleep) {
                    sv = @"sleep";
                } else if(value == HKCategoryValueSleepAnalysisAwake) {
                    sv = @"awake";
                }

                [list addObject:
                     [@{
                        @"s":s,
                        @"e":e,
                        @"v":sv,
                      } mutableCopy]
                ];
            }
            
            id r = [@{@"r":@TRUE} mutableCopy];
            r[@"list"] = list;
            r[@"unit"] = @"category";
            dispatch_async(dispatch_get_main_queue(), ^{
                callback(r);
            });
        }];
        [self.healthStore executeQuery:query];
    } else {
        HKQuantityType *type = [HKObjectType quantityTypeForIdentifier:typeIdentifier];
        HKStatisticsOptions option = HKStatisticsOptionCumulativeSum;
        if(typeIdentifier == HKQuantityTypeIdentifierHeartRate)
            option = HKStatisticsOptionDiscreteAverage;
        else if(typeIdentifier == HKQuantityTypeIdentifierBodyMassIndex)
            option = HKStatisticsOptionDiscreteAverage;
        else if(typeIdentifier == HKQuantityTypeIdentifierBodyFatPercentage)
            option = HKStatisticsOptionDiscreteAverage;
        else if(typeIdentifier == HKQuantityTypeIdentifierOxygenSaturation)
            option = HKStatisticsOptionDiscreteAverage;
        else if(typeIdentifier == HKQuantityTypeIdentifierBloodPressureSystolic)
            option = HKStatisticsOptionDiscreteAverage;
        else if(typeIdentifier == HKQuantityTypeIdentifierBloodPressureDiastolic)
            option = HKStatisticsOptionDiscreteAverage;
        
        // Your interval: sum by hour
        NSDateComponents *intervalComponents = [[NSDateComponents alloc] init];
        intervalComponents.minute = 10;

        HKStatisticsCollectionQuery *query = [[HKStatisticsCollectionQuery alloc] initWithQuantityType:type quantitySamplePredicate:predicate options:option anchorDate:fromDate intervalComponents:intervalComponents];
            query.initialResultsHandler = ^(HKStatisticsCollectionQuery *query, HKStatisticsCollection *result, NSError *error) {
                
                NSDateFormatter *df2 = [[NSDateFormatter alloc]init];
                [df2 setDateFormat:@"yyyyMMddHHmmss"];
                id list = [@[] mutableCopy];
                id slist = [result statistics];
                NSString* unit = @"";
                BOOL first = true;
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
                    
                    if(first) {
                        NSLog(@"%@ %@ ~ %@, %@", typeIdentifier, s, e, q);
                        first = NO;
                    }

                    [list addObject:
                         [@{
                            @"s":s,
                            @"e":e,
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
    
    
}
@end
