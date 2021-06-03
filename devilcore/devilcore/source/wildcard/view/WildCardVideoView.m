//
//  WildCardVideoView.m
//  devilcore
//
//  Created by Mu Young Ko on 2021/04/16.
//

#import "WildCardVideoView.h"
#import "WildCardConstructor.h"

@interface WildCardVideoView() <AVPlayerViewControllerDelegate>
@property (nonatomic, retain) NSString* previewPath;
@property (nonatomic, retain) NSString* videoPath;
@property (nonatomic, retain) UIImageView* imageView;
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
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(didFinishPlaying) name:AVPlayerItemDidPlayToEndTimeNotification object:nil];
    
    _imageView = (UIImageView*)[[WildCardConstructor sharedInstance].delegate getNetworkImageViewInstnace];
    self.imageView.contentMode = UIViewContentModeScaleAspectFill;
    self.imageView.clipsToBounds = YES;
    self.imageView.hidden = YES;
    [self addSubview:_imageView];
    [WildCardConstructor followSizeFromFather:self child:self.imageView];
    
    return self;
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
    int fy = (sh - sw)/2;
    int ty = (sh + sw)/2;
    NSString* activeKey = nil;
    for(id k in d) {
        WildCardVideoView* v = m[k];
        if(v.autoPlay && v.videoPath != nil){
            CGRect r = [v.superview convertRect:v.frame toView:nil];
            int y = r.origin.y + r.size.height/2;
            if(fy < y & y < ty) {
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

- (void)setPreview:(NSString*)ppath video:(NSString*)vpath{
    NSLog(@"ppath - %@", ppath);
    _playerViewController.player = nil;
    if(vpath != nil) {
        _playerViewController.player = [AVPlayer playerWithURL:[NSURL fileURLWithPath:vpath]];
        if(self.autoPlay){
            [WildCardVideoView registView:self];
        }
            
    } else {
        _playerViewController.view.hidden = YES;
        self.imageView.hidden = NO;
    }
    
    self.previewPath = ppath;
    self.videoPath = vpath;
    
    if([ppath hasPrefix:@"http"]) {
        [[WildCardConstructor sharedInstance].delegate loadNetworkImageView:self.imageView withUrl:ppath];
    } else {
        NSData *imageData = [NSData dataWithContentsOfURL:[NSURL fileURLWithPath:ppath]];
        UIImage *image = [UIImage imageWithData:imageData];
        [self.imageView setImage:image];
    }
}

-(void)didFinishPlaying{
    NSLog(@"didFinishPlaying");
}

-(void)play{
    self.imageView.hidden = YES;
    if(_playerViewController.player != nil) {
        _playerViewController.view.hidden = NO;
        [_playerViewController.player play];
    }
}

-(void)stop{
    self.imageView.hidden = NO;
    if(_playerViewController.player != nil)
        [_playerViewController.player pause];
}

@end
