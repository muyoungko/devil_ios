//
//  DevilAVCamPhotoCaptureDelegate.m
//  devilcore
//
//  Created by Mu Young Ko on 2021/04/12.
//

#import "DevilAVCamPhotoCaptureDelegate.h"

#import <CoreImage/CoreImage.h>

@import Photos;

@interface DevilAVCamPhotoCaptureDelegate ()

@property (nonatomic, readwrite) AVCapturePhotoSettings* requestedPhotoSettings;
@property (nonatomic) void (^willCapturePhotoAnimation)(void);
@property (nonatomic) void (^livePhotoCaptureHandler)(BOOL capturing);
@property (nonatomic) void (^completionHandler)(DevilAVCamPhotoCaptureDelegate* photoCaptureDelegate);
@property (nonatomic) void (^photoProcessingHandler)(BOOL animate);

@property (nonatomic) NSURL* livePhotoCompanionMovieURL;
@property (nonatomic) NSData* portraitEffectsMatteData;
@property (nonatomic) NSMutableArray* semanticSegmentationMatteDataArray;
@property (nonatomic) CMTime maxPhotoProcessingTime;

@end

@implementation DevilAVCamPhotoCaptureDelegate

- (instancetype) initWithRequestedPhotoSettings:(AVCapturePhotoSettings*)requestedPhotoSettings willCapturePhotoAnimation:(void (^)(void))willCapturePhotoAnimation livePhotoCaptureHandler:(void (^)(BOOL))livePhotoCaptureHandler completionHandler:(void (^)(DevilAVCamPhotoCaptureDelegate*))completionHandler photoProcessingHandler:(void (^)(BOOL))photoProcessingHandler
{
    self = [super init];
    if ( self ) {
        self.requestedPhotoSettings = requestedPhotoSettings;
        self.willCapturePhotoAnimation = willCapturePhotoAnimation;
        self.livePhotoCaptureHandler = livePhotoCaptureHandler;
        self.completionHandler = completionHandler;
        self.semanticSegmentationMatteDataArray = [NSMutableArray array];
        self.photoProcessingHandler = photoProcessingHandler;
    }
    return self;
}

- (void) didFinish
{
    if ( [[NSFileManager defaultManager] fileExistsAtPath:self.livePhotoCompanionMovieURL.path] ) {
        NSError* error = nil;
        [[NSFileManager defaultManager] removeItemAtPath:self.livePhotoCompanionMovieURL.path error:&error];
        
        if ( error ) {
            NSLog( @"Could not remove file at url: %@", self.livePhotoCompanionMovieURL.path );
        }
    }
    
    self.completionHandler( self );
}

- (void) handleSemanticSegmentationMatte:(AVSemanticSegmentationMatteType)semanticSegmentationMatteType photo:(AVCapturePhoto *)photo
{
    CIImageOption imageOption = nil;
    if ( semanticSegmentationMatteType == AVSemanticSegmentationMatteTypeHair ) {
        imageOption = kCIImageAuxiliarySemanticSegmentationHairMatte;
    }
    else if ( semanticSegmentationMatteType == AVSemanticSegmentationMatteTypeSkin ) {
        imageOption = kCIImageAuxiliarySemanticSegmentationSkinMatte;
    }
    else if ( semanticSegmentationMatteType == AVSemanticSegmentationMatteTypeTeeth ) {
        imageOption = kCIImageAuxiliarySemanticSegmentationTeethMatte;
    }
    else {
        NSLog( @"%@ Matte type is not supported!",semanticSegmentationMatteType.description );
        return;
    }

    CGImagePropertyOrientation orientation = [[photo.metadata objectForKey:(NSString*)kCGImagePropertyOrientation] intValue];
    AVSemanticSegmentationMatte* semanticSegmentationMatte = [[photo semanticSegmentationMatteForType:semanticSegmentationMatteType] semanticSegmentationMatteByApplyingExifOrientation:orientation];
    if ( semanticSegmentationMatte == nil )
    {
        NSLog( @"No %@ in AVCapturePhoto.", semanticSegmentationMatteType.description );
        return;
    }
    CVPixelBufferRef semanticSegmentationMattePixelBuffer = [semanticSegmentationMatte mattingImage];
    CIImage* semanticSegmetationMatteImage = [CIImage imageWithCVPixelBuffer:semanticSegmentationMattePixelBuffer options:@{ imageOption : @(YES) }];
    CIContext* context = [CIContext context];
    CGColorSpaceRef linearColorSpace = CGColorSpaceCreateWithName( kCGColorSpaceLinearSRGB );
    NSData *semanticSegmentationData = [context HEIFRepresentationOfImage:semanticSegmetationMatteImage format:kCIFormatRGBA8 colorSpace:linearColorSpace options:@{ (id)kCIImageRepresentationPortraitEffectsMatteImage : semanticSegmetationMatteImage} ];
    [self.semanticSegmentationMatteDataArray addObject:semanticSegmentationData];
}

