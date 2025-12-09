//
//  DevilSpeech.m
//  devilcore
//
//  Created by Mu Young Ko on 2021/05/21.
//

#import "DevilSpeech.h"
@import Speech;

@interface DevilSpeech () <SFSpeechRecognizerDelegate, SFSpeechRecognitionTaskDelegate, AVSpeechSynthesizerDelegate, AVAudioPlayerDelegate>

@property void (^callback)(id text);
@property (nonatomic, strong) SFSpeechRecognizer* speechRecognizer;
@property (nonatomic, strong) SFSpeechAudioBufferRecognitionRequest * recognitionRequest;
@property (nonatomic, strong) SFSpeechRecognitionTask* recognitionTask;
@property (nonatomic, strong) AVAudioEngine* audioEngine;
@property (nonatomic, strong) AVAudioInputNode* inputNode;
@property (nonatomic, strong) AVAudioPlayer* beepPlayer;
@property (nonatomic, strong) NSString* text;
@property NSTimeInterval lastSpeechTime;
@property BOOL ing;
@property BOOL streaming;
@property int index;
@end

@implementation DevilSpeech

+ (DevilSpeech*)sharedInstance {
    static DevilSpeech *sharedInstance = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        sharedInstance = [[self alloc] init];
        sharedInstance.index = 0;
    });
    return sharedInstance;
}

- (void)playBeep{
    
    [[AVAudioSession sharedInstance] setCategory: AVAudioSessionCategoryPlayback error: nil];
    
    NSError *error;
    NSBundle *bundle = [NSBundle bundleForClass:[self class]];
    NSString *path = [bundle pathForResource:@"devil_record_start" ofType:@"mp3"];
    self.beepPlayer = [[AVAudioPlayer alloc] initWithContentsOfURL:[NSURL fileURLWithPath:path] error:&error];
    self.beepPlayer.numberOfLoops = 1;
    self.beepPlayer.currentTime = 0.0;
    self.beepPlayer.volume = 1.0f;
    
    BOOL playback = [self.beepPlayer play];
    self.beepPlayer.delegate = self;
}

- (void)audioPlayerDidFinishPlaying:(AVAudioPlayer *)player successfully:(BOOL)flag {
    NSLog(@"audioPlayerDidFinishPlaying");
    if(!self.ing)
        [[AVAudioSession sharedInstance] setActive:NO error:nil];
    
}

- (void)audioPlayerDecodeErrorDidOccur:(AVAudioPlayer *)player error:(NSError * __nullable)error{
    NSLog(@"audioPlayerDecodeErrorDidOccur %@", error);
}

- (void)listen:(id)param :(void (^)(id text))callback {
    self.audioEngine = [[AVAudioEngine alloc] init];
    self.streaming = [param[@"streaming"] boolValue];
    self.ing = true;
    [SFSpeechRecognizer requestAuthorization:^(SFSpeechRecognizerAuthorizationStatus status) {
        if(status == SFSpeechRecognizerAuthorizationStatusAuthorized){
            self.callback = callback;

            [self playBeep];
            dispatch_async(dispatch_get_main_queue(), ^{
                [self performSelector:@selector(listenCore:) withObject:param afterDelay:0.5f];
            });
        } else {
            NSLog(@"Speech Recognition Authorization Status: %ld", (long)status);
        }
    }];
}

- (void)listenCore:(id)param {
    NSString* locale = @"ko-KR";
    if(param[@"locale"])
        locale = param[@"locale"];
    self.speechRecognizer = [[SFSpeechRecognizer alloc] initWithLocale:[[NSLocale alloc] initWithLocaleIdentifier:locale] ];
    self.speechRecognizer.delegate = self;
    
    if (!self.speechRecognizer.isAvailable) {
        NSLog(@"SFSpeechRecognizer is not available right now. Check network connection or device support.");
        // 사용자에게 알리거나 재시도를 요청하는 로직 추가
        return;
    }
    
    if(self.recognitionTask != nil) {
        [self.recognitionTask cancel];
        self.recognitionTask = nil;
    }
    if(self.inputNode != nil)
        self.inputNode = nil;
    
    AVAudioSession* session = [AVAudioSession sharedInstance];
    NSError *categoryError = nil;
    [session setCategory:AVAudioSessionCategoryRecord
             mode:AVAudioSessionModeMeasurement
          options:AVAudioSessionCategoryOptionAllowBluetooth | AVAudioSessionCategoryOptionInterruptSpokenAudioAndMixWithOthers
            error:&categoryError];

    if (categoryError) {
        NSLog(@"AVAudioSession setCategory error: %@", categoryError.localizedDescription);
        // 여기서 콜백을 통해 에러를 알리는 로직을 추가할 수 있습니다.
        return;
    }

    NSError *activationError = nil;
    BOOL success = [session setActive:YES withOptions:AVAudioSessionSetActiveOptionNotifyOthersOnDeactivation error:&activationError];

    if (!success || activationError) {
        NSLog(@"AVAudioSession setActive error: %@", activationError.localizedDescription);
        return;
    }
    
    self.recognitionRequest = [[SFSpeechAudioBufferRecognitionRequest alloc] init];
    self.inputNode = self.audioEngine.inputNode;
    AVAudioFormat *recordingFormat = [self.inputNode outputFormatForBus:0];
    NSLog(@"Audio Input Format Sample Rate: %f, Channels: %lu",
          recordingFormat.sampleRate, (unsigned long)recordingFormat.channelCount);
    
    self.recognitionRequest.shouldReportPartialResults = YES;
    
    self.recognitionTask = [self.speechRecognizer recognitionTaskWithRequest:self.recognitionRequest delegate:self];
    NSLog(@"Task created pointer: %@", self.recognitionTask); // Task 객체가 nil이 아닌지 확인
    
    [self.inputNode installTapOnBus:0 bufferSize:1024 format:[self.inputNode outputFormatForBus:0] block:^(AVAudioPCMBuffer * _Nonnull buffer, AVAudioTime * _Nonnull when) {
        [self.recognitionRequest appendAudioPCMBuffer:buffer];
    }];
    
    [self.audioEngine prepare];
    NSError* error;
    [self.audioEngine startAndReturnError:&error];
    if(error) {
        NSLog(@"%@", error);
    }
     
    
    self.text = @"";
    dispatch_async(dispatch_get_main_queue(), ^{
        [self performSelector:@selector(stopReserve) withObject:nil afterDelay:3];
    });
}

