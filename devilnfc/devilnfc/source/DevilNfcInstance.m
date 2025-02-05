//
//  DevilNfc.m
//  devilcore
//
//  Created by Mu Young Ko on 2022/07/23.
//

#import "DevilNfcInstance.h"
@import devilcore;
@import CoreNFC;

@interface DevilNfcInstance() <NFCNDEFReaderSessionDelegate, NFCTagReaderSessionDelegate>
//@property (nonatomic, retain) NFCNDEFReaderSession* session;
@property (nonatomic, retain) NFCTagReaderSession* session;

@property NFCNDEFMessage* detectedMessage;
@property (nonatomic, retain) id param;
@property id (^callback)(id res);
@end

@implementation DevilNfcInstance

+ (DevilNfcInstance*)sharedInstance {
    static DevilNfcInstance *sharedInstance = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        sharedInstance = [[self alloc] init];
    });
    return sharedInstance;
}
 
- (void)start:(id)param :(id (^)(id res))callback {
    if([NFCNDEFReaderSession readingAvailable])
    {
        self.param = param;
        self.callback = callback;
        self.session = [[NFCTagReaderSession alloc] initWithPollingOption:NFCPollingISO14443 delegate:self queue:nil];
        //self.session = [[NFCNDEFReaderSession alloc] initWithDelegate:self queue:nil invalidateAfterFirstRead:YES];
        [self.session beginSession];
    }
}

- (void)stop {
    if(self.session) {
        [self.session invalidateSession];
        self.session = nil;
    }
}

- (void)tagReaderSession:(NFCTagReaderSession *)session didInvalidateWithError:(NSError *)error API_AVAILABLE(ios(13.0)) API_UNAVAILABLE(watchos, macos, tvos) {
    NSLog(@"didInvalidateWithError");
    //잘읽었는데도 여기가 호출된다
//    if(self.callback) {
//        id r = [@{} mutableCopy];
//        r[@"r"] = @FALSE;
//        r[@"msg"] = @"cancel";
//        dispatch_async(dispatch_get_main_queue(), ^{
//            self.callback(r);
//            self.callback = nil;
//        });
//    }
}

- (void)tagReaderSessionDidBecomeActive:(NFCTagReaderSession *)session API_AVAILABLE(ios(13.0)) API_UNAVAILABLE(watchos, macos, tvos) {
    NSLog(@"tagReaderSessionDidBecomeActive");
}

- (void)tagReaderSession:(NFCTagReaderSession *)session didDetectTags:(NSArray<__kindof id<NFCTag>> *)tags API_AVAILABLE(ios(13.0)) API_UNAVAILABLE(watchos, macos, tvos) {
    NSLog(@"tagReaderSession didDetectTags");
    
    if([tags count] > 0) {
        id tag = tags[0];
        NSData* sn = [[tag asNFCISO7816Tag] identifier];
        NSString* idd = [DevilUtil byteToHex:sn];
        [session connectToTag:tag completionHandler:^(NSError * _Nullable error) {
            if(error) {
                if(self.callback) {
                    id r = [@{} mutableCopy];
                    r[@"r"] = @FALSE;
                    r[@"id"] = idd;
                    r[@"msg"] = [error localizedDescription];
                    NSLog(@"%@", [error localizedDescription]);
                    dispatch_async(dispatch_get_main_queue(), ^{
                        self.callback(r);
                        self.callback = nil;
                    });
                }
                return ;
            }
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
                } else {
                    [self stop];
                    if(self.callback) {
                        id r = [@{} mutableCopy];
                        r[@"r"] = @TRUE;
                        r[@"id"] = idd;
                        dispatch_async(dispatch_get_main_queue(), ^{
                            self.callback(r);
                            self.callback = nil;
                        });
                    }
                }
            }];
        }];
    }
}

- (void)readAndCallback:(id)tag {
    [tag readNDEFWithCompletionHandler:^(NFCNDEFMessage * _Nullable msg, NSError * _Nullable err) {
        NSLog(@"readAndCallback %@", msg);
        id r = [@{} mutableCopy];
        r[@"r"] = @TRUE;
        r[@"id"] = @"none";
        r[@"event"] = @"read";
        r[@"tech_list"] = [@[] mutableCopy];
        r[@"record_list"] = [@[] mutableCopy];
        
        if([msg.records count] > 0) {
            NSData* payload = [[msg.records firstObject] payload];
            //payload에서 첫바이트 제거 0
            //payload = [payload subdataWithRange:[NSMakeRange(1, [payload length]-1)]];
            NSString* payload_text = [[NSString alloc] initWithData:payload encoding:NSUTF8StringEncoding];
            [r[@"record_list"] addObject:[@{
                @"payload_hex":[self hexString:payload],
                @"payload_text":payload_text,
            } mutableCopy]];
        }
        
        [[DevilDebugView sharedInstance] log:DEVIL_LOG_NFC title:@"read" log:r];
        
        if(self.callback) {
            dispatch_async(dispatch_get_main_queue(), ^{
                
                id write_object = self.callback(r);
                if(write_object) {
                    [self nfc_write:tag :write_object];
                } else {
                    [self stop];
                }
            });
        }
    }];
}

