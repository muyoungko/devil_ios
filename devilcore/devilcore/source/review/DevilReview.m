//
//  DevilReview.m
//  devilcore
//
//  Created by Mu Young Ko on 2023/11/08.
//

#import "DevilReview.h"
#import "Jevil.h"
@import StoreKit;

@interface DevilReview ()

@end


@implementation DevilReview

+(DevilReview*)sharedInstance {
    static DevilReview *sharedInstance = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        sharedInstance = [[self alloc] init];
    });
    return sharedInstance;
}

#define REVIEW_DATE_MAP @"REVIEW_DATE_MAP"
#define REVIEW_SHOWED @"REVIEW_SHOWED"

-(BOOL)reviewShouldShow {
    
    if([Jevil get:REVIEW_SHOWED])
        return NO;
    
    NSString* s = [Jevil get:REVIEW_DATE_MAP];
    if(!s)
        s = @"{}";
    
    NSData *jsonData = [s dataUsingEncoding:NSUTF8StringEncoding];
    NSError *e;
    id json = [NSJSONSerialization JSONObjectWithData:jsonData options:NSJSONReadingMutableContainers error:&e];
    
    NSDateFormatter *df = [[NSDateFormatter alloc]init];
    [df setDateFormat:@"yyyyMMdd"];
    NSString* today = [df stringFromDate:[NSDate date]];
    json[today] = @"Y";
    
    NSData * dd = [NSJSONSerialization  dataWithJSONObject:json options:0 error:&e];
    NSString * myString = [[NSString alloc] initWithData:dd   encoding:NSUTF8StringEncoding];
    [Jevil save:REVIEW_DATE_MAP :myString];
    
    id ks = [json allKeys];
    if([ks count] >= 5) {
        [Jevil save:REVIEW_SHOWED :@"Y"];
        return YES;
    }
    
    return NO;
}

-(BOOL)review:(BOOL)force {
    if([self reviewShouldShow] || force)
        [SKStoreReviewController requestReview];
    
    return YES;
}

@end
