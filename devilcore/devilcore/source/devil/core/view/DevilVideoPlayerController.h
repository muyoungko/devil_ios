//
//  DevilVideoPlayerController.h
//  devilcore
//
//  Created by Mu Young Ko on 2023/08/08.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

@protocol DevilVideoPlayerControllerDelegate<NSObject>
    
@required
- (void)onSeek:(int)time_sec;
@end

@interface DevilVideoPlayerController : UIView

@property (nonatomic, weak) id<DevilVideoPlayerControllerDelegate> delegate;
@property (nonatomic, weak) UIView* fullScreenView;
@property (nonatomic, weak) UIView* zoomView;

-(void)setTime:(int)current :(int)duration;
-(void)finished;

@end

NS_ASSUME_NONNULL_END