- (void) captureOutput:(AVCapturePhotoOutput*)captureOutput willBeginCaptureForResolvedSettings:(AVCaptureResolvedPhotoSettings*)resolvedSettings
{
    if ( ( resolvedSettings.livePhotoMovieDimensions.width > 0 ) && ( resolvedSettings.livePhotoMovieDimensions.height > 0 ) ) {
        self.livePhotoCaptureHandler( YES );
    }
    self.maxPhotoProcessingTime = CMTimeAdd( resolvedSettings.photoProcessingTimeRange.start, resolvedSettings.photoProcessingTimeRange.duration );
}

- (void) captureOutput:(AVCapturePhotoOutput*)captureOutput willCapturePhotoForResolvedSettings:(AVCaptureResolvedPhotoSettings*)resolvedSettings
{
    self.willCapturePhotoAnimation();

    // Show spinner if processing time exceeds 1 second
    CMTime onesec = CMTimeMake(1, 1);
    if ( CMTimeCompare(self.maxPhotoProcessingTime, onesec) > 0 ) {
        self.photoProcessingHandler( YES );
    }
}

- (void) captureOutput:(AVCapturePhotoOutput*)captureOutput didFinishProcessingPhoto:(AVCapturePhoto*)photo error:(nullable NSError*)error
{
    self.photoProcessingHandler( NO );
    
    if ( error != nil ) {
        NSLog( @"Error capturing photo: %@", error );
        return;
    }
    
    self.photoData = [photo fileDataRepresentation];
    
    // Portrait Effects Matte only gets generated if there is a face
    if ( photo.portraitEffectsMatte != nil ) {
        CGImagePropertyOrientation orientation = [[photo.metadata objectForKey:(NSString*)kCGImagePropertyOrientation] intValue];
        AVPortraitEffectsMatte* portraitEffectsMatte = [photo.portraitEffectsMatte portraitEffectsMatteByApplyingExifOrientation:orientation];
        CVPixelBufferRef portraitEffectsMattePixelBuffer = [portraitEffectsMatte mattingImage];
        CIImage* portraitEffectsMatteImage = [CIImage imageWithCVPixelBuffer:portraitEffectsMattePixelBuffer options:@{ kCIImageAuxiliaryPortraitEffectsMatte : @(YES) }];
        CIContext* context = [CIContext context];
        CGColorSpaceRef linearColorSpace = CGColorSpaceCreateWithName( kCGColorSpaceLinearSRGB );
        self.portraitEffectsMatteData = [context HEIFRepresentationOfImage:portraitEffectsMatteImage format:kCIFormatRGBA8 colorSpace:linearColorSpace options:@{ (id)kCIImageRepresentationPortraitEffectsMatteImage : portraitEffectsMatteImage} ];
    }
    else {
        self.portraitEffectsMatteData = nil;
    }
    
    for ( AVSemanticSegmentationMatteType type in captureOutput.enabledSemanticSegmentationMatteTypes ) {
        [self handleSemanticSegmentationMatte:type photo:photo];
    }
}

- (void) captureOutput:(AVCapturePhotoOutput*)captureOutput didFinishRecordingLivePhotoMovieForEventualFileAtURL:(NSURL*)outputFileURL resolvedSettings:(AVCaptureResolvedPhotoSettings*)resolvedSettings
{
    self.livePhotoCaptureHandler(NO);
}

- (void) captureOutput:(AVCapturePhotoOutput*)captureOutput didFinishProcessingLivePhotoToMovieFileAtURL:(NSURL*)outputFileURL duration:(CMTime)duration photoDisplayTime:(CMTime)photoDisplayTime resolvedSettings:(AVCaptureResolvedPhotoSettings*)resolvedSettings error:(NSError*)error
{
    if ( error != nil ) {
        NSLog( @"Error processing Live Photo companion movie: %@", error );
        return;
    }
    
    self.livePhotoCompanionMovieURL = outputFileURL;
}

- (void) captureOutput:(AVCapturePhotoOutput*)captureOutput didFinishCaptureForResolvedSettings:(AVCaptureResolvedPhotoSettings*)resolvedSettings error:(NSError*)error
{
    if ( error != nil ) {
        NSLog( @"Error capturing photo: %@", error );
        [self didFinish];
        return;
    }
    
    if ( self.photoData == nil ) {
        NSLog( @"No photo data resource" );
        [self didFinish];
        return;
    }

    
    [self didFinish];
    
}


@end
