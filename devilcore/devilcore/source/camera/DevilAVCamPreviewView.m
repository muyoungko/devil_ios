//
//  DevilAVCamPreviewView.m
//  devilcore
//
//  Created by Mu Young Ko on 2021/04/11.
//
@import AVFoundation;

#import "DevilAVCamPreviewView.h"

@implementation DevilAVCamPreviewView

+ (Class)layerClass
{
    return [AVCaptureVideoPreviewLayer class];
}

- (AVCaptureVideoPreviewLayer*) videoPreviewLayer
{
    return (AVCaptureVideoPreviewLayer *)self.layer;
}

- (AVCaptureSession*) session
{
    return self.videoPreviewLayer.session;
}

- (void)setSession:(AVCaptureSession*) session
{
    self.videoPreviewLayer.session = session;
}

@end
