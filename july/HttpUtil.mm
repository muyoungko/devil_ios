//
//  HttpUtil.m
//  library
//
//  Created by Mu Young Ko on 2017. 1. 28..
//  Copyright © 2017년 sbs cnbc. All rights reserved.
//

#import "HttpUtil.h"

@implementation HttpUtil

+(void)get:(NSString*)url : (void (^)(id))callback
{
    
    NSURL* nsurl = [NSURL URLWithString:url];
    NSURLSession* session = [NSURLSession sharedSession];
    NSMutableURLRequest* request =[NSMutableURLRequest requestWithURL:nsurl];
    [request setHTTPMethod:@"GET"];
    NSArray *cookies = [[NSHTTPCookieStorage sharedHTTPCookieStorage] cookies];
    NSData *cookieData = [NSKeyedArchiver archivedDataWithRootObject:cookies];

    if([cookieData length]) {
        NSArray *cookies =
        [NSKeyedUnarchiver unarchiveObjectWithData:cookieData];
    
        
        NSMutableString *cookieStringToSet = [[NSMutableString alloc] init];
        for (NSHTTPCookie *cookie in cookies) {
            [cookieStringToSet appendFormat:@"%@=%@;",
             cookie.name, cookie.value];
        }
        
        if (cookieStringToSet.length) {
            [request setValue:cookieStringToSet forHTTPHeaderField:@"Cookie"];
            //NSLog(@"Cookie : %@", cookieStringToSet);
        }
    }
    
    NSURLSessionDataTask* task = [session dataTaskWithRequest:request completionHandler:^(NSData *data, NSURLResponse *response, NSError *error) {
        if(error == nil)
        {
            id json = [NSJSONSerialization JSONObjectWithData:data options:NSJSONReadingMutableContainers error:nil];
            
            [[NSOperationQueue mainQueue] addOperationWithBlock:^ {
                callback(json);
            }];
        }
        else
        {
            [[NSOperationQueue mainQueue] addOperationWithBlock:^ {
                callback(nil);
            }];
        }
    }];
    [task resume];
}


+(void)getImage:(NSString*)url : (void (^)(id))callback
{
    
    NSURL* nsurl = [NSURL URLWithString:url];
    NSURLSession* session = [NSURLSession sharedSession];
    NSMutableURLRequest* request =[NSMutableURLRequest requestWithURL:nsurl];
    [request setHTTPMethod:@"GET"];
    NSURLSessionDataTask* task = [session dataTaskWithRequest:request completionHandler:^(NSData *data, NSURLResponse *response, NSError *error) {
        if(error == nil)
        {
            UIImage* res = [UIImage imageWithData:data];
            [[NSOperationQueue mainQueue] addOperationWithBlock:^ {
                callback(res);
            }];
        }
        else
        {
            [[NSOperationQueue mainQueue] addOperationWithBlock:^ {
                callback(nil);
            }];
        }
    }];
    [task resume];
}

+(void)post:(NSString*)url :(NSDictionary *)parameters : (void (^)(id))callback
{
    
    NSDictionary *headers = @{ @"Content-Type": @"application/json",
                               @"SVC_CD": @"107",
                               @"cache-control": @"no-cache"};
    
    NSData *postData = [NSJSONSerialization dataWithJSONObject:parameters options:0 error:nil];
    
    NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:[NSURL URLWithString:url]
                                                           cachePolicy:NSURLRequestUseProtocolCachePolicy
                                                       timeoutInterval:10.0];
    [request setHTTPMethod:@"POST"];
    [request setAllHTTPHeaderFields:headers];
    [request setHTTPBody:postData];
    
    NSURLSession *session = [NSURLSession sharedSession];
    NSURLSessionDataTask *dataTask = [session dataTaskWithRequest:request
                                                completionHandler:^(NSData *data, NSURLResponse *response, NSError *error) {
                                                    if(error == nil)
                                                    {
                                                        id json = [NSJSONSerialization JSONObjectWithData:data options:NSJSONReadingMutableContainers error:nil];
                                                        
                                                        [[NSOperationQueue mainQueue] addOperationWithBlock:^ {
                                                            callback(json);
                                                        }];
                                                    }
                                                    else
                                                    {
                                                        [[NSOperationQueue mainQueue] addOperationWithBlock:^ {
                                                            callback(nil);
                                                        }];
                                                    }
                                                }];
    [dataTask resume];
    
}


@end
