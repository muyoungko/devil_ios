//
//  ReplaceRuleVideo.m
//  devilcore
//
//  Created by Mu Young Ko on 2021/04/19.
//

#import "ReplaceRuleVideo.h"
#import "WildCardVideoView.h"
#import "WildCardConstructor.h"
#import "MappingSyntaxInterpreter.h"

@implementation ReplaceRuleVideo

- (void)constructRule:(WildCardMeta *)wcMeta parent:(UIView *)parent vv:(WildCardUIView *)vv layer:(id)layer depth:(int)depth result:(id)result{
    WildCardVideoView* videoView = [[WildCardVideoView alloc] initWithFrame:CGRectMake(0,0,0,0)];
    self.replaceView = videoView;
    if(vv.layer.cornerRadius > 0) {
        videoView.playerViewController.view.layer.cornerRadius = videoView.imageView.layer.cornerRadius = videoView.layer.cornerRadius = vv.layer.cornerRadius;
        videoView.playerViewController.view.layer.masksToBounds = true;
    }
    
    [vv addSubview:videoView];
    [WildCardConstructor followSizeFromFather:vv child:videoView];
}

- (void)updateRule:(WildCardMeta *)meta data:(id)opt{
    id video = self.replaceJsonLayer;
    NSString* videoUrlJsonPath = video[@"videoUrl"];
    NSString* previewUrlJsonPath = video[@"previewUrl"];
    NSString* autoPlay = video[@"autoPlay"];
    NSString* previewUrl = [MappingSyntaxInterpreter interpret:previewUrlJsonPath :opt];
    NSString* videoUrl = [MappingSyntaxInterpreter interpret:videoUrlJsonPath :opt];
    
    WildCardVideoView* videoView = (WildCardVideoView*)self.replaceView;
    videoView.centerInside = [@"center_inside" isEqualToString:video[@"scaleType"]];
    [videoView setAutoPlay:[@"Y" isEqualToString:autoPlay]];
    [videoView setPreview:previewUrl video:videoUrl];
    if(videoUrl) {
        [videoView superview].userInteractionEnabled = YES;
    }
}

@end
