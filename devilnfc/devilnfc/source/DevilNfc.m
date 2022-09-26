//
//  DevilNfc.m
//  devilcore
//
//  Created by Mu Young Ko on 2022/07/23.
//

#import "DevilNfc.h"
@import devilcore;
@import CoreNFC;

@interface DevilNfc() <NFCNDEFReaderSessionDelegate>
@property (nonatomic, retain) NFCNDEFReaderSession* session;
@property NFCNDEFMessage* detectedMessage;
@property (nonatomic, retain) id param;
@property void (^callback)(id res);
@end

@implementation DevilNfc

+ (DevilNfc*)sharedInstance {
    static DevilNfc *sharedInstance = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        sharedInstance = [[self alloc] init];
    });
    return sharedInstance;
}

- (void)start:(id)param :(void (^)(id res))callback {
    if([NFCNDEFReaderSession readingAvailable]) {
        self.param = param;
        self.callback = callback;
        self.session = [[NFCNDEFReaderSession alloc] initWithDelegate:self queue:nil invalidateAfterFirstRead:YES];
        [self.session beginSession];
    }
}

- (void)stop {
    if(self.session) {
        [self.session invalidateSession];
        self.session = nil;
    }
}


- (void)readAndCallback:(id)tag {
    [tag readNDEFWithCompletionHandler:^(NFCNDEFMessage * _Nullable msg, NSError * _Nullable err) {
        NSLog(@"%@", msg);
        id r = [@{} mutableCopy];
        r[@"r"] = @TRUE;
        r[@"id"] = @"none";
        r[@"tech_list"] = [@[] mutableCopy];
        r[@"record_list"] = [@[] mutableCopy];
        
        if([msg.records count] > 0) {
            NSData* payload = [[msg.records firstObject] payload];
            NSString* payload_text = [[NSString alloc] initWithData:payload encoding:NSUTF8StringEncoding];
            [r[@"record_list"] addObject:[@{
                @"payload_hex":[self hexString:payload],
                @"payload_text":payload_text,
            } mutableCopy]];
        }
        [self.session invalidateSession];
        self.session = nil;
        
        [[DevilDebugView sharedInstance] log:DEVIL_LOG_NFC title:@"read" log:r];
        
        if(self.callback) {
            dispatch_async(dispatch_get_main_queue(), ^{
                self.callback(r);
            });
        }
    }];
}

- (void)readerSession:(NFCNDEFReaderSession *)session didDetectTags:(NSArray<__kindof id<NFCNDEFTag>> *)tags{
    NSLog(@"didDetectTags");
    if([tags count] > 0) {
        id tag = tags[0];
        
        [session connectToTag:tag completionHandler:^(NSError * _Nullable error) {
            [tag queryNDEFStatusWithCompletionHandler:^(NFCNDEFStatus status, NSUInteger capacity, NSError * _Nullable error) {
                if(status == NFCNDEFStatusReadWrite || status == NFCNDEFStatusReadOnly) {
                    if(self.param[@"write"] && (self.param[@"write"][@"hex"] || self.param[@"write"][@"text"])) {
                        NSString* hex = self.param[@"write"][@"hex"];
                        NSString* text = self.param[@"write"][@"text"];
                        
                        NSData* b = nil;
                        if(hex)
                            b = [self fromHexString:hex];
                        else if(text) {
                            text = [text stringByReplacingOccurrencesOfString:@"\\n" withString:@"\n"];
                            text = [text stringByReplacingOccurrencesOfString:@"\\r" withString:@"\r"];
                            text = [text stringByReplacingOccurrencesOfString:@"\\t" withString:@"\t"];
                            b = [text dataUsingEncoding:NSUTF8StringEncoding];
                        }
                        
                        if(b) {
                            NSString* s = [[NSString alloc] initWithData:b encoding:NSUTF8StringEncoding];
                            [[DevilDebugView sharedInstance] log:DEVIL_LOG_NFC title:@"write" log:@{
                                @"text":s,
                            }];
                            
                            NFCNDEFPayload* payload = [NFCNDEFPayload wellKnownTypeURIPayloadWithString:s];
                            NFCNDEFMessage* ndefmsg = [[NFCNDEFMessage alloc] initWithNDEFRecords:@[payload]];
                            [tag writeNDEF:ndefmsg completionHandler:^(NSError * _Nullable err) {
                                if(err) {
                                    NSLog(@"%@", err);
                                }
                                
                                float writeAndReadTermMs = 0.25f;
                                if(self.param[@"writeAndReadTermMs"]) {
                                    writeAndReadTermMs = [self.param[@"writeAndReadTermMs"] longValue] / 1000.0f;
                                    
                                }
                                [NSThread sleepForTimeInterval:writeAndReadTermMs];
                                
                                [self readAndCallback:tag];
                            }];
                        }
                    } else {
                        [self readAndCallback:tag];
                    }
                }
                
            }];
        }];
    }
}
- (void)readerSession:(NFCNDEFReaderSession *)session didDetectNDEFs:(NSArray<NFCNDEFMessage *> *)messages {
    NSLog(@"didDetectNDEFs");
}

- (void)readerSessionDidBecomeActive:(NFCNDEFReaderSession *)session {
    NSLog(@"readerSessionDidBecomeActive");
}

- (void)readerSession:(NFCNDEFReaderSession *)session didInvalidateWithError:(NSError *)error {
    NSLog(@"didInvalidateWithError");
}

- (NSString *) hexString : (NSData*)data
{
    NSUInteger bytesCount = data.length;
    if (bytesCount) {
        const char *hexChars = "0123456789ABCDEF";
        const unsigned char *dataBuffer = data.bytes;
        char *chars = malloc(sizeof(char) * (bytesCount * 2 + 1));
        if (chars == NULL) {
            // malloc returns null if attempting to allocate more memory than the system can provide. Thanks Cœur
            [NSException raise:NSInternalInconsistencyException format:@"Failed to allocate more memory" arguments:nil];
            return nil;
        }
        char *s = chars;
        for (unsigned i = 0; i < bytesCount; ++i) {
            *s++ = hexChars[((*dataBuffer & 0xF0) >> 4)];
            *s++ = hexChars[(*dataBuffer & 0x0F)];
            dataBuffer++;
        }
        *s = '\0';
        NSString *hexString = [NSString stringWithUTF8String:chars];
        free(chars);
        return hexString;
    }
    return @"";
}

- (NSData*) fromHexString : (NSString*)command{
    command = [command stringByReplacingOccurrencesOfString:@" " withString:@""];
    NSMutableData *commandToSend= [[NSMutableData alloc] init];
    unsigned char whole_byte;
    char byte_chars[3] = {'\0','\0','\0'};
    int i;
    for (i=0; i < [command length]/2; i++) {
        byte_chars[0] = [command characterAtIndex:i*2];
        byte_chars[1] = [command characterAtIndex:i*2+1];
        whole_byte = strtol(byte_chars, NULL, 16);
        [commandToSend appendBytes:&whole_byte length:1];
    }
    NSLog(@"%@", commandToSend);
    return commandToSend;
}


@end
