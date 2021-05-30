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

- (void)setPreview:(NSString*)ppath video:(NSString*)vpath{
    NSLog(@"ppath - %@", ppath);
    _playerViewController.player = nil;
    if(vpath != nil) {
        _playerViewController.player = [AVPlayer playerWithURL:[NSURL fileURLWithPath:vpath]];
        _playerViewController.view.hidden = NO;
        [_playerViewController.player play];
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
    if(_playerViewController.player != nil)
        [_playerViewController.player play];
}

-(void)stop{
    self.imageView.hidden = NO;
    if(_playerViewController.player != nil)
        [_playerViewController.player pause];
}

@end
