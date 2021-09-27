//
//  WildCardVideoView.h
//  devilcore
//
//  Created by Mu Young Ko on 2021/04/16.
//

#import <Foundation/Foundation.h>
#import <AVFoundation/AVFoundation.h>
#import <AVKit/AVKit.h>
@import UIKit;

NS_ASSUME_NONNULL_BEGIN

@interface WildCardVideoView : UIView

-(void)setPreview:(NSString*)path video:(NSString*)path;
- (void)setPreview:(NSString*)ppath video:(NSString*)vpath force:(BOOL)force;

-(void)play;
+(void)autoPlay;
@property BOOL autoPlay;
@property (nonatomic, retain) AVPlayerViewController *playerViewController;
@property (nonatomic, retain) UIImageView* imageView;

@end

NS_ASSUME_NONNULL_END
