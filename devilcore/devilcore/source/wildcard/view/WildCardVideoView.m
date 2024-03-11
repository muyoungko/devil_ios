//
//  WildCardVideoView.m
//  devilcore
//
//  Created by Mu Young Ko on 2021/04/16.
//

#import "WildCardVideoView.h"
#import "WildCardConstructor.h"
#import "Lottie.h"
#import <objc/runtime.h>
#import <QuartzCore/QuartzCore.h>
#import "DevilUtil.h"
#import "DevilVideoPlayerController.h"

@interface WildCardVideoView() <AVPlayerViewControllerDelegate, DevilVideoPlayerControllerDelegate>
@property (nonatomic, retain) NSString* previewPath;
@property (nonatomic, retain) NSString* videoPath;
@property (nonatomic, retain) NSString* lastPlayingVideoPath;
@property (nonatomic, retain) LOTAnimationView* playPause;
@property (nonatomic, retain) UIActivityIndicatorView* loading;
@property (nonatomic, retain) id observer;
@property BOOL ready;
@property BOOL playing;

@property (nonatomic, retain) DevilVideoPlayerController* controler;
@property (nonatomic, copy) void (^readyCallback)(id);

@end

@implementation WildCardVideoView


- (instancetype)initWithFrame:(CGRect)frame{
    self = [super initWithFrame:frame];
    
    _playerViewController = [[AVPlayerViewController alloc] init];
    _playerViewController.view.frame = CGRectMake(0, 0, frame.size.width, frame.size.height);
    _playerViewController.showsPlaybackControls = NO;
    _playerViewController.delegate = self;
    _playerViewController.player.automaticallyWaitsToMinimizeStalling = NO;
    [_playerViewController.player addObserver:self forKeyPath:@"status" options:0 context:nil];
    
    [self addSubview:_playerViewController.view];
    
    _imageView = (UIImageView*)[[WildCardConstructor sharedInstance].delegate getNetworkImageViewInstnace];
    self.imageView.clipsToBounds = YES;
    self.imageView.hidden = YES;
    [self addSubview:_imageView];
    [WildCardConstructor followSizeFromFather:self child:self.imageView];
    
    
    self.loading = [[UIActivityIndicatorView alloc] initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleWhite];
    [self addSubview:_loading];
    [WildCardConstructor followSizeFromFather:self child:_loading];
    [_loading startAnimating];
    _loading.hidden = YES;
    
    
    NSBundle *bundle = [NSBundle bundleForClass:[self class]];
    LOTAnimationView* loading = [LOTAnimationView animationNamed:@"play_pause" inBundle:bundle];
    int w = 240;
    int h = 170;
    loading.frame = CGRectMake( (frame.size.width-w)/2, (frame.size.height-h)/2 , w, h);
    loading.userInteractionEnabled = NO;
    loading.tag = 5123;
    loading.loopAnimation = NO;
    loading.alpha = 0.5;
    loading.hidden = YES;
    [self addSubview:loading];
    self.playPause = loading;
    
    self.userInteractionEnabled = YES;
    
    
    loading.translatesAutoresizingMaskIntoConstraints = NO;
    // loading 뷰의 가로 너비 제약 (고정된 값)
    NSLayoutConstraint *widthConstraint = [NSLayoutConstraint constraintWithItem:loading
                                                                       attribute:NSLayoutAttributeWidth
                                                                       relatedBy:NSLayoutRelationEqual
                                                                          toItem:nil
                                                                       attribute:NSLayoutAttributeNotAnAttribute
                                                                      multiplier:1.0
                                                                        constant:240.0];
    
    // 가로 방향 가운데 정렬을 위한 제약 추가
    NSLayoutConstraint *centerXConstraint = [NSLayoutConstraint constraintWithItem:loading
                                                                         attribute:NSLayoutAttributeCenterX
                                                                         relatedBy:NSLayoutRelationEqual
                                                                            toItem:self
                                                                         attribute:NSLayoutAttributeCenterX
                                                                        multiplier:1.0
                                                                          constant:0.0];

    // loading 뷰의 세로 너비 제약 (고정된 값)
    NSLayoutConstraint *heightConstraint = [NSLayoutConstraint constraintWithItem:loading
                                                                       attribute:NSLayoutAttributeHeight
                                                                       relatedBy:NSLayoutRelationEqual
                                                                          toItem:nil
                                                                       attribute:NSLayoutAttributeNotAnAttribute
                                                                      multiplier:1.0
                                                                        constant:170.0];
    
    // 세로 방향 가운데 정렬을 위한 제약 추가
    NSLayoutConstraint *centerYConstraint = [NSLayoutConstraint constraintWithItem:loading
                                                                         attribute:NSLayoutAttributeCenterY
                                                                         relatedBy:NSLayoutRelationEqual
                                                                            toItem:self
                                                                         attribute:NSLayoutAttributeCenterY
                                                                        multiplier:1.0
                                                                          constant:0.0];
    
    // 위에서 생성한 두 제약을 활성화
    [NSLayoutConstraint activateConstraints:@[widthConstraint, centerXConstraint, heightConstraint, centerYConstraint]];
    
    
    UITapGestureRecognizer* singleFingerTap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(onClickVideoView:)];
    [self addGestureRecognizer:singleFingerTap];
    
    
    _ready = NO;
    _playing = NO;
    
    self.clipsToBounds = TRUE;
    
    return self;
}


