#import "JulyUtil.h"

// Multipart 업로드 진행률 및 완료를 처리하는 내부 delegate
@interface JulyUploadDelegate : NSObject <NSURLSessionDataDelegate>
@property (nonatomic, copy) void (^progressCallback)(long sentByte, long totalByte);
@property (nonatomic, copy) void (^completeCallback)(id res);
@property (nonatomic, strong) NSMutableData *responseData;
- (instancetype)initWithProgress:(void (^)(long, long))progress complete:(void (^)(id))complete;
@end

@implementation JulyUploadDelegate

- (instancetype)initWithProgress:(void (^)(long, long))progress complete:(void (^)(id))complete {
    self = [super init];
    self.progressCallback = progress;
    self.completeCallback = complete;
    self.responseData = [NSMutableData data];
    return self;
}

- (void)URLSession:(NSURLSession *)session task:(NSURLSessionTask *)task didSendBodyData:(int64_t)bytesSent totalBytesSent:(int64_t)totalBytesSent totalBytesExpectedToSend:(int64_t)totalBytesExpectedToSend {
    if (self.progressCallback) {
        self.progressCallback((long)totalBytesSent, (long)totalBytesExpectedToSend);
    }
}

- (void)URLSession:(NSURLSession *)session dataTask:(NSURLSessionDataTask *)dataTask didReceiveData:(NSData *)data {
    [self.responseData appendData:data];
}

- (void)URLSession:(NSURLSession *)session task:(NSURLSessionTask *)task didCompleteWithError:(NSError *)error {
    if (error) {
        self.completeCallback(@{@"r": @FALSE, @"msg": [error localizedDescription]});
        return;
    }
    NSError *jsonError;
    id json = [NSJSONSerialization JSONObjectWithData:self.responseData options:NSJSONReadingMutableContainers error:&jsonError];
    self.completeCallback(jsonError ? @{@"r": @FALSE} : json);
    [session finishTasksAndInvalidate];
}

@end

@implementation JulyUtil

// 1. 숫자 콤마 포맷팅
+(NSString*)comma:(int)m{
    NSNumberFormatter * formatter = [NSNumberFormatter new];
    [formatter setNumberStyle:NSNumberFormatterDecimalStyle];
    return [formatter stringFromNumber:[NSNumber numberWithInteger:m]];
}

// 2. 날짜 포맷팅 (yyyyMMdd -> yyyy/MM/dd)
+(NSString*)dateFormatSlash:(NSString*)yyyyMMdd{
    if(yyyyMMdd.length < 8) return yyyyMMdd;
    return [NSString stringWithFormat:@"%@/%@/%@",
            [yyyyMMdd substringWithRange:NSMakeRange(0, 4)],
            [yyyyMMdd substringWithRange:NSMakeRange(4, 2)],
            [yyyyMMdd substringWithRange:NSMakeRange(6, 2)]];
}

// 3. 날짜 포맷팅 (yyyyMMdd -> MM/dd)
+(NSString*)dateFormatMMddSlash:(NSString*)yyyyMMdd{
    if(yyyyMMdd.length < 8) return yyyyMMdd;
    return [NSString stringWithFormat:@"%@/%@",
            [yyyyMMdd substringWithRange:NSMakeRange(4, 2)],
            [yyyyMMdd substringWithRange:NSMakeRange(6, 2)]];
}

// 4. 리스트에서 특정 키값으로 객체 찾기
+(id)getFromList:(id)list col:(NSString*)col key:(NSString*)key{
    for(int i=0; list != nil && i < [list count]; i++){
        if([list[i][col] isEqualToString:key]) return list[i];
    }
    return nil;
}

// 5. 리스트에서 특정 키값으로 인덱스 찾기
+(int)getIndexFromList:(id)list col:(NSString*)col key:(NSString*)key{
    for(int i=0; list != nil && i < [list count]; i++){
        if([list[i][col] isEqualToString:key]) return i;
    }
    return -1;
}