- (void)nfc_write:(id)tag :(id)write_object {
    NSString* hex = write_object[@"hex"];
    NSString* text = write_object[@"text"];
    NSString *languageCode = @"en";
    if(write_object[@"language"])
        languageCode = write_object[@"language"];
    
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
        [[DevilDebugView sharedInstance] log:DEVIL_LOG_NFC title:[NSString stringWithFormat:@"write %lu bytes", (unsigned long)[s length] ] log:@{
            @"text":s,
        }];
        
//        [self writeToISO7816Tag:tag data:b completion:^(NSError * _Nullable err) {
//            if(err) {
//                NSLog(@"%@", err);
//                if(self.callback) {
//                    dispatch_async(dispatch_get_main_queue(), ^{
//                        self.callback(@{
//                            @"r":@FALSE,
//                            @"event":@"write",
//                            @"msg":@"NFC write failed",
//                        });
//                    });
//                }
//                return;
//            }
//            
//            [self stop];
//            
//            if(self.callback) {
//                dispatch_async(dispatch_get_main_queue(), ^{
//                    self.callback(@{
//                        @"r":@TRUE,
//                        @"event":@"write",
//                    });
//                });
//            }
//        }];
        
        
        NSData *languageData = [languageCode dataUsingEncoding:NSUTF8StringEncoding];

        /**
         NFC 텍스트 레코드는 **Text Record Type Definition (RTD)**을 따르며, 다음과 같은 구조를 가집니다.
         1 Byte    Status Byte (언어 코드 길이 및 UTF-8/UTF-16 플래그 포함)
         X Byte    언어 코드 (예: "en" = 2바이트)
         Y Byte    텍스트 데이터 (UTF-8 또는 UTF-16 인코딩)
         
         Android에서 자동 생성되는 데이터 (NdefRecord.createTextRecord)
         [0x02] [0x65, 0x6E] [텍스트 데이터]
         
         iOS에서 직접 생성한 데이터
         [0x02] [언어 코드] [텍스트 데이터]
         */
        uint8_t statusByte = (uint8_t)languageData.length & 0x3F; // 상위 비트 0으로 유지 (UTF-8)
        NSData *statusData = [NSData dataWithBytes:&statusByte length:1];

        
        NSMutableData *c = [NSMutableData data];
        [c appendData:statusData];
        [c appendData:languageData];  // 먼저 언어 코드 추가
        [c appendData:b]; // 그 다음 실제 텍스트 추가

        NFCNDEFPayload* payload = [[NFCNDEFPayload alloc] initWithFormat:NFCTypeNameFormatNFCWellKnown
                                                                    type:[@"T" dataUsingEncoding:NSUTF8StringEncoding]
                                                                 identifier:[NSData data]
                                                                   payload:c];
        NFCNDEFMessage* ndefmsg = [[NFCNDEFMessage alloc] initWithNDEFRecords:@[payload]];
        
        [tag writeNDEF:ndefmsg completionHandler:^(NSError * _Nullable err) {
            if(err) {
                NSLog(@"%@", err);
                if(self.callback) {
                    dispatch_async(dispatch_get_main_queue(), ^{
                        self.callback(@{
                            @"r":@FALSE,
                            @"event":@"write",
                            @"msg":@"NFC write failed",
                        });
                    });
                }
                return;
            }
            
            [self stop];
            
            if(self.callback) {
                dispatch_async(dispatch_get_main_queue(), ^{
                    self.callback(@{
                        @"r":@TRUE,
                        @"event":@"write",
                    });
                });
            }
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


- (void)writeToISO7816Tag:(id<NFCISO7816Tag>)tag data:(NSData *)data completion:(void (^)(NSError * _Nullable))completion {
    // APDU 명령 생성
    NFCISO7816APDU *apdu = [[NFCISO7816APDU alloc] initWithInstructionClass:0x00 // CLA
                                                        instructionCode:0xD6       // INS (WRITE BINARY 명령 예시)
                                                        p1Parameter:0x00           // P1
                                                        p2Parameter:0x00           // P2 (오프셋)
                                                        data:data                  // 보낼 데이터
                                                        expectedResponseLength:-1]; // Le (-1: 모든 응답 받기)

    // 명령 전송
    [tag sendCommandAPDU:apdu completionHandler:^(NSData *responseData, uint8_t sw1, uint8_t sw2, NSError *error) {
        if (error) {
            NSLog(@"APDU 전송 실패: %@", error.localizedDescription);
            if (completion) completion(error);
            return;
        }
        
        // 상태 워드(SW1, SW2) 확인
        if (sw1 == 0x90 && sw2 == 0x00) {
            NSLog(@"쓰기 성공");
            if (completion) completion(nil);
        } else {
            NSLog(@"쓰기 실패 - 상태 워드: %02X %02X", sw1, sw2);
            if (completion) completion([NSError errorWithDomain:@"NFCErrorDomain" code:-1 userInfo:@{NSLocalizedDescriptionKey: @"쓰기 실패"}]);
        }
    }];
}

@end
