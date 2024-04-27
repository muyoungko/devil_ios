//
//  DevilMultiPartUploader.m
//  devilcore
//
//  Created by Mu Young Ko on 2024/04/08.
//

#import "DevilMultiPartUploader.h"
#import "DevilController.h"
#import "JevilInstance.h"
#import "DevilUtil.h"
#import "DevilLang.h"

@interface DevilMultiPartUploader()
@property void (^progress_callback)(id res);
@property double lastTime;
@property BOOL showProgress;
@end

@implementation DevilMultiPartUploader

-(void)multiPartUpload:(BOOL)showProgress url:(NSString*)urlString header:(id)header name:(NSString*)name filename:(NSString*)filename filePath:(NSString*)filePath progress:(void (^)(id res))progress_callback complete:(void (^)(id res))callback {
    self.showProgress = showProgress;
    self.progress_callback = progress_callback;
    
    filePath = [DevilUtil replaceUdidPrefixDir:filePath];
    if(![[NSFileManager defaultManager] fileExistsAtPath:filePath])
        return callback(@{@"r":@FALSE, @"msg":@"File Not Found"});
    
    DevilController* vc = (DevilController*)[JevilInstance currentInstance].vc;
    [vc.retainObject addObject:self];
    if(showProgress) {
        [DevilUtil showAlert:vc msg:trans(@"Uploading") showYes:YES yesText:trans(@"Cancel") cancelable:false callback:^(BOOL yes) {
            if(yes) {
                [vc closeActiveAlertMessage];
                id r = [@{@"r":@FALSE, @"msg":@"Canceled"} mutableCopy];
                dispatch_async(dispatch_get_main_queue(), ^{callback(r);});
            }
        }];
    }
    
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_HIGH, 0), ^{
        
        NSData* filedata = [[NSFileManager defaultManager] contentsAtPath:filePath];
        if(filedata == nil) {
            id s = [filePath componentsSeparatedByString:@"/"];
            NSString* file = s[[s count]-1];
            NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
            NSString *documentsDirectory = paths[0];
            NSString* path = [documentsDirectory stringByAppendingPathComponent:file];
            filedata = [[NSFileManager defaultManager] contentsAtPath:path];
        }
        
        if(!filedata) {
            dispatch_async(dispatch_get_main_queue(), ^{
                callback(@{@"r":@FALSE, @"msg":@"file not exists"});
            });
            return;
        }
        
        // Create a multipart form request.
        NSMutableURLRequest *request = [[NSMutableURLRequest alloc] init];
        [request setURL:[NSURL URLWithString:urlString]];
        [request setAllHTTPHeaderFields:header];
        [request setHTTPMethod:@"POST"];
        
        NSString *boundary = @"^-----^";
        NSString *contentType = [NSString stringWithFormat:@"multipart/form-data;charset=utf-8;boundary=%@",boundary];
        [request addValue:contentType forHTTPHeaderField: @"content-type"];
        [request addValue:@"utf-8" forHTTPHeaderField: @"accept-charset"];
        
        NSMutableData *body = [NSMutableData data];
        [body appendData:[[NSString stringWithFormat:@"--%@\r\n",boundary] dataUsingEncoding:NSUTF8StringEncoding]];
        [body appendData:[[NSString stringWithFormat:@"Content-Disposition: form-data; name=\"%@\"; filename=\"%@\"\r\n", name, filename] dataUsingEncoding:NSUTF8StringEncoding]];
        [body appendData:[@"Content-Type: application/octet-stream\r\n" dataUsingEncoding:NSUTF8StringEncoding]];
        [body appendData:[@"Content-Transfer-Encoding: binary\r\n\r\n" dataUsingEncoding:NSUTF8StringEncoding]];
        [body appendData:filedata];
        [body appendData:[[NSString stringWithFormat:@"\r\n--%@--\r\n",boundary] dataUsingEncoding:NSUTF8StringEncoding]];
        [request setHTTPBody:body];
        
        NSURLSessionConfiguration* sessionConfig = [NSURLSessionConfiguration defaultSessionConfiguration];
        
        NSURLSession* session = [NSURLSession sessionWithConfiguration:sessionConfig delegate:self delegateQueue:[NSOperationQueue mainQueue]];
        NSURLSessionDataTask* task = [session dataTaskWithRequest:request completionHandler:^(NSData * _Nullable data, NSURLResponse * _Nullable response, NSError * _Nullable error) {
            
            __block id result = [@{@"r":@TRUE} mutableCopy];
            if(error != nil) {
                result[@"r"] = @FALSE;
                result[@"msg"] = [error localizedDescription];
            }
    
            NSString *s = [[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding];
            if([s hasPrefix:@"{"]){
                result = [NSJSONSerialization JSONObjectWithData:[s dataUsingEncoding:NSUTF8StringEncoding] options:NSJSONReadingMutableContainers error:nil];
            } else {
                result[@"string"] = s;
            }
            dispatch_async(dispatch_get_main_queue(), ^{
                callback(result);
            });
        }];
        
        if (@available(iOS 15.0, *)) {
            task.delegate = self;
        }
        
        [task resume];
    });
}

- (void)URLSession:(NSURLSession *)session task:(NSURLSessionTask *)task
                                didSendBodyData:(int64_t)thisByteSent
    totalBytesSent:(int64_t)byteSent totalBytesExpectedToSend:(int64_t)totalBytesExpectedToSend
{
    if(self.progress_callback) {
        dispatch_async(dispatch_get_main_queue(), ^{
            
            double now = (double)[NSDate date].timeIntervalSince1970;
            if( (now - self.lastTime) < 1 || byteSent == totalBytesExpectedToSend) {
                return;
            }
            
            self.lastTime = now;
            DevilController* vc = (DevilController*)[JevilInstance currentInstance].vc;
            if(totalBytesExpectedToSend > 0 && byteSent > 0) {
                if(self.showProgress)
                    [vc setActiveAlertMessage:[NSString stringWithFormat:@"%@... %d%%", trans(@"Uploading"),
                                               (int)(byteSent*100/totalBytesExpectedToSend)]];
                else {
                    self.progress_callback(@{
                        @"sent": [NSNumber numberWithLong:byteSent],
                        @"total": [NSNumber numberWithLong:totalBytesExpectedToSend],
                        @"rate": [NSNumber numberWithInt:(int)(byteSent*100/totalBytesExpectedToSend)],
                    });
               }
            }
        });
    }
}

@end
