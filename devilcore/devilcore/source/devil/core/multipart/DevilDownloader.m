//
//  DevilDownloader.m
//  devilcore
//
//  Created by Mu Young Ko on 2024/04/16.
//

#import "DevilDownloader.h"
#import "DevilController.h"
#import "JevilInstance.h"
#import "DevilUtil.h"
#import "DevilLang.h"

@interface DevilDownloader()
@property void (^progress_callback)(id res);
@property void (^complete_callback)(id res);
@property double lastTime;
@property BOOL showProgress;
@property (nonatomic, retain) NSString* filePath;
@property (nonatomic, retain) NSString* filePathEncoding;
@property (nonatomic, retain) NSString* urlString;
@property long long downloadSize;
@property long long currentDownloadSize;
@property (nonatomic, retain) NSURLSessionDataTask* task;
@property (nonatomic, strong) NSFileHandle *fileHandle;

@end

@implementation DevilDownloader

/**
 미완
 */
-(void)download:(BOOL)showProgress url:(NSString*)urlString header:(id)header filePath:(NSString*)filePath progress:(void (^)(id res))progress_callback complete:(void (^)(id res))callback {
    self.urlString = urlString;
    self.showProgress = showProgress;
    self.progress_callback = progress_callback;
    self.complete_callback = callback;
    self.filePathEncoding = self.filePath = filePath;
    
    DevilController* vc = (DevilController*)[JevilInstance currentInstance].vc;
    [vc.retainObject addObject:self];
    if(showProgress) {
        [DevilUtil showAlert:vc msg:trans(@"Downloading") showYes:YES yesText:trans(@"Cancel") cancelable:false callback:^(BOOL yes) {
            if(yes) {
                [vc closeActiveAlertMessage];
                [self.task cancel];
                id r = [@{@"r":@FALSE, @"msg":@"Canceled"} mutableCopy];
                dispatch_async(dispatch_get_main_queue(), ^{callback(r);});
            }
        }];
    }
    
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_HIGH, 0), ^{
        
        NSMutableURLRequest *request = [[NSMutableURLRequest alloc] init];
        [request setURL:[NSURL URLWithString:urlString]];
        [request setAllHTTPHeaderFields:header];
        [request setHTTPMethod:@"GET"];
        
        NSURLSessionConfiguration* sessionConfig = [NSURLSessionConfiguration defaultSessionConfiguration];
        NSURLSession* session = [NSURLSession sessionWithConfiguration:sessionConfig delegate:self delegateQueue:[NSOperationQueue mainQueue]];
        NSURLSessionDataTask* task = [session dataTaskWithRequest:request];
        
        if (@available(iOS 15.0, *)) {
            task.delegate = self;
        }
        
        [task resume];
        self.task = task;
    });
}


// 데이터 수신 시작
- (void)URLSession:(NSURLSession *)session dataTask:(NSURLSessionDataTask *)dataTask
                                 didReceiveResponse:(NSURLResponse *)response
 completionHandler:(void (NS_SWIFT_SENDABLE ^)(NSURLSessionResponseDisposition disposition))completionHandler {
    completionHandler(NSURLSessionResponseAllow);
    
    NSHTTPURLResponse* res = (NSHTTPURLResponse*)response;
    NSString* contentDisposition = res.allHeaderFields[@"Content-Disposition"];
    
    if(self.filePath == nil && contentDisposition != nil) {
        
        NSString* filename = @"";
        id ss = [[res description] componentsSeparatedByString:@");"];
        for(NSString* line in ss) {
            if([line containsString:@"Content-Disposition"]) {
                NSRange range = [line rangeOfString:@"filename=\\\""];
                if(range.length > 0) {
                    NSString* part = [line substringFromIndex:range.location + range.length];
                    part = [part stringByReplacingOccurrencesOfString:@"\\\"\"" withString:@""];
                    part = [part stringByReplacingOccurrencesOfString:@"\n" withString:@""];
                    part = [part stringByReplacingOccurrencesOfString:@"\\U00" withString:@"%"];
                    part = urldecode(part);
                    filename = trim(part);
                }
            }
        }
        self.filePath = [DevilUtil generateTempFilePathWithName:filename];
        self.filePathEncoding = [self.filePath stringByReplacingOccurrencesOfString:filename withString:urlencode(filename)];
    }
    
    if(!self.filePath) {
        NSString* ext = [DevilUtil getFileExt:self.urlString];
        NSString* name = urldecode([DevilUtil getFileName:self.urlString]);
        NSString* filename = [NSString stringWithFormat:@"%@.%@", name, ext];
        self.filePath = [DevilUtil generateTempFilePathWithName:filename];
        self.filePathEncoding = [self.filePath stringByReplacingOccurrencesOfString:filename withString:urlencode(filename)];
    }
    
    self.downloadSize = response.expectedContentLength;
    self.currentDownloadSize = 0;
    
    if ([[NSFileManager defaultManager] fileExistsAtPath:self.filePath])
        [[NSFileManager defaultManager] removeItemAtPath:self.filePath error:nil];
    [[NSFileManager defaultManager] createFileAtPath:self.filePath contents:nil attributes:nil];
    self.fileHandle = [NSFileHandle fileHandleForWritingAtPath:self.filePath];
}