-(BOOL)pointInside:(CGPoint)point withEvent:(UIEvent *)event {
    for (UIView *view in self.subviews) {
        if (!view.hidden && view.userInteractionEnabled && [view pointInside:[self convertPoint:point toView:view] withEvent:event])
            return YES;
    }
    return NO;
}

-(BOOL) isFinished {
    if(_videoPath == nil || _playerViewController.player == nil)
        return NO;
    
    CMTime currentTime = [_playerViewController.player.currentItem currentTime];
    CMTime endTime = [_playerViewController.player.currentItem duration];
    if(CMTIME_COMPARE_INLINE(currentTime, ==, endTime)) {
        return YES;
    }
    
    return NO;
}

-(void)onClickVideoView:(id)sender {
    if(self.videoPath != nil) {
        if([self isFinished]) {
            [_playerViewController.player seekToTime:CMTimeMake(0, 1)];
            [_playerViewController.player play];
            self.imageView.hidden = YES;
            [self blinkPlay];
            [self tick];
        } else {
            if(self.playerViewController.player.timeControlStatus == AVPlayerTimeControlStatusPlaying) {
                [self stop];
                [self blinkPause];
            } else {
                [self play];
                [self blinkPlay];
            }
        }
    }
}

-(void)blinkPlay {
    [self.playPause stop];
    self.playPause.hidden = NO;
    [self.playPause playFromFrame:[NSNumber numberWithInt:30] toFrame:[NSNumber numberWithInt:60] withCompletion:^(BOOL animationFinished) {
        self.playPause.hidden = YES;
    }];
}

-(void)blinkPause {
    [self.playPause stop];
    self.playPause.hidden = NO;
    [self.playPause playFromFrame:[NSNumber numberWithInt:0] toFrame:[NSNumber numberWithInt:30] withCompletion:^(BOOL animationFinished) {
        self.playPause.hidden = YES;
    }];
}

+ (id)sharedMap {
    static id sharedInstance = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        sharedInstance = [@{} mutableCopy];
    });
    return sharedInstance;
}

+(void)registView:(WildCardVideoView*)v {
    NSString* key = [NSString stringWithFormat:@"%@", v];
    key = [key componentsSeparatedByString:@" "][1];
    [WildCardVideoView sharedMap][key] = v;
}

