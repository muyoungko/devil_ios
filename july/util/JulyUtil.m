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
        [manager.requestSerializer setTimeoutInterval:10.0];
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
        [manager.requestSerializer setTimeoutInterval:10.0];
        [manager POST:url parameters:params headers:headers progress:nil success:^(NSURLSessionTask *task, id res)
        {
            NSMutableDictionary* r = [NSJSONSerialization JSONObjectWithData:res options:NSJSONReadingMutableContainers error:nil];
            callback(r);
        }
             failure:^(NSURLSessionTask *operation, NSError *error)
        {
            callback(error);
        }];
    }
}

+(void)request:(NSString*)url header:(id _Nullable)header postParam:(id _Nullable)params complete:(void (^)(id res))callback{
    AFHTTPSessionManager *manager = [AFHTTPSessionManager manager];
    
    BOOL form = YES;
    id mheader = [header mutableCopy];
    if(header[@"content-type"] && [@"application/x-www-form-urlencoded" isEqualToString:header[@"content-type"]]) {
        manager.requestSerializer = [AFHTTPRequestSerializer serializer];
        manager.responseSerializer = [AFHTTPResponseSerializer serializer];
        [manager.requestSerializer setValue:@"application/x-www-form-urlencoded; charset=UTF-8" forHTTPHeaderField:@"Content-Type"];
        form = YES;
    } else {
        manager.requestSerializer = [AFJSONRequestSerializer serializer];
        manager.responseSerializer = [AFHTTPResponseSerializer serializer];
        mheader[@"Accept"] = @"application/json";
        mheader[@"Content-Type"] = @"application/json";
        
        form = NO;
    }

    __block BOOL fform = form;
    [manager.requestSerializer setTimeoutInterval:10.0];
    [manager POST:url parameters:params headers:mheader progress:nil success:^(NSURLSessionTask *task, id res)
    {
        if(fform) {
            callback([[NSString alloc] initWithData:res encoding:NSUTF8StringEncoding]);
        } else {
            NSMutableDictionary* r = [NSJSONSerialization JSONObjectWithData:res options:NSJSONReadingMutableContainers error:nil];
            callback(r);
        }
    }
         failure:^(NSURLSessionTask *operation, NSError *error)
    {
        callback(error);
    }];
}

+(void)request:(NSString*)url header:(id _Nullable)header complete:(void (^)(id res))callback{
    AFHTTPSessionManager *manager = [AFHTTPSessionManager manager];
    manager.responseSerializer = [AFHTTPResponseSerializer serializer];
    
    id headers = [@{@"Accept": @"application/json"} mutableCopy];
    NSString* token = [[NSUserDefaults standardUserDefaults] objectForKey:@"token"];
    if(token)
        headers[@"x-access-token"] = token;
    for(id k in [header allKeys])
        headers[k] = header[k];
    
    [manager.requestSerializer setTimeoutInterval:10.0];
    [manager GET:url parameters:@{} headers:headers progress:nil success:^(NSURLSessionTask *task, id res)
    {
        NSMutableDictionary* r = [NSJSONSerialization JSONObjectWithData:res options:NSJSONReadingMutableContainers error:nil];
        callback(r);
    }
         failure:^(NSURLSessionTask *operation, NSError *error)
    {
        callback(error);
    }];
}


+(void)request:(NSString*)url header:(id _Nullable)header putParam:(id _Nullable)params complete:(void (^)(id res))callback{
    AFHTTPSessionManager *manager = [AFHTTPSessionManager manager];
    manager.requestSerializer = [AFJSONRequestSerializer serializer];
    manager.responseSerializer = [AFHTTPResponseSerializer serializer];
    
    id headers = [@{@"Accept": @"application/json",
        @"Content-Type": @"application/json",
    } mutableCopy];
    for(id k in [header allKeys]){
        headers[k] = header[k];
    }
    [manager PUT:url parameters:params headers:headers success:^(NSURLSessionDataTask * _Nonnull task, id  _Nullable res) {
        NSMutableDictionary* r = [NSJSONSerialization JSONObjectWithData:res options:NSJSONReadingMutableContainers error:nil];
        callback(r);
    } failure:^(NSURLSessionDataTask * _Nullable task, NSError * _Nonnull error) {
        callback(error);
    }];
}


+(void)request:(NSString*)url complete:(void (^)(id res))callback{
    
    AFHTTPSessionManager *manager = [AFHTTPSessionManager manager];
    manager.responseSerializer = [AFHTTPResponseSerializer serializer];
    
    [manager.requestSerializer setTimeoutInterval:10.0];
    [manager GET:url parameters:@{} headers:@{} progress:nil success:^(NSURLSessionTask *task, id res)
    {
        callback(res);
    }
         failure:^(NSURLSessionTask *operation, NSError *error)
    {
        callback(error);
    }];
}



+(void)share:(UIViewController*)vc text:(NSString*)textToShare{
    UIActivityViewController *activityVC = [[UIActivityViewController alloc] initWithActivityItems:@[textToShare] applicationActivities:nil];
    activityVC.excludedActivityTypes = @[UIActivityTypePrint, UIActivityTypeCopyToPasteboard, UIActivityTypeAssignToContact, UIActivityTypeSaveToCameraRoll]; //Exclude whichever aren't relevant
    [vc presentViewController:activityVC animated:YES completion:nil];
}

@end
