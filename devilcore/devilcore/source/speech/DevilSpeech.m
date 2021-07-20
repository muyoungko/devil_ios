//
//  DevilSpeech.m
//  devilcore
//
//  Created by Mu Young Ko on 2021/05/21.
//

#import "DevilSpeech.h"
@import Speech;

@interface DevilSpeech () <SFSpeechRecognizerDelegate, SFSpeechRecognitionTaskDelegate, AVSpeechSynthesizerDelegate>

@property void (^callback)(id text);
@property (nonatomic, strong) SFSpeechRecognizer* speechRecognizer;
@property (nonatomic, strong) SFSpeechAudioBufferRecognitionRequest * recognitionRequest;
@property (nonatomic, strong) SFSpeechRecognitionTask* recognitionTask;
@property (nonatomic, strong) AVAudioEngine* audioEngine;
@property (nonatomic, strong) AVAudioInputNode* inputNode;
@property (nonatomic, strong) AVAudioPlayer* beepPlayer;
@property (nonatomic, strong) NSString* text;
@end

@implementation DevilSpeech

+ (DevilSpeech*)sharedInstance {
    static DevilSpeech *sharedInstance = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        sharedInstance = [[self alloc] init];
    });
    return sharedInstance;
}

- (void)playBeep{
    NSBundle *bundle = [NSBundle bundleForClass:[self class]];
    NSString *path = [bundle pathForResource:@"devil_camera_record" ofType:@"wav"];
    
    NSError *error;
    self.beepPlayer = [[AVAudioPlayer alloc]initWithContentsOfURL:[NSURL fileURLWithPath:path] error:&error];
    self.beepPlayer.numberOfLoops = 1;
    [self.beepPlayer play];
}

- (void)listen:(id)param :(void (^)(id text))callback {
    self.audioEngine = [[AVAudioEngine alloc] init];
    [SFSpeechRecognizer requestAuthorization:^(SFSpeechRecognizerAuthorizationStatus status) {
        if(status == SFSpeechRecognizerAuthorizationStatusAuthorized){
            self.callback = callback;
            
            [self playBeep];
            dispatch_async(dispatch_get_main_queue(), ^{
                [self performSelector:@selector(listenCore:) withObject:param afterDelay:0.5f];
            });
        }
    }];
}

- (void)listenCore:(id)param {
    self.speechRecognizer = [[SFSpeechRecognizer alloc] initWithLocale:[[NSLocale alloc] initWithLocaleIdentifier:@"ko-KR"] ];
    self.speechRecognizer.delegate = self;
    
    if(self.recognitionTask != nil) {
        [self.recognitionTask cancel];
        self.recognitionTask = nil;
    }
    if(self.inputNode != nil)
        self.inputNode = nil;
    
    AVAudioSession* session = [AVAudioSession sharedInstance];
    [session setCategory:AVAudioSessionCategoryRecord error:nil];
    [session setMode:AVAudioSessionModeMeasurement error:nil];
    [session setActive:YES withOptions:AVAudioSessionSetActiveOptionNotifyOthersOnDeactivation error:nil];
    
    self.recognitionRequest = [[SFSpeechAudioBufferRecognitionRequest alloc] init];
    self.inputNode = self.audioEngine.inputNode;
    
    self.recognitionRequest.shouldReportPartialResults = YES;
    
    self.recognitionTask = [self.speechRecognizer recognitionTaskWithRequest:self.recognitionRequest delegate:self];
    
    [self.inputNode installTapOnBus:0 bufferSize:1024 format:[self.inputNode outputFormatForBus:0] block:^(AVAudioPCMBuffer * _Nonnull buffer, AVAudioTime * _Nonnull when) {
        [self.recognitionRequest appendAudioPCMBuffer:buffer];
    }];
    
    [self.audioEngine prepare];
    [self.audioEngine startAndReturnError:nil];
    
    self.text = @"";
    dispatch_async(dispatch_get_main_queue(), ^{
        [self performSelector:@selector(finish) withObject:nil afterDelay:4];
    });
}

- (void) finish {
    [self stop];
    if(self.callback != nil) {
        self.callback(self.text);
    }
}

- (void) cancel {
    self.callback = nil;
    [self stop];
}
- (void) stop {
    if(self.audioEngine != nil && self.audioEngine.isRunning) {
        [self.audioEngine stop];
        
        dispatch_async(dispatch_get_main_queue(), ^{
            [self performSelector:@selector(playBeep) withObject:nil afterDelay:0.5f];
        });
    }
    
    if(self.recognitionRequest)
        [self.recognitionRequest endAudio];
    if(self.inputNode)
        [self.inputNode removeTapOnBus:0];
    
    self.inputNode = nil;
    self.recognitionTask = nil;
    self.recognitionRequest = nil;
    self.audioEngine = nil;
}
- (void)speechRecognitionDidDetectSpeech:(SFSpeechRecognitionTask *)task{
    NSLog(@"speechRecognitionDidDetectSpeech");
}

- (void)speechSynthesizer:(AVSpeechSynthesizer *)synthesizer didCancelSpeechUtterance:(AVSpeechUtterance *)utterance{
    
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
}

- (void)speechRecognitionTask:(SFSpeechRecognitionTask *)task didHypothesizeTranscription:(SFTranscription *)transcription{
    NSLog(@"didHypothesizeTranscription");
    self.text = [transcription formattedString];
    NSLog(@"%@", self.text);
}

@end