+(void)unregistView:(WildCardVideoView*)v {
    NSString* key = [NSString stringWithFormat:@"%@", v];
    key = [key componentsSeparatedByString:@" "][1];
    if(v)
       [v stop];
    [[WildCardVideoView sharedMap] removeObjectForKey:key];
}

+(void)autoPlay {
    id m = [WildCardVideoView sharedMap];
    id d = [m allKeys];
    CGRect s = [[UIScreen mainScreen] bounds];
    int sw = s.size.width;
    int sh = s.size.height;
    int fy = (sh - sw)/3;
    int ty = (sh + sw)/2;
    int fx = 0;
    int tx = sw;
    NSString* activeKey = nil;
    for(id k in d) {
        WildCardVideoView* v = m[k];
        if(v.autoPlay && v.videoPath != nil){
            CGRect r = [v.superview convertRect:v.frame toView:nil];
            int x = r.origin.x + r.size.width/2;
            int y = r.origin.y + r.size.height/2;
            if(fx < x & x < tx && fy < y & y < ty) {
                [v play];
                activeKey = k;
                break;
            }
        }
    }
    
    for(id k in d) {
        WildCardVideoView* v = m[k];
        if(![k isEqualToString:activeKey])
            [v stop];
    }
}

- (void)didMoveToWindow {
    if (self.window == nil) {
        [WildCardVideoView unregistView:self];
    }
}
- (void)setPreview:(NSString*)ppath video:(NSString*)vpath {
    [self setPreview:ppath video:vpath force:NO];
}

- (void)setPreview:(NSString*)ppath video:(NSString*)vpath force:(BOOL)force{
    
    if(self.centerInside) {
        _playerViewController.videoGravity = AVLayerVideoGravityResizeAspect;
        self.imageView.contentMode = UIViewContentModeScaleAspectFit;
    } else {
        _playerViewController.videoGravity = AVLayerVideoGravityResizeAspectFill;
        self.imageView.contentMode = UIViewContentModeScaleAspectFill;
    }
    
    if(vpath == nil) {
        if(_playerViewController != nil)
            [_playerViewController.player pause];
        _playerViewController.view.hidden = YES;
        _playerViewController.player = nil;
    }
    
    if(ppath && [ppath hasPrefix:@"http"]) {
        if(![ppath isEqualToString:self.previewPath]) {
            [[WildCardConstructor sharedInstance].delegate loadNetworkImageView:self.imageView withUrl:ppath];
            self.imageView.hidden = NO;
        }
    } else if(ppath) {
        NSData *imageData = [NSData dataWithContentsOfURL:[NSURL fileURLWithPath:ppath]];
        UIImage *image = [UIImage imageWithData:imageData];
        [self.imageView setImage:image];
    }
    
    if(self.autoPlay)
        [WildCardVideoView registView:self];
    else
        [WildCardVideoView unregistView:self];
    
    self.previewPath = ppath;
    self.videoPath = [DevilUtil replaceUdidPrefixDir:vpath];
}

- (void)observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object
                        change:(NSDictionary *)change context:(void *)context {
    AVPlayer* player = _playerViewController.player;
    if ([keyPath isEqualToString:@"status"]) {
        if (player.status == AVPlayerStatusReadyToPlay) {
            NSLog(@"Ready to Play");
            _ready = YES;
            if(_playing)
                [self play];
            
            if(self.readyCallback) {
                self.readyCallback(@{});
                self.readyCallback = nil;
            }
        } else if (player.status == AVPlayerStatusFailed) {
            NSLog(@"Fail to Ready");
        } else {
            
        }
    } else {
        NSLog(@"Previous observeValueForKeyPath %@", keyPath );
    }
}

-(void)didFinishPlaying{
    NSLog(@"didFinishPlaying");
    self.playing = NO;
    self.imageView.hidden = NO;
    if(_controler) {
        [_controler finished];
    }
}

-(void)onPrepared {
    _loading.hidden = YES;
    self.imageView.hidden = YES;
}