- (void)URLSession:(NSURLSession *)session dataTask:(NSURLSessionDataTask *)dataTask
    didReceiveData:(NSData *)data {
    
    self.currentDownloadSize += [data length];
    [self.fileHandle writeData:data];
    
    if(self.progress_callback || self.showProgress) {
        dispatch_async(dispatch_get_main_queue(), ^{
            
            double now = (double)[NSDate date].timeIntervalSince1970;
            if( (now - self.lastTime) < 0.3 || self.currentDownloadSize == self.downloadSize) {
                return;
            }
            
            self.lastTime = now;
            DevilController* vc = (DevilController*)[JevilInstance currentInstance].vc;
            if(self.downloadSize > 0 && self.currentDownloadSize > 0) {
                if(self.showProgress)
                    [vc setActiveAlertMessage:[NSString stringWithFormat:@"%@... %d%%", trans(@"Downloading"),
                                               (int)(self.currentDownloadSize*100/self.downloadSize)]];
                else {
                    self.progress_callback(@{
                        @"sent": [NSNumber numberWithLong:self.currentDownloadSize],
                        @"total": [NSNumber numberWithLong:self.downloadSize],
                        @"rate": [NSNumber numberWithInt:(int)(self.currentDownloadSize*100/self.downloadSize)],
                    });
               }
            }
        });
    }
}

- (void)URLSession:(NSURLSession *)session task:(NSURLSessionTask *)task didCompleteWithError:(nullable NSError *)error {
    
    [self.fileHandle closeFile];
    self.fileHandle = nil;
    
    __block id result = [@{@"r":@TRUE} mutableCopy];
    if(error != nil) {
        result[@"r"] = @FALSE;
        result[@"msg"] = [error localizedDescription];
    } else if(self.downloadSize != self.currentDownloadSize) {
        result[@"r"] = @FALSE;
        result[@"msg"] = @"File Size Different";
    } else {
        result[@"dest"] = self.filePath;
        result[@"dest_encoding"] = self.filePathEncoding;
        result[@"size"] = [NSNumber numberWithLongLong:self.currentDownloadSize];
    }

    dispatch_async(dispatch_get_main_queue(), ^{
        if(self.showProgress) {
            DevilController* vc = (DevilController*)[JevilInstance currentInstance].vc;
            [vc closeActiveAlertMessage];
        }
    });
    
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(1 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        dispatch_async(dispatch_get_main_queue(), ^{
            self.complete_callback(result);
            self.filePathEncoding = self.filePath = nil;
            self.progress_callback = self.complete_callback = nil;
        });
    });
    
}



- (void)URLSession:(NSURLSession *)session dataTask:(NSURLSessionDataTask *)dataTask
    didBecomeDownloadTask:(NSURLSessionDownloadTask *)downloadTask {
    
}


@end
