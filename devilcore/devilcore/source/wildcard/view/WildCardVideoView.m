//
//  WildCardVideoView.m
//  devilcore
//
//  Created by Mu Young Ko on 2021/04/16.
//

#import "WildCardVideoView.h"

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
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(didStartPlaying) name:AVPlayerItemDidPlayToEndTimeNotification object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(didFinishPlaying) name:AVPlayerItemDidPlayToEndTimeNotification object:nil];
    
    _imageView = [[UIImageView alloc] initWithFrame:CGRectMake(0, 0, frame.size.width, frame.size.height)];
    self.imageView.contentMode = UIViewContentModeScaleAspectFill;
    self.imageView.clipsToBounds = YES;
    self.imageView.hidden = YES;
    [self addSubview:_imageView];
    
    return self;
}

- (void)setPreview:(NSString*)ppath video:(NSString*)vpath{
    _playerViewController.player = nil;
    _playerViewController.player = [AVPlayer playerWithURL:[NSURL fileURLWithPath:vpath]];
    
    self.previewPath = ppath;
    self.videoPath = vpath;
    NSData *imageData = [NSData dataWithContentsOfURL:[NSURL fileURLWithPath:ppath]];
    UIImage *image = [UIImage imageWithData:imageData];
    [self.imageView setImage:image];
    
    _playerViewController.player = [AVPlayer playerWithURL:[NSURL fileURLWithPath:vpath]];

}

-(void)didStartPlaying{
    NSLog(@"didStartPlaying");
}
-(void)didFinishPlaying{
    NSLog(@"didFinishPlaying");
}

-(void)play{
    [_playerViewController.player play];
}

-(void)stop{
    [_playerViewController.player pause];
}

@end
