//
//  JulyUtil.m
//  sticar
//
//  Created by Mu Young Ko on 2019. 6. 28..
//  Copyright © 2019년 trix. All rights reserved.
//

#import "JulyUtil.h"
#import <AFNetworking/AFNetworking.h>

@implementation JulyUtil

+(NSString*)comma:(int)m{
    NSNumberFormatter * formatter = [NSNumberFormatter new];
    [formatter setNumberStyle:NSNumberFormatterDecimalStyle];
    NSString * r =  [formatter stringFromNumber:[NSNumber numberWithInteger:m]];
    return r;
}

+(NSString*)dateFormatSlash:(NSString*)yyyyMMdd{
    NSString* r = nil;
    r = [NSString stringWithFormat:@"%@/%@/%@"
         , [yyyyMMdd substringWithRange:NSMakeRange(0, 4)]
         , [yyyyMMdd substringWithRange:NSMakeRange(4, 2)]
         , [yyyyMMdd substringWithRange:NSMakeRange(6, 2)]
         ];
    
    return r;
}


+(NSString*)dateFormatMMddSlash:(NSString*)yyyyMMdd{
    NSString* r = nil;
    r = [NSString stringWithFormat:@"%@/%@"
         , [yyyyMMdd substringWithRange:NSMakeRange(4, 2)]
         , [yyyyMMdd substringWithRange:NSMakeRange(6, 2)]
         ];
    
    return r;
}

+(id)getFromList:(id)list col:(NSString*)col key:(NSString*)key{
    for(int i=0;list != nil && i<[list count];i++){
        if([list[i][col] isEqualToString:key])
            return list[i];
    }
    return nil;
}

+(int)getIndexFromList:(id)list col:(NSString*)col key:(NSString*)key{
    for(int i=0;list != nil && i<[list count];i++){
        if([list[i][col] isEqualToString:key])
            return i;
    }
    return -1;
}

+(void)request:(NSString*)url postParam:(id _Nullable)params complete:(void (^)(id res))callback{
    
    AFHTTPSessionManager *manager = [AFHTTPSessionManager manager];
    manager.responseSerializer = [AFHTTPResponseSerializer serializer];
    
    id headers = [@{@"Accept": @"application/json"} mutableCopy];
    
    if(params == nil){
        [manager GET:url parameters:@{} headers:headers progress:nil success:^(NSURLSessionTask *task, id res)
        {
            NSMutableDictionary* r = [NSJSONSerialization JSONObjectWithData:res options:NSJSONReadingMutableContainers error:nil];
            callback(r);
        }
             failure:^(NSURLSessionTask *operation, NSError *error)
        {
            callback(nil);
        }];
    } else {
        [manager POST:url parameters:params headers:headers progress:nil success:^(NSURLSessionTask *task, id res)
        {
            NSMutableDictionary* r = [NSJSONSerialization JSONObjectWithData:res options:NSJSONReadingMutableContainers error:nil];
            callback(r);
        }
             failure:^(NSURLSessionTask *operation, NSError *error)
        {
            callback(nil);
        }];
    }
}


+(void)request:(NSString*)url complete:(void (^)(id res))callback{
    
    AFHTTPSessionManager *manager = [AFHTTPSessionManager manager];
    manager.responseSerializer = [AFHTTPResponseSerializer serializer];
    
    [manager GET:url parameters:@{} headers:@{} progress:nil success:^(NSURLSessionTask *task, id res)
    {
        callback(res);
    }
         failure:^(NSURLSessionTask *operation, NSError *error)
    {
        callback(nil);
    }];
}

+(void)share:(UIViewController*)vc text:(NSString*)textToShare{
    UIActivityViewController *activityVC = [[UIActivityViewController alloc] initWithActivityItems:@[textToShare] applicationActivities:nil];
    activityVC.excludedActivityTypes = @[UIActivityTypePrint, UIActivityTypeCopyToPasteboard, UIActivityTypeAssignToContact, UIActivityTypeSaveToCameraRoll]; //Exclude whichever aren't relevant
    [vc presentViewController:activityVC animated:YES completion:nil];
}

@end
