//
//  DevilNfc.m
//  devilcore
//
//  Created by Mu Young Ko on 2022/07/23.
//

#import "DevilNfc.h"
@import CoreNFC;

@interface DevilNfc() <NFCNDEFReaderSessionDelegate>

@property (nonatomic, retain) NFCNDEFReaderSession* session;
@property NFCNDEFMessage* detectedMessage;

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
        self.session = [[NFCNDEFReaderSession alloc] initWithDelegate:self queue:nil invalidateAfterFirstRead:YES];
        [self.session beginSession];
    }
}
- (void)readerSession:(NFCNDEFReaderSession *)session didDetectTags:(NSArray<__kindof id<NFCNDEFTag>> *)tags{
    NSLog(@"didDetectTags");
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

- (void)stop {
    if(self.session) {
        [self.session invalidateSession];
        self.session = nil;
    }
}

@end