// 6. 공통 네트워크 요청 메서드 (내부용 보조 메서드)
+(void)baseRequest:(NSMutableURLRequest*)request complete:(void (^)(id res))callback {
    NSURLSession *session = [NSURLSession sharedSession];
    [[session dataTaskWithRequest:request completionHandler:^(NSData * _Nullable data, NSURLResponse * _Nullable response, NSError * _Nullable error) {
        
        dispatch_async(dispatch_get_main_queue(), ^{
            if (error) {
                callback(error);
                return;
            }
            if (!data) {
                callback(nil);
                return;
            }
            
            NSError *jsonError;
            id json = [NSJSONSerialization JSONObjectWithData:data options:NSJSONReadingMutableContainers error:&jsonError];
            
            if (jsonError) {
                // JSON이 아닌 경우 문자열로 반환 시도
                NSString *str = [[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding];
                callback(str ? str : data);
            } else {
                callback(json);
            }
        });
    }] resume];
}

// 7. GET/POST 기본 요청
+(void)request:(NSString*)url postParam:(id _Nullable)params complete:(void (^)(id res))callback{
    NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:[NSURL URLWithString:url]];
    [request setTimeoutInterval:10.0];
    [request setValue:@"application/json" forHTTPHeaderField:@"Accept"];
    
    if(params != nil){
        [request setHTTPMethod:@"POST"];
        [request setValue:@"application/json" forHTTPHeaderField:@"Content-Type"];
        NSData *postData = [NSJSONSerialization dataWithJSONObject:params options:0 error:nil];
        [request setHTTPBody:postData];
    } else {
        [request setHTTPMethod:@"GET"];
    }
    
    [self baseRequest:request complete:callback];
}

+(void)request:(NSString*)url complete:(void (^)(id res))callback {
    [self request:url postParam:nil complete:callback];
}

// 8. Header 및 Content-Type 대응 POST 요청
+(void)request:(NSString*)url header:(id _Nullable)header postParam:(id _Nullable)params complete:(void (^)(id res))callback{
    NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:[NSURL URLWithString:url]];
    [request setHTTPMethod:@"POST"];
    [request setTimeoutInterval:10.0];
    
    BOOL isForm = [header[@"content-type"] isEqualToString:@"application/x-www-form-urlencoded"];
    
    for(id key in header) {
        [request setValue:header[key] forHTTPHeaderField:key];
    }
    
    if(params) {
        if(isForm) {
            // Form URL Encoded 처리
            NSMutableArray *parts = [NSMutableArray array];
            for (id key in params) {
                [parts addObject:[NSString stringWithFormat:@"%@=%@", key, params[key]]];
            }
            NSString *bodyString = [parts componentsJoinedByString:@"&"];
            [request setHTTPBody:[bodyString dataUsingEncoding:NSUTF8StringEncoding]];
        } else {
            // JSON 처리
            [request setValue:@"application/json" forHTTPHeaderField:@"Content-Type"];
            [request setHTTPBody:[NSJSONSerialization dataWithJSONObject:params options:0 error:nil]];
        }
    }
    
    [self baseRequest:request complete:callback];
}

// 9. GET 요청 (Token 및 Custom Header 포함)
+(void)request:(NSString*)url header:(id _Nullable)header complete:(void (^)(id res))callback{
    NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:[NSURL URLWithString:url]];
    [request setHTTPMethod:@"GET"];
    [request setTimeoutInterval:10.0];
    [request setValue:@"application/json" forHTTPHeaderField:@"Accept"];
    
    NSString* token = [[NSUserDefaults standardUserDefaults] objectForKey:@"token"];
    if(token) [request setValue:token forHTTPHeaderField:@"x-access-token"];
    
    for(id k in header) {
        [request setValue:header[k] forHTTPHeaderField:k];
    }
    
    [self baseRequest:request complete:callback];
}

// 10. PUT 요청
+(void)request:(NSString*)url header:(id _Nullable)header putParam:(id _Nullable)params complete:(void (^)(id res))callback{
    NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:[NSURL URLWithString:url]];
    [request setHTTPMethod:@"PUT"];
    [request setValue:@"application/json" forHTTPHeaderField:@"Accept"];
    [request setValue:@"application/json" forHTTPHeaderField:@"Content-Type"];
    
    for(id k in header) {
        [request setValue:header[k] forHTTPHeaderField:k];
    }
    
    if(params) {
        [request setHTTPBody:[NSJSONSerialization dataWithJSONObject:params options:0 error:nil]];
    }
    
    [self baseRequest:request complete:callback];
}