-(void)onPreparedTimerStart {
    
    if(self.observer != nil) {
        @try {
            [self.playerViewController.player removeTimeObserver:self.observer];
        }@catch(NSException* e) {
        }
        
        self.observer = nil;
    }
    
    self.observer = [self.playerViewController.player addPeriodicTimeObserverForInterval:CMTimeMake(1, 4)
        queue:NULL // main queue
        usingBlock:^(CMTime time) {

        
        CMTime currentPosition = self.playerViewController.player.currentItem.currentTime;
        float currentPositionSec = ((float)currentPosition.value / currentPosition.timescale);
        if(currentPositionSec > 0) {
            [self.playerViewController.player removeTimeObserver:self.observer];
            [self onPrepared];
        }
    }];
    
}

-(void)play{
    NSLog(@"play %@", self.videoPath);
    _playing = YES;
    //self.videoPath = @"https://file-examples-com.github.io/uploads/2017/04/file_example_MP4_640_3MG.mp4";
    if(self.videoPath == nil || ![self.videoPath isEqualToString:self.lastPlayingVideoPath]){
        
        _loading.hidden = NO;
        if([self.videoPath hasPrefix:@"http"])
            _playerViewController.player = [AVPlayer playerWithURL:[NSURL URLWithString:self.videoPath]];
        else
            _playerViewController.player = [AVPlayer playerWithURL:[NSURL fileURLWithPath:self.videoPath]];
        
        self.lastPlayingVideoPath = self.videoPath;
        
        [self onPreparedTimerStart];
        
        _ready = NO;
        
        if(_playerViewController.player != nil) {
            _playerViewController.view.hidden = NO;
            
            if([self isFinished]){
                [_playerViewController.player seekToTime:CMTimeMakeWithSeconds(0, 6000)];
            }
            [_playerViewController.player play];
        }
        
        [[AVAudioSession sharedInstance] setCategory: AVAudioSessionCategoryPlayback error: nil];
        
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(didFinishPlaying) name:AVPlayerItemDidPlayToEndTimeNotification object:nil];
    } else {
        if(_playerViewController.player.timeControlStatus == AVPlayerTimeControlStatusPaused) {
            if([self isFinished]) {
                [_playerViewController.player seekToTime:CMTimeMake(0, 1)];
                [_playerViewController.player play];
            } else {
                [_playerViewController.player play];
            }
            self.imageView.hidden = YES;
        }
    }
    
    [self tick];
}

-(void)stop{
    [[NSNotificationCenter defaultCenter] removeObserver:self];
    
    _playing = NO;
    if(_playerViewController.player != nil)
        [_playerViewController.player pause];
}

-(BOOL)isPlaying {
    return _playing;
}


-(void)constructController {
    self.controler = [[DevilVideoPlayerController alloc] initWithFrame:CGRectMake(0, 0, 0, 0)];
    [self addSubview:self.controler];
    _controler.fullScreenView = self;
    _controler.zoomView = _playerViewController.view;
    _controler.delegate = self;
    [WildCardConstructor followSizeFromFather:self child:_controler];
}

- (void)onSeek:(int)time_sec{
    [_playerViewController.player seekToTime:CMTimeMake(time_sec, 1)];
    if(!_playing)
        [self play];
}


- (void)tick {
    if(_playing && _controler){
        CMTime currentTime = [_playerViewController.player.currentItem currentTime];
        CMTime endTime = [_playerViewController.player.currentItem duration];
        
        int seconds = (int)CMTimeGetSeconds(currentTime);
        int duration = (int)CMTimeGetSeconds(endTime);
        [_controler setTime:seconds :duration];
        
        [self performSelector:@selector(tick) withObject:nil afterDelay:1];
    }
}

-(void)callback:(NSString*)command callback:(void (^)(id))callback {
    self.readyCallback = callback;
}
@end
