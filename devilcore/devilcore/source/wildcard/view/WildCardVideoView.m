//
//  WildCardVideoView.m
//  devilcore
//
//  Created by Mu Young Ko on 2021/04/16.
//

#import "WildCardVideoView.h"
#import "WildCardConstructor.h"
#import "Lottie.h"

@interface WildCardVideoView() <AVPlayerViewControllerDelegate>
@property (nonatomic, retain) NSString* previewPath;
@property (nonatomic, retain) NSString* videoPath;
@property (nonatomic, retain) NSString* lastPlayingVideoPath;
@property (nonatomic, retain) LOTAnimationView* playPause;
@property BOOL ready;
@property BOOL playing;
@property BOOL finished;
@end

@implementation WildCardVideoView


- (instancetype)initWithFrame:(CGRect)frame{
    self = [super initWithFrame:frame];
    
    _playerViewController = [[AVPlayerViewController alloc] init];
    _playerViewController.view.frame = CGRectMake(0, 0, frame.size.width, frame.size.height);
    _playerViewController.showsPlaybackControls = NO;
    _playerViewController.delegate = self;
    _playerViewController.videoGravity = AVLayerVideoGravityResizeAspectFill;
    [self addSubview:_playerViewController.view];
    
    _imageView = (UIImageView*)[[WildCardConstructor sharedInstance].delegate getNetworkImageViewInstnace];
    self.imageView.contentMode = UIViewContentModeScaleAspectFill;
    self.imageView.clipsToBounds = YES;
    self.imageView.hidden = YES;
    [self addSubview:_imageView];
    [WildCardConstructor followSizeFromFather:self child:self.imageView];
    
    
    CGRect s = [[UIScreen mainScreen] bounds];
    int sw = s.size.width;
    
    NSBundle *bundle = [NSBundle bundleForClass:[self class]];
    LOTAnimationView* loading = [LOTAnimationView animationNamed:@"play_pause" inBundle:bundle];
    int w = 240;
    int h = 170;
    loading.frame = CGRectMake( (sw-w)/2, (sw-h)/2 , w, h);
    loading.userInteractionEnabled = NO;
    loading.tag = 5123;
    loading.loopAnimation = NO;
    loading.alpha = 0.5;
    loading.hidden = YES;
    [self addSubview:loading];
    self.playPause = loading;
    
    self.userInteractionEnabled = YES;
    
    UITapGestureRecognizer* singleFingerTap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(onClickVideoView:)];
    [self addGestureRecognizer:singleFingerTap];
    
    _ready = NO;
    _playing = NO;
    _finished = NO;
    
    return self;
}

-(void)onClickVideoView:(id)sender {
    if(self.videoPath != nil) {
        if(self.playerViewController.player.timeControlStatus == AVPlayerTimeControlStatusPlaying) {
            [self stop];
            [self blinkPause];
        } else {
            [self play];
            [self blinkPlay];
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
    _playerViewController.player = nil;
    if(vpath == nil) {
        [_playerViewController.player pause];
        _playerViewController.view.hidden = YES;
    }
    
    if(ppath != nil)
        self.imageView.hidden = NO;
    
    self.previewPath = ppath;
    self.videoPath = vpath;
    
    if([ppath hasPrefix:@"http"]) {
        [[WildCardConstructor sharedInstance].delegate loadNetworkImageView:self.imageView withUrl:ppath];
    } else {
        NSData *imageData = [NSData dataWithContentsOfURL:[NSURL fileURLWithPath:ppath]];
        UIImage *image = [UIImage imageWithData:imageData];
        [self.imageView setImage:image];
    }
    
    if(self.autoPlay)
        [WildCardVideoView registView:self];
    else
        [WildCardVideoView unregistView:self];
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
    self.finished = YES;
    self.playing = NO;
    self.imageView.hidden = NO;
}

-(void)play{
    NSLog(@"play %@", self.videoPath);
    
    _playing = YES;
    
    if(self.videoPath == nil || ![self.videoPath isEqualToString:self.lastPlayingVideoPath]){
        if(_playerViewController.player){
            NSLog(@"Remove Observer");
            [_playerViewController.player removeObserver:self forKeyPath:@"status"];
        }
        _playerViewController.player = [AVPlayer playerWithURL:[NSURL fileURLWithPath:self.videoPath]];
        self.lastPlayingVideoPath = self.videoPath;
        [_playerViewController.player addObserver:self forKeyPath:@"status" options:0 context:nil];
        _ready = NO;
        NSLog(@"Player Init");
    } else {
        NSLog(@"Player Init Pass");
    }
    
    if(!_ready) {
        NSLog(@"play returned");
        //return;
    }
    
    NSLog(@"play ing");
    self.imageView.hidden = YES;
    if(_playerViewController.player != nil) {
        _playerViewController.view.hidden = NO;
        
        if(self.finished){
            [_playerViewController.player seekToTime:CMTimeMakeWithSeconds(0, 6000)];
        }
        self.finished = NO;
        [_playerViewController.player play];
    }
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(didFinishPlaying) name:AVPlayerItemDidPlayToEndTimeNotification object:nil];
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

@end