- (void)stopReserve {
    NSTimeInterval now = [[NSDate date] timeIntervalSince1970];
    if((now - self.lastSpeechTime) >= 3.0f)
        [self finish];
    else if(self.ing) {
        [self performSelector:@selector(stopReserve) withObject:nil afterDelay:3];
    }
}

- (void) finish {
    self.ing = false;
    if(self.callback != nil) {
        self.callback(@{
            @"r":@TRUE,
            @"text":self.text,
            @"end":@TRUE,
        });
    }
    
    [self stop];
}

- (void) cancel {
    self.ing = false;
    self.callback = nil;
    [self stop];
}

- (void) stop {
    self.ing = false;
    if(self.audioEngine != nil && self.audioEngine.isRunning) {
        [self.audioEngine stop];
    }
    
    if(self.recognitionRequest)
        [self.recognitionRequest endAudio];
    if(self.inputNode)
        [self.inputNode removeTapOnBus:0];
    
    self.inputNode = nil;
    self.recognitionTask = nil;
    self.recognitionRequest = nil;
    self.audioEngine = nil;
    
    [self performSelector:@selector(playBeep) withObject:nil afterDelay:0.5f];
}
- (void)speechRecognitionDidDetectSpeech:(SFSpeechRecognitionTask *)task{
    NSLog(@"speechRecognitionDidDetectSpeech");
}

- (void)speechSynthesizer:(AVSpeechSynthesizer *)synthesizer didCancelSpeechUtterance:(AVSpeechUtterance *)utterance{
    
}

- (void)speechRecognitionTask:(SFSpeechRecognitionTask *)task didStartSubmittingAudio:(SFSpeechRecognitionRequest *)request {
    NSLog(@"🟢 Audio Submission Started. Waiting for transcription...");
}

- (void)speechRecognitionTaskWasCancelled:(SFSpeechRecognitionTask *)task{
    NSLog(@"speechRecognitionTaskWasCancelled");
}

- (void)speechRecognitionTask:(SFSpeechRecognitionTask *)task didFinishRecognition:(SFSpeechRecognitionResult *)result{
    NSLog(@"didFinishRecognition");
    self.text = [[result bestTranscription] formattedString];
    NSLog(@"%@", self.text);
    if([result isFinal]){
        [self.audioEngine stop];
        [self.inputNode removeTapOnBus:0];
        self.recognitionTask = nil;
        self.recognitionRequest = nil;
    }
    
    if([self.text length] >= 4) {
        [self finish];
    }

}

- (void)speechRecognitionTask:(SFSpeechRecognitionTask *)task didFinishWithError:(NSError *)error {
    NSLog(@"didFinishWithError: %@", error);
    
    // 에러 발생 시 처리 (네트워크 문제, 권한 문제, 서버 응답 없음 등)
    if (error) {
        // 에러를 콜백으로 전달하거나, 사용자에게 알리는 로직 추가
        if (self.callback != nil) {
            self.callback(@{
                @"r":@FALSE,
                @"error":error.localizedDescription,
                @"end":@TRUE,
            });
        }
    }
    
    [self stop]; // 에러 발생 시 정리
}

- (void)speechRecognitionTask:(SFSpeechRecognitionTask *)task didHypothesizeTranscription:(SFTranscription *)transcription{
    NSLog(@"didHypothesizeTranscription");
    self.lastSpeechTime = [[NSDate date] timeIntervalSince1970];
    self.text = [transcription formattedString];
    NSLog(@"%@", self.text);
    if(self.streaming && self.callback) {
        self.callback(@{
            @"r":@TRUE,
            @"text":self.text,
            @"end":@FALSE,
        });
    }
}


- (BOOL)isRecording {
    return _ing;
}

@end