// 11. HTTP 메서드 범용 요청 (GET/POST/PUT 등, devil_list 포함 응답 파싱)
+(void)requestHttp:(NSString*)method url:(NSString*)url header:(NSDictionary* _Nullable)header body:(NSMutableDictionary* _Nullable)body complete:(void (^)(NSMutableDictionary* responseJsonObject))success {
    NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:[NSURL URLWithString:url]];
    [request setHTTPMethod:[method uppercaseString]];
    [request setTimeoutInterval:10.0];

    // 기본 헤더
    [request setValue:@"application/json, application/*+json" forHTTPHeaderField:@"Accept"];
    [request setValue:@"application/json" forHTTPHeaderField:@"Content-Type"];

    // 커스텀 헤더 적용
    for (id k in header) {
        [request setValue:header[k] forHTTPHeaderField:k];
    }

    // body 직렬화
    if (body && body.count > 0) {
        BOOL isForm = [@"application/x-www-form-urlencoded" isEqualToString:header[@"Content-Type"]];
        if (isForm) {
            NSMutableArray *parts = [NSMutableArray array];
            for (id key in body) {
                [parts addObject:[NSString stringWithFormat:@"%@=%@", key, body[key]]];
            }
            [request setHTTPBody:[[parts componentsJoinedByString:@"&"] dataUsingEncoding:NSUTF8StringEncoding]];
        } else {
            [request setHTTPBody:[NSJSONSerialization dataWithJSONObject:body options:0 error:nil]];
        }
    }

    NSURLSession *session = [NSURLSession sharedSession];
    [[session dataTaskWithRequest:request completionHandler:^(NSData * _Nullable data, NSURLResponse * _Nullable response, NSError * _Nullable error) {
        dispatch_async(dispatch_get_main_queue(), ^{
            if (error) {
                success((id)error);
                return;
            }
            if (!data) {
                success([@{} mutableCopy]);
                return;
            }
            NSString *s = [[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding];
            if ([s hasPrefix:@"["]) {
                id a = [NSJSONSerialization JSONObjectWithData:data options:NSJSONReadingMutableContainers error:nil];
                success([@{@"devil_list": a} mutableCopy]);
            } else if ([s hasPrefix:@"{"]) {
                id a = [NSJSONSerialization JSONObjectWithData:data options:NSJSONReadingMutableContainers error:nil];
                success(a);
            } else {
                success([@{@"string": s} mutableCopy]);
            }
        });
    }] resume];
}

// 12. Multipart POST 파일 업로드
+(void)multiPartPost:(NSString*)urlString header:(id _Nullable)header name:(NSString*)name filename:(NSString*)filename filePath:(NSString*)filePath progress:(void (^)(long sentByte, long totalByte))progress_callback complete:(void (^)(id res))callback {
    NSString *boundary = [NSString stringWithFormat:@"Boundary-%@", [[NSUUID UUID] UUIDString]];

    NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:[NSURL URLWithString:urlString]];
    [request setHTTPMethod:@"POST"];
    [request setValue:[NSString stringWithFormat:@"multipart/form-data; boundary=%@", boundary] forHTTPHeaderField:@"Content-Type"];
    for (id k in header) {
        [request setValue:header[k] forHTTPHeaderField:k];
    }

    NSData *fileData = [NSData dataWithContentsOfFile:filePath];
    NSMutableData *body = [NSMutableData data];
    [body appendData:[[NSString stringWithFormat:@"--%@\r\n", boundary] dataUsingEncoding:NSUTF8StringEncoding]];
    [body appendData:[[NSString stringWithFormat:@"Content-Disposition: form-data; name=\"%@\"; filename=\"%@\"\r\n", name, filename] dataUsingEncoding:NSUTF8StringEncoding]];
    [body appendData:[@"Content-Type: application/octet-stream\r\n\r\n" dataUsingEncoding:NSUTF8StringEncoding]];
    [body appendData:fileData];
    [body appendData:[[NSString stringWithFormat:@"\r\n--%@--\r\n", boundary] dataUsingEncoding:NSUTF8StringEncoding]];

    JulyUploadDelegate *delegate = [[JulyUploadDelegate alloc] initWithProgress:progress_callback complete:callback];
    NSURLSession *session = [NSURLSession sessionWithConfiguration:[NSURLSessionConfiguration defaultSessionConfiguration]
                                                         delegate:delegate
                                                    delegateQueue:[NSOperationQueue mainQueue]];
    [[session uploadTaskWithRequest:request fromData:body] resume];
}

// 13. 공유하기
+(void)share:(UIViewController*)vc text:(NSString*)textToShare{
    UIActivityViewController *activityVC = [[UIActivityViewController alloc] initWithActivityItems:@[textToShare] applicationActivities:nil];
    activityVC.excludedActivityTypes = @[UIActivityTypePrint, UIActivityTypeCopyToPasteboard, UIActivityTypeAssignToContact, UIActivityTypeSaveToCameraRoll];
    [vc presentViewController:activityVC animated:YES completion:nil];
}

@end
