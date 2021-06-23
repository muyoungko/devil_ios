//
//  DevilCameraController.m
//  devilcore
//
//  Created by Mu Young Ko on 2021/04/11.
//

#import "DevilCameraController.h"
#import "DevilAVCamPreviewView.h"
#import "DevilAVCamPhotoCaptureDelegate.h"
#import "DevilUtil.h"
#import "PECropView.h"
#import "WildCardVideoView.h"

#import <MobileCoreServices/UTCoreTypes.h>

@import AVFoundation;
@import Photos;

static void*  SessionRunningContext = &SessionRunningContext;
static void*  SystemPressureContext = &SystemPressureContext;

typedef NS_ENUM(NSInteger, AVCamSetupResult) {
    AVCamSetupResultSuccess,
    AVCamSetupResultCameraNotAuthorized,
    AVCamSetupResultSessionConfigurationFailed
};

typedef NS_ENUM(NSInteger, AVCamCaptureMode) {
    AVCamCaptureModePhoto = 0,
    AVCamCaptureModeMovie = 1
};

typedef NS_ENUM(NSInteger, AVCamLivePhotoMode) {
    AVCamLivePhotoModeOn,
    AVCamLivePhotoModeOff
};

typedef NS_ENUM(NSInteger, AVCamDepthDataDeliveryMode) {
    AVCamDepthDataDeliveryModeOn,
    AVCamDepthDataDeliveryModeOff
};

typedef NS_ENUM(NSInteger, AVCamPortraitEffectsMatteDeliveryMode) {
    AVCamPortraitEffectsMatteDeliveryModeOn,
    AVCamPortraitEffectsMatteDeliveryModeOff
};

typedef NS_ENUM(NSInteger, UIMode) {
    UIModePicture,
    UIModeTaken,
    UIModeRecord,
    UIModeRecording,
    UIModeRecorded
};

@interface AVCaptureDeviceDiscoverySession (Utilities)

- (NSInteger)uniqueDevicePositionsCount;

@end

@implementation AVCaptureDeviceDiscoverySession (Utilities)

- (NSInteger)uniqueDevicePositionsCount
{
    NSMutableArray<NSNumber* >* uniqueDevicePositions = [NSMutableArray array];
    
    for (AVCaptureDevice* device in self.devices) {
        if (![uniqueDevicePositions containsObject:@(device.position)]) {
            [uniqueDevicePositions addObject:@(device.position)];
        }
    }
    
    return uniqueDevicePositions.count;
}

@end


@interface DevilCameraController ()<AVCaptureFileOutputRecordingDelegate, UIImagePickerControllerDelegate>

@property (nonatomic) BOOL front;
@property (nonatomic) BOOL flash;
@property (nonatomic) BOOL video;

@property (nonatomic) NSString* targetImagePath;
@property (nonatomic) NSString* targetPreviewPath;
@property (nonatomic) NSString* targetVideoPathMov;
@property (nonatomic) NSString* targetVideoPathMovCopy;
@property (nonatomic) NSString* targetVideoPathMp4;

@property (nonatomic) BOOL startVideo;
@property (nonatomic) BOOL startFront;
@property (nonatomic) BOOL startFlash;
@property (nonatomic) BOOL hasPicture;
@property (nonatomic) BOOL hasVideo;
@property (nonatomic) BOOL hasGallery;
@property (nonatomic) int minSec;
@property (nonatomic) int maxSec;
@property (nonatomic) float ratio;

@property (nonatomic) UIMode uiMode;
@property (nonatomic, retain) UILabel* topTitle;
@property (nonatomic) int recordSec;
@property (nonatomic, retain) UIButton* btnBack;
@property (nonatomic, retain) UIButton* btnFlash;
@property (nonatomic, retain) UIButton* btnFront;
@property (nonatomic, retain) UIButton* btnVideo;
@property (nonatomic, retain) UIButton* btnPicture;
@property (nonatomic, retain) UIButton* btnGallery;
@property (nonatomic, retain) UIButton* btnTake;
@property (nonatomic, retain) UIButton* btnRecordStart;
@property (nonatomic, retain) UIButton* btnRecordStop;
@property (nonatomic, retain) UIButton* btnBack1;
@property (nonatomic, retain) UIButton* btnComplete1;
@property (nonatomic, retain) UIButton* btnBack2;
@property (nonatomic, retain) UIButton* btnComplete2;
@property (nonatomic, retain) UIView* capTop;
@property (nonatomic, retain) UIView* capBottom;
@property (nonatomic, retain) UIView* takenLayer;
@property (nonatomic, retain) UIImageView* takenImageView;
@property (nonatomic, retain) PECropView* cropView;
@property (nonatomic, retain) UIView* recordLayer;
@property (nonatomic, retain) WildCardVideoView* videoView;

@property (nonatomic, retain) DevilAVCamPreviewView* previewView;
@property (nonatomic) AVCamSetupResult setupResult;

@property (nonatomic) dispatch_queue_t sessionQueue;
@property (nonatomic) AVCaptureSession* session;
@property (nonatomic, getter=isSessionRunning) BOOL sessionRunning;
@property (nonatomic) AVCaptureDeviceInput* videoDeviceInput;

@property (nonatomic) AVCaptureDeviceDiscoverySession* videoDeviceDiscoverySession;

// Capturing photos.
@property (nonatomic) AVCamLivePhotoMode livePhotoMode;
@property (nonatomic) AVCamDepthDataDeliveryMode depthDataDeliveryMode;
@property (nonatomic) AVCamPortraitEffectsMatteDeliveryMode portraitEffectsMatteDeliveryMode;
@property (nonatomic) AVCapturePhotoQualityPrioritization photoQualityPrioritizationMode;

@property (nonatomic) AVCapturePhotoOutput* photoOutput;
@property (nonatomic) NSArray<AVSemanticSegmentationMatteType>* selectedSemanticSegmentationMatteTypes;
@property (nonatomic) NSMutableDictionary<NSNumber* , DevilAVCamPhotoCaptureDelegate* >* inProgressPhotoCaptureDelegates;
@property (nonatomic) NSInteger inProgressLivePhotoCapturesCount;

@property (nonatomic, strong) AVCaptureMovieFileOutput* movieFileOutput;
@property (nonatomic) UIBackgroundTaskIdentifier backgroundRecordingID;

@property (nonatomic, retain) UIActivityIndicatorView *spinner;
@end

@implementation DevilCameraController


- (void)viewDidLoad {
    [super viewDidLoad];
    self.view.backgroundColor = [UIColor blackColor];
    NSString* outputFileName = [NSUUID UUID].UUIDString;
    
    self.targetPreviewPath = [NSTemporaryDirectory() stringByAppendingPathComponent:[outputFileName stringByAppendingPathExtension:@"jpg"]];
    self.targetVideoPathMov = [NSTemporaryDirectory() stringByAppendingPathComponent:[outputFileName stringByAppendingPathExtension:@"mov"]];
    self.targetVideoPathMovCopy = [NSTemporaryDirectory() stringByAppendingPathComponent:[outputFileName stringByAppendingString:@"_copy.mov"]];
    self.targetVideoPathMp4 = [NSTemporaryDirectory() stringByAppendingPathComponent:[outputFileName stringByAppendingPathExtension:@"mp4"]];
    self.targetImagePath = [NSTemporaryDirectory() stringByAppendingPathComponent:[outputFileName stringByAppendingPathExtension:@"jpg"]];
    
    [self initParam];
    [self ui];
    
    self.session = [[AVCaptureSession alloc] init];
    NSArray<AVCaptureDeviceType>* deviceTypes = @[AVCaptureDeviceTypeBuiltInWideAngleCamera, AVCaptureDeviceTypeBuiltInDualCamera, AVCaptureDeviceTypeBuiltInTrueDepthCamera];
    self.videoDeviceDiscoverySession = [AVCaptureDeviceDiscoverySession discoverySessionWithDeviceTypes:deviceTypes mediaType:AVMediaTypeVideo position:AVCaptureDevicePositionUnspecified];
    
    // Set up the preview view.
    self.previewView.session = self.session;
    
    // Communicate with the session and other session objects on this queue.
    self.sessionQueue = dispatch_queue_create("session queue", DISPATCH_QUEUE_SERIAL);
    
    self.setupResult = AVCamSetupResultSuccess;
    
    dispatch_async(self.sessionQueue, ^{
        [self configureSession];
    });
    dispatch_async(dispatch_get_main_queue(), ^{
        self.spinner = [[UIActivityIndicatorView alloc] initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleLarge];
        self.spinner.color = [UIColor yellowColor];
        [self.previewView addSubview:self.spinner];
    });
}

- (void) viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    [self hideNavigationBar];
    dispatch_async(self.sessionQueue, ^{
        switch (self.setupResult)
        {
            case AVCamSetupResultSuccess:
            {
                // Only setup observers and start the session running if setup succeeded.
                [self addObservers];
                [self.session startRunning];
                self.sessionRunning = self.session.isRunning;
                break;
            }
            case AVCamSetupResultCameraNotAuthorized:
            {
                dispatch_async(dispatch_get_main_queue(), ^{
                    NSString* message = NSLocalizedString(@"AVCam doesn't have permission to use the camera, please change privacy settings", @"Alert message when the user has denied access to the camera");
                    UIAlertController* alertController = [UIAlertController alertControllerWithTitle:@"AVCam" message:message preferredStyle:UIAlertControllerStyleAlert];
                    UIAlertAction* cancelAction = [UIAlertAction actionWithTitle:NSLocalizedString(@"OK", @"Alert OK button") style:UIAlertActionStyleCancel handler:nil];
                    [alertController addAction:cancelAction];
                    // Provide quick access to Settings.
                    UIAlertAction* settingsAction = [UIAlertAction actionWithTitle:NSLocalizedString(@"Settings", @"Alert button to open Settings") style:UIAlertActionStyleDefault handler:^(UIAlertAction* action) {
                        [[UIApplication sharedApplication] openURL:[NSURL URLWithString:UIApplicationOpenSettingsURLString] options:@{} completionHandler:nil];
                    }];
                    [alertController addAction:settingsAction];
                    [self presentViewController:alertController animated:YES completion:nil];
                });
                break;
            }
            case AVCamSetupResultSessionConfigurationFailed:
            {
                dispatch_async(dispatch_get_main_queue(), ^{
                    NSString* message = NSLocalizedString(@"Unable to capture media", @"Alert message when something goes wrong during capture session configuration");
                    UIAlertController* alertController = [UIAlertController alertControllerWithTitle:@"AVCam" message:message preferredStyle:UIAlertControllerStyleAlert];
                    UIAlertAction* cancelAction = [UIAlertAction actionWithTitle:NSLocalizedString(@"OK", @"Alert OK button") style:UIAlertActionStyleCancel handler:nil];
                    [alertController addAction:cancelAction];
                    [self presentViewController:alertController animated:YES completion:nil];
                });
                break;
            }
        }
    });
}

- (void) viewDidDisappear:(BOOL)animated
{
    dispatch_async(self.sessionQueue, ^{
        if (self.setupResult == AVCamSetupResultSuccess) {
            [self.session stopRunning];
            [self removeObservers];
        }
    });
    
    [super viewDidDisappear:animated];
}

- (UIButton*)createButton:(CGPoint)point :(NSString*)imageName :(int)size :(SEL)sel :(UIColor*)color :(UIView*)parent{
    NSBundle *bundle = [NSBundle bundleForClass:[self class]];
    UIButton* r = [UIButton buttonWithType:UIButtonTypeCustom];
    r.frame = CGRectMake(0, 0, size, size);
    UIImage* image = nil;
    if(color){
        r.tintColor = color;
        image = [[UIImage imageNamed:imageName inBundle:bundle compatibleWithTraitCollection:nil] imageWithRenderingMode:UIImageRenderingModeAlwaysTemplate];
    } else {
        image = [UIImage imageNamed:imageName inBundle:bundle compatibleWithTraitCollection:nil];
    }
    r.contentMode = UIViewContentModeScaleToFill;
    [r setImage:image forState:UIControlStateNormal];
    r.center = point;
    [r addTarget:self action:sel forControlEvents:UIControlEventTouchUpInside];
    if(parent)
        [parent addSubview:r];
    else
        [self.view addSubview:r];
    return r;
}

- (void)initParam {
    self.startVideo = NO;
    self.startFront = YES;
    self.startFlash = YES;
    self.hasPicture = YES;
    self.hasVideo = YES;
    self.hasGallery = YES;
    self.minSec = 3;
    self.maxSec = 10;
    self.ratio = 1.0f;
    if(self.param) {
        if(self.param[@"startVideo"])
            self.startVideo = [self.param[@"startVideo"] boolValue];
        if(self.param[@"startFront"])
            self.startFront = [self.param[@"startFront"] boolValue];
        if(self.param[@"startFlash"])
            self.startFlash = [self.param[@"startFlash"] boolValue];
        if(self.param[@"hasPicture"])
            self.hasPicture = [self.param[@"hasPicture"] boolValue];
        if(self.param[@"hasVideo"])
            self.hasVideo = [self.param[@"hasVideo"] boolValue];
        if(self.param[@"hasGallery"])
            self.hasGallery = [self.param[@"hasGallery"] boolValue];
        
        if(self.param[@"minSec"])
            self.minSec = [self.param[@"minSec"] intValue];
        if(self.param[@"maxSec"])
            self.maxSec = [self.param[@"maxSec"] intValue];
        if(self.param[@"ratio"])
            self.ratio = [self.param[@"ratio"] floatValue];
    }
    
    self.front = self.startFront;
    self.flash = self.startFlash;
    self.video = self.startVideo;
}

- (void)ui{
    float sw = [UIScreen mainScreen].bounds.size.width;
    float sh = [UIScreen mainScreen].bounds.size.height;
    
    self.previewView = [[DevilAVCamPreviewView alloc] initWithFrame:CGRectMake(0, 0,
                                                                               self.view.frame.size.width, self.view.frame.size.height)];
    [self.view addSubview:self.previewView];
    
    float capH = (sh - (_ratio * sw)) / 2.0f;
    self.capTop = [[UILabel alloc] initWithFrame:CGRectMake(0, 0, sw, capH)];
    self.capTop.backgroundColor = UIColorFromRGBA(0xFF000000);
    [self.view addSubview:self.capTop];
    self.capBottom = [[UILabel alloc] initWithFrame:CGRectMake(0, sh-capH, sw, capH)];
    self.capBottom.backgroundColor = UIColorFromRGBA(0xFF000000);
    [self.view addSubview:self.capBottom];
    
    self.topTitle = [[UILabel alloc] initWithFrame:CGRectMake(0, 0, sw, 50)];
    self.topTitle.center = CGPointMake(sw/2, 80);
    self.topTitle.textColor = [UIColor whiteColor];
    self.topTitle.font = [UIFont systemFontOfSize:18];
    self.topTitle.textAlignment = NSTextAlignmentCenter;
    
    [self.view addSubview:self.topTitle];
    
    self.btnBack = [self createButton:CGPointMake(40, 80) :@"devil_camera_cancel" :30 :@selector(onClickBack:) :UIColorFromRGB(0xffffff) :nil];
    self.btnFlash = [self createButton:CGPointMake(sw-90, 80) :@"devil_camera_flash" :30 :@selector(onClickFlash:) :UIColorFromRGB(0xffffff) :nil];
    self.btnFront = [self createButton:CGPointMake(sw-35, 80) :@"devil_camera_front_back" :30 :@selector(onClickFront:) :UIColorFromRGB(0xffffff) :nil];
    
    self.btnTake = [self createButton:CGPointMake(sw/2, sh-100) :@"devil_camera_shutter" :70 :@selector(onClickTake:) :UIColorFromRGB(0x3cb043) :nil];
    self.btnRecordStart = [self createButton:CGPointMake(sw/2, sh-100) :@"devil_camera_record_start" :110 :@selector(onClickRecordStartOrStop:) :UIColorFromRGB(0xff0000) :nil];
    self.btnRecordStop = [self createButton:CGPointMake(sw/2, sh-100) :@"devil_camera_recording" :110 :@selector(onClickRecordStartOrStop:) : nil :nil];
    
    self.btnGallery = [self createButton:CGPointMake(sw/2 - 120, sh-100) :@"devil_camera_gallery" :30 :@selector(onClickGallery:) :UIColorFromRGB(0xffffff) :nil];
    
    self.btnPicture = [self createButton:CGPointMake(sw/2 + 120, sh-100) :@"devil_camera_picture" :35 :@selector(onClickPicture:) :UIColorFromRGB(0xffffff) :nil];
    self.btnVideo = [self createButton:CGPointMake(sw/2 + 120, sh-100) :@"devil_camera_video" :35 :@selector(onClickVideo:) :UIColorFromRGB(0xffffff) :nil];
    
    self.takenLayer = [[UIView alloc] initWithFrame:self.view.frame];
    self.takenLayer.userInteractionEnabled = YES;
    [self.view addSubview:self.takenLayer];
    self.takenLayer.backgroundColor = [UIColor whiteColor];
    self.takenImageView = [[UIImageView alloc] initWithFrame:CGRectMake(0, 0, sw, sh)];
    [self.takenLayer addSubview:self.takenImageView];
    
    self.cropView = [[PECropView alloc] initWithFrame:CGRectMake(0, 0, sw, sh)];
    self.cropView.ratio = self.ratio;
    self.cropView.keepingCropAspectRatio = YES;
    [self.takenLayer addSubview:self.cropView];
    
    self.btnBack1 = [self createButton:CGPointMake(sw/2 - 60, sh-100) :@"devil_camera_cancel" :50 :@selector(onClickCancel1:) :UIColorFromRGB(0xff0000) :self.takenLayer];
    self.btnComplete1 = [self createButton:CGPointMake(sw/2 + 60, sh-100) :@"devil_camera_complete" :50 :@selector(onClickComplete1:) :UIColorFromRGB(0x3cb043) :self.takenLayer];
    
    
    self.recordLayer = [[UIView alloc] initWithFrame:self.view.frame];
    self.recordLayer.userInteractionEnabled = YES;
    [self.view addSubview:self.recordLayer];
    self.recordLayer.backgroundColor = [UIColor whiteColor];
    
    self.videoView = [[WildCardVideoView alloc] initWithFrame:CGRectMake(0, 0, sw, sw)];
    self.videoView.playerViewController.showsPlaybackControls = YES;
    self.videoView.center = CGPointMake(sw/2, sh/2);
    [self.recordLayer addSubview:self.videoView];
    
    self.btnBack2 = [self createButton:CGPointMake(sw/2 - 60, sh-100) :@"devil_camera_cancel" :50 :@selector(onClickCancel2:) :UIColorFromRGB(0xff0000) :self.recordLayer];
    self.btnComplete2 = [self createButton:CGPointMake(sw/2 + 60, sh-100) :@"devil_camera_complete" :50 :@selector(onClickComplete2:) :UIColorFromRGB(0x3cb043) :self.recordLayer];
    
    if(_hasVideo && !_hasPicture) {
        self.startVideo = YES;
    }
        
    if(_hasVideo && _startVideo){
        self.video = YES;
        [self uiRecord];
    } else if(_hasPicture){
        self.video = NO;
        [self uiPicture];
    }
    
}

- (void)uiPicture {
    self.uiMode = UIModePicture;
    self.topTitle.text = @"";
    self.recordLayer.hidden = YES;
    self.takenLayer.hidden = YES;
    self.btnTake.hidden = NO;
    self.btnRecordStart.hidden = YES;
    self.btnRecordStop.hidden = YES;
    self.btnFront.hidden = NO;
    self.btnFlash.hidden = NO;
    self.btnGallery.hidden = self.hasGallery?NO:YES;
    self.btnVideo.hidden = self.hasVideo?NO:YES;
    self.btnPicture.hidden = YES;
}

- (void)uiTaken {
    self.topTitle.text = @"";
    self.uiMode = UIModeTaken;
    self.recordLayer.hidden = YES;
    self.takenLayer.hidden = NO;
}

- (void)uiRecord {
    self.uiMode = UIModeRecord;
    self.topTitle.text = @"동영상";
    self.recordSec = 0;
    self.recordLayer.hidden = YES;
    self.takenLayer.hidden = YES;
    self.btnTake.hidden = YES;
    self.btnRecordStart.hidden = NO;
    self.btnRecordStop.hidden = YES;
    self.btnFront.hidden = NO;
    self.btnFlash.hidden = NO;
    self.btnGallery.hidden = self.hasGallery?NO:YES;
    self.btnVideo.hidden = YES;
    self.btnPicture.hidden = self.hasPicture?NO:YES;
}

- (void)tick {
    if(self.uiMode == UIModeRecording){
        self.recordSec++;
        NSString* t = @"";
        if(self.recordSec >= 3600)
            t = [NSString stringWithFormat:@"%02d:%02d:%02d", self.recordSec/3600, (self.recordSec%3600)/60, self.recordSec % 60];
        else
            t = [NSString stringWithFormat:@"%02d:%02d", (self.recordSec%3600)/60, self.recordSec % 60];
        self.topTitle.text =t;
        [self performSelector:@selector(tick) withObject:nil afterDelay:1];
    }
}

- (void)uiRecording {
    self.uiMode = UIModeRecording;
    self.topTitle.text = @"00:00";
    [self performSelector:@selector(tick) withObject:nil afterDelay:1];
    self.recordLayer.hidden = YES;
    self.takenLayer.hidden = YES;
    self.btnTake.hidden = YES;
    self.btnRecordStart.hidden = YES;
    self.btnRecordStop.hidden = NO;
    self.btnFront.hidden = YES;
    self.btnFlash.hidden = YES;
    self.btnGallery.hidden = YES;
    self.btnVideo.hidden = YES;
    self.btnPicture.hidden = YES;
}

- (void)uiRecorded {
    self.topTitle.text = @"동영상";
    self.uiMode = UIModeRecorded;
    self.recordLayer.hidden = NO;
    self.takenLayer.hidden = YES;
}

- (void) configureSession
{
    if (self.setupResult != AVCamSetupResultSuccess) {
        return;
    }
    
    NSError* error = nil;
    
    [self.session beginConfiguration];
    
    /*
     We do not create an AVCaptureMovieFileOutput when setting up the session because
     Live Photo is not supported when AVCaptureMovieFileOutput is added to the session.
    */
    self.session.sessionPreset = AVCaptureSessionPresetPhoto;
    
    // Add video input.
    
    // Choose the back dual camera if available, otherwise default to a wide angle camera.
    AVCaptureDevice* videoDevice = nil;
    if(self.front)
        videoDevice = [AVCaptureDevice defaultDeviceWithDeviceType:AVCaptureDeviceTypeBuiltInWideAngleCamera mediaType:AVMediaTypeVideo position:AVCaptureDevicePositionFront];
    else
        videoDevice = [AVCaptureDevice defaultDeviceWithDeviceType:AVCaptureDeviceTypeBuiltInDualCamera mediaType:AVMediaTypeVideo position:AVCaptureDevicePositionBack];
    if (!videoDevice) {
        // If a rear dual camera is not available, default to the rear wide angle camera.
        videoDevice = [AVCaptureDevice defaultDeviceWithDeviceType:AVCaptureDeviceTypeBuiltInWideAngleCamera mediaType:AVMediaTypeVideo position:AVCaptureDevicePositionBack];
        
        // In the event that the rear wide angle camera isn't available, default to the front wide angle camera.
        if (!videoDevice) {
            videoDevice = [AVCaptureDevice defaultDeviceWithDeviceType:AVCaptureDeviceTypeBuiltInWideAngleCamera mediaType:AVMediaTypeVideo position:AVCaptureDevicePositionFront];
        }
    }
    
    AVCaptureDeviceInput* videoDeviceInput = [AVCaptureDeviceInput deviceInputWithDevice:videoDevice error:&error];
    if (!videoDeviceInput) {
        NSLog(@"Could not create video device input: %@", error);
        self.setupResult = AVCamSetupResultSessionConfigurationFailed;
        [self.session commitConfiguration];
        return;
    }
    if ([self.session canAddInput:videoDeviceInput]) {
        [self.session addInput:videoDeviceInput];
        self.videoDeviceInput = videoDeviceInput;
        
        dispatch_async(dispatch_get_main_queue(), ^{
            /*
             Dispatch video streaming to the main queue because AVCaptureVideoPreviewLayer is the backing layer for PreviewView.
             You can manipulate UIView only on the main thread.
             Note: As an exception to the above rule, it is not necessary to serialize video orientation changes
             on the AVCaptureVideoPreviewLayer’s connection with other session manipulation.
             
             Use the status bar orientation as the initial video orientation. Subsequent orientation changes are
             handled by CameraViewController.viewWillTransition(to:with:).
            */
            AVCaptureVideoOrientation initialVideoOrientation = AVCaptureVideoOrientationPortrait;
            if (self.windowOrientation != UIInterfaceOrientationUnknown) {
                initialVideoOrientation = (AVCaptureVideoOrientation)self.windowOrientation;
            }
            
            self.previewView.videoPreviewLayer.connection.videoOrientation = initialVideoOrientation;
        });
    }
    else {
        NSLog(@"Could not add video device input to the session");
        self.setupResult = AVCamSetupResultSessionConfigurationFailed;
        [self.session commitConfiguration];
        return;
    }
    
    // Add audio input.
    AVCaptureDevice* audioDevice = [AVCaptureDevice defaultDeviceWithMediaType:AVMediaTypeAudio];
    AVCaptureDeviceInput* audioDeviceInput = [AVCaptureDeviceInput deviceInputWithDevice:audioDevice error:&error];
    if (!audioDeviceInput) {
        NSLog(@"Could not create audio device input: %@", error);
    }
    if ([self.session canAddInput:audioDeviceInput]) {
        [self.session addInput:audioDeviceInput];
    }
    else {
        NSLog(@"Could not add audio device input to the session");
    }
    
    // Add photo output.
    AVCapturePhotoOutput* photoOutput = [[AVCapturePhotoOutput alloc] init];
    if ([self.session canAddOutput:photoOutput]) {
        [self.session addOutput:photoOutput];
        self.photoOutput = photoOutput;
        
        self.photoOutput.highResolutionCaptureEnabled = YES;
        self.photoOutput.livePhotoCaptureEnabled = self.photoOutput.livePhotoCaptureSupported;
        self.photoOutput.depthDataDeliveryEnabled = self.photoOutput.depthDataDeliverySupported;
        self.photoOutput.portraitEffectsMatteDeliveryEnabled = self.photoOutput.portraitEffectsMatteDeliverySupported;
        self.photoOutput.enabledSemanticSegmentationMatteTypes = self.photoOutput.availableSemanticSegmentationMatteTypes;
        self.selectedSemanticSegmentationMatteTypes = self.photoOutput.enabledSemanticSegmentationMatteTypes;
        self.photoOutput.maxPhotoQualityPrioritization = AVCapturePhotoQualityPrioritizationSpeed;
        
        self.livePhotoMode = self.photoOutput.livePhotoCaptureSupported ? AVCamLivePhotoModeOn : AVCamLivePhotoModeOff;
        self.depthDataDeliveryMode = self.photoOutput.depthDataDeliverySupported ? AVCamDepthDataDeliveryModeOn : AVCamDepthDataDeliveryModeOff;
        self.portraitEffectsMatteDeliveryMode = self.photoOutput.portraitEffectsMatteDeliverySupported ? AVCamPortraitEffectsMatteDeliveryModeOn : AVCamPortraitEffectsMatteDeliveryModeOff;
        self.photoQualityPrioritizationMode = AVCapturePhotoQualityPrioritizationSpeed;
        
        self.inProgressPhotoCaptureDelegates = [NSMutableDictionary dictionary];
        self.inProgressLivePhotoCapturesCount = 0;
    }
    else {
        NSLog(@"Could not add photo output to the session");
        self.setupResult = AVCamSetupResultSessionConfigurationFailed;
        [self.session commitConfiguration];
        return;
    }
    
    if(self.video) {
        [self onClickVideo:nil];
    }
    
    self.backgroundRecordingID = UIBackgroundTaskInvalid;
    
    [self.session commitConfiguration];
}

- (UIInterfaceOrientation)windowOrientation {
    return self.view.window.windowScene.interfaceOrientation;
}

- (UIInterfaceOrientationMask)supportedInterfaceOrientations
{
    return UIInterfaceOrientationMaskPortrait;
}


- (void) onClickRecordStartOrStop:(id)sender
{
    /*
     Disable the Camera button until recording finishes, and disable
     the Record button until recording starts or finishes.
     
     See the AVCaptureFileOutputRecordingDelegate methods.
    */
    
    /*
     Retrieve the video preview layer's video orientation on the main queue
     before entering the session queue. We do this to ensure UI elements are
     accessed on the main thread and session configuration is done on the session queue.
    */
    AVCaptureVideoOrientation videoPreviewLayerVideoOrientation = self.previewView.videoPreviewLayer.connection.videoOrientation;
    
    dispatch_async(self.sessionQueue, ^{
        if (!self.movieFileOutput.isRecording) {
            if ([UIDevice currentDevice].isMultitaskingSupported) {
                /*
                 Setup background task.
                 This is needed because the -[captureOutput:didFinishRecordingToOutputFileAtURL:fromConnections:error:]
                 callback is not received until AVCam returns to the foreground unless you request background execution time.
                 This also ensures that there will be time to write the file to the photo library when AVCam is backgrounded.
                 To conclude this background execution, -[endBackgroundTask:] is called in
                 -[captureOutput:didFinishRecordingToOutputFileAtURL:fromConnections:error:] after the recorded file has been saved.
                */
                self.backgroundRecordingID = [[UIApplication sharedApplication] beginBackgroundTaskWithExpirationHandler:nil];
            }
            
            // Update the orientation on the movie file output video connection before starting recording.
            AVCaptureConnection* movieFileOutputConnection = [self.movieFileOutput connectionWithMediaType:AVMediaTypeVideo];
            movieFileOutputConnection.videoOrientation = videoPreviewLayerVideoOrientation;
            
            // Use HEVC codec if supported
            if ([self.movieFileOutput.availableVideoCodecTypes containsObject:AVVideoCodecTypeHEVC]) {
                [self.movieFileOutput setOutputSettings:@{ AVVideoCodecKey : AVVideoCodecTypeHEVC } forConnection:movieFileOutputConnection];
            }
            
            // Start recording to a temporary file.
            NSString* outputFilePath = self.targetVideoPathMov;
            NSURL* outputURL = [NSURL fileURLWithPath:outputFilePath];
            [self.movieFileOutput startRecordingToOutputFileURL:outputURL recordingDelegate:self];
        }
        else {
            
            [self.movieFileOutput stopRecording];
        }
    });
}

- (void) captureOutput:(AVCaptureFileOutput*)captureOutput
didStartRecordingToOutputFileAtURL:(NSURL*)fileURL
       fromConnections:(NSArray*)connections
{
    // Enable the Record button to let the user stop recording.
    dispatch_async(dispatch_get_main_queue(), ^{
        [self uiRecording];
    });
}


- (void) captureOutput:(AVCaptureFileOutput*)captureOutput
didFinishRecordingToOutputFileAtURL:(NSURL*)outputFileURL
       fromConnections:(NSArray*)connections
                 error:(NSError*)error
{
    /*
     currentBackgroundRecordingID is used to end the background task
     associated with the current recording. It allows a new recording to be started
     and associated with a new UIBackgroundTaskIdentifier, once the movie file output's
     `recording` property is back to NO.
     Since a unique file path for each recording is used, a new recording will
     not overwrite a recording currently being saved.
    */
    UIBackgroundTaskIdentifier currentBackgroundRecordingID = self.backgroundRecordingID;
    self.backgroundRecordingID = UIBackgroundTaskInvalid;
    
    dispatch_block_t cleanUp = ^{
        if ([[NSFileManager defaultManager] fileExistsAtPath:outputFileURL.path]) {
            [[NSFileManager defaultManager] removeItemAtPath:outputFileURL.path error:NULL];
        }
        
        if (currentBackgroundRecordingID != UIBackgroundTaskInvalid) {
            [[UIApplication sharedApplication] endBackgroundTask:currentBackgroundRecordingID];
        }
    };
    
    BOOL success = YES;
    
    if (error) {
        NSLog(@"Movie file finishing error: %@", error);
        success = [error.userInfo[AVErrorRecordingSuccessfullyFinishedKey] boolValue];
    }
    if (success) {
        // Enable the Camera and Record buttons to let the user switch camera and start another recording.
        dispatch_async(dispatch_get_main_queue(), ^{
            if([self checkDuration:self.targetVideoPathMov]) {
                UIImage* preview = [DevilUtil getThumbnail:self.targetVideoPathMov];
                NSData *imageData = UIImageJPEGRepresentation(preview, 0.6f);
                [imageData writeToFile:self.targetPreviewPath atomically:YES];
                [self uiRecorded];
                [DevilUtil convertMovToMp4:self.targetVideoPathMov to:self.targetVideoPathMp4 callback:^(id  _Nonnull res) {
                    if([res[@"r"] boolValue]){
                        [self.videoView setPreview:self.targetPreviewPath video:self.targetVideoPathMp4 force:YES];
                        [self.videoView play];
                    } else
                        [self showAlert:@"Record Failed"];
                }];
            }
        });
    }
    else {
        cleanUp();
    }
}

- (void) addObservers
{
    [self.session addObserver:self forKeyPath:@"running" options:NSKeyValueObservingOptionNew context:SessionRunningContext];
    [self addObserver:self forKeyPath:@"videoDeviceInput.device.systemPressureState" options:NSKeyValueObservingOptionNew context:SystemPressureContext];
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(subjectAreaDidChange:) name:AVCaptureDeviceSubjectAreaDidChangeNotification object:self.videoDeviceInput.device];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(sessionRuntimeError:) name:AVCaptureSessionRuntimeErrorNotification object:self.session];
    
    /*
     A session can only run when the app is full screen. It will be interrupted
     in a multi-app layout, introduced in iOS 9, see also the documentation of
     AVCaptureSessionInterruptionReason. Add observers to handle these session
     interruptions and show a preview is paused message. See the documentation
     of AVCaptureSessionWasInterruptedNotification for other interruption reasons.
    */
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(sessionWasInterrupted:) name:AVCaptureSessionWasInterruptedNotification object:self.session];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(sessionInterruptionEnded:) name:AVCaptureSessionInterruptionEndedNotification object:self.session];
}

- (void) removeObservers
{
    [[NSNotificationCenter defaultCenter] removeObserver:self];
    
    [self.session removeObserver:self forKeyPath:@"running" context:SessionRunningContext];
    [self removeObserver:self forKeyPath:@"videoDeviceInput.device.systemPressureState" context:SystemPressureContext];
}


- (void) observeValueForKeyPath:(NSString*)keyPath
                       ofObject:(id)object
                         change:(NSDictionary*)change
                        context:(void*)context
{
    if (context == SessionRunningContext) {
        BOOL isSessionRunning = [change[NSKeyValueChangeNewKey] boolValue];
        BOOL livePhotoCaptureEnabled = self.photoOutput.livePhotoCaptureEnabled;
        BOOL depthDataDeliveryEnabled = self.photoOutput.depthDataDeliveryEnabled;
        BOOL portraitEffectsMatteDeliveryEnabled = self.photoOutput.portraitEffectsMatteDeliveryEnabled;
        BOOL semanticSegmentationMatteDeliveryEnabled = (self.photoOutput.enabledSemanticSegmentationMatteTypes.count > 0) ? YES: NO;
        
        dispatch_async(dispatch_get_main_queue(), ^{
            // Only enable the ability to change camera if the device has more than one camera.
            
        });
    }
    else if (context == SystemPressureContext) {
        AVCaptureSystemPressureState* systemPressureState = change[NSKeyValueChangeNewKey];
        [self setRecommendedFrameRateRangeForPressureState:systemPressureState];
    }
    else {
        [super observeValueForKeyPath:keyPath ofObject:object change:change context:context];
    }
}


- (void) focusWithMode:(AVCaptureFocusMode)focusMode
        exposeWithMode:(AVCaptureExposureMode)exposureMode
         atDevicePoint:(CGPoint)point
monitorSubjectAreaChange:(BOOL)monitorSubjectAreaChange
{
    dispatch_async(self.sessionQueue, ^{
        AVCaptureDevice* device = self.videoDeviceInput.device;
        NSError* error = nil;
        if ([device lockForConfiguration:&error]) {
            /*
             Setting (focus/exposure)PointOfInterest alone does not initiate a (focus/exposure) operation.
             Call set(Focus/Exposure)Mode() to apply the new point of interest.
            */
            if (device.isFocusPointOfInterestSupported && [device isFocusModeSupported:focusMode]) {
                device.focusPointOfInterest = point;
                device.focusMode = focusMode;
            }
            
            if (device.isExposurePointOfInterestSupported && [device isExposureModeSupported:exposureMode]) {
                device.exposurePointOfInterest = point;
                device.exposureMode = exposureMode;
            }
            
            device.subjectAreaChangeMonitoringEnabled = monitorSubjectAreaChange;
            [device unlockForConfiguration];
        }
        else {
            NSLog(@"Could not lock device for configuration: %@", error);
        }
    });
}

- (void) subjectAreaDidChange:(NSNotification*)notification
{
    CGPoint devicePoint = CGPointMake(0.5, 0.5);
    [self focusWithMode:AVCaptureFocusModeContinuousAutoFocus exposeWithMode:AVCaptureExposureModeContinuousAutoExposure atDevicePoint:devicePoint monitorSubjectAreaChange:NO];
}

- (void) sessionRuntimeError:(NSNotification*)notification
{
    NSError* error = notification.userInfo[AVCaptureSessionErrorKey];
    NSLog(@"Capture session runtime error: %@", error);
    
    // If media services were reset, and the last start succeeded, restart the session.
    if (error.code == AVErrorMediaServicesWereReset) {
        dispatch_async(self.sessionQueue, ^{
            if (self.isSessionRunning) {
                [self.session startRunning];
                self.sessionRunning = self.session.isRunning;
            }
            else {
                dispatch_async(dispatch_get_main_queue(), ^{
                    
                });
            }
        });
    }
    else {
        
    }
}

- (void) setRecommendedFrameRateRangeForPressureState:(AVCaptureSystemPressureState*)systemPressureState
{
    /*
     The frame rates used here are for demonstrative purposes only for this app.
     Your frame rate throttling may be different depending on your app's camera configuration.
    */
    AVCaptureSystemPressureLevel pressureLevel = [systemPressureState level];
    if (pressureLevel == AVCaptureSystemPressureLevelSerious || pressureLevel == AVCaptureSystemPressureLevelCritical) {
        if (![self.movieFileOutput isRecording] && [self.videoDeviceInput.device lockForConfiguration:nil]) {
            NSLog(@"WARNING: Reached elevated system pressure level: %@. Throttling frame rate.", pressureLevel);
            self.videoDeviceInput.device.activeVideoMinFrameDuration = CMTimeMake(1, 20);
            self.videoDeviceInput.device.activeVideoMaxFrameDuration = CMTimeMake(1, 15);
            [self.videoDeviceInput.device unlockForConfiguration];
        }
    }
    else if (pressureLevel == AVCaptureSystemPressureLevelShutdown) {
        NSLog(@"Session stopped running due to shutdown system pressure level.");
    }
}

- (void) sessionWasInterrupted:(NSNotification*)notification
{
    /*
     In some scenarios we want to enable the user to resume the session running.
     For example, if music playback is initiated via control center while
     using AVCam, then the user can let AVCam resume
     the session running, which will stop music playback. Note that stopping
     music playback in control center will not automatically resume the session
     running. Also note that it is not always possible to resume, see -[resumeInterruptedSession:].
    */
    BOOL showResumeButton = NO;
    
    AVCaptureSessionInterruptionReason reason = [notification.userInfo[AVCaptureSessionInterruptionReasonKey] integerValue];
    NSLog(@"Capture session was interrupted with reason %ld", (long)reason);
    
    if (reason == AVCaptureSessionInterruptionReasonAudioDeviceInUseByAnotherClient ||
        reason == AVCaptureSessionInterruptionReasonVideoDeviceInUseByAnotherClient) {
        showResumeButton = YES;
    }
    else if (reason == AVCaptureSessionInterruptionReasonVideoDeviceNotAvailableWithMultipleForegroundApps) {
        // Fade-in a label to inform the user that the camera is unavailable.
        
        [UIView animateWithDuration:0.25 animations:^{
            
        }];
    }
    else if (reason == AVCaptureSessionInterruptionReasonVideoDeviceNotAvailableDueToSystemPressure) {
        NSLog(@"Session stopped running due to shutdown system pressure level.");
    }
    
    if (showResumeButton) {
        // Fade-in a button to enable the user to try to resume the session running.
        [UIView animateWithDuration:0.25 animations:^{
        }];
    }
}

- (void) sessionInterruptionEnded:(NSNotification*)notification
{
    NSLog(@"Capture session interruption ended");
    if(self.video)
        [self uiRecord];
    else
        [self uiPicture];
}


- (void)hideNavigationBar{
    [self.navigationController setNavigationBarHidden:YES animated:YES];
}

-(void)onClickTake:(id)sender {
    /*
     Retrieve the video preview layer's video orientation on the main queue before
     entering the session queue. We do this to ensure UI elements are accessed on
     the main thread and session configuration is done on the session queue.
    */
    AVCaptureVideoOrientation videoPreviewLayerVideoOrientation = self.previewView.videoPreviewLayer.connection.videoOrientation;
    
    dispatch_async(self.sessionQueue, ^{
        
        // Update the photo output's connection to match the video orientation of the video preview layer.
        AVCaptureConnection* photoOutputConnection = [self.photoOutput connectionWithMediaType:AVMediaTypeVideo];
        photoOutputConnection.videoOrientation = videoPreviewLayerVideoOrientation;
        
        AVCapturePhotoSettings* photoSettings;
        // Capture HEIF photos when supported, with the flash set to enable auto- and high-resolution photos.
        if ([self.photoOutput.availablePhotoCodecTypes containsObject:AVVideoCodecTypeHEVC]) {
            photoSettings = [AVCapturePhotoSettings photoSettingsWithFormat:@{ AVVideoCodecKey : AVVideoCodecTypeHEVC }];
        }
        else {
            photoSettings = [AVCapturePhotoSettings photoSettings];
        }
        
        if (self.videoDeviceInput.device.isFlashAvailable) {
            if(self.flash && !self.front)
                photoSettings.flashMode = AVCaptureFlashModeAuto;
            else
                photoSettings.flashMode = AVCaptureFlashModeOff;
        }
        
        photoSettings.highResolutionPhotoEnabled = YES;
        if (photoSettings.availablePreviewPhotoPixelFormatTypes.count > 0) {
            photoSettings.previewPhotoFormat = @{ (NSString*)kCVPixelBufferPixelFormatTypeKey : photoSettings.availablePreviewPhotoPixelFormatTypes.firstObject };
        }
        if (self.livePhotoMode == AVCamLivePhotoModeOn && self.photoOutput.livePhotoCaptureSupported) { // Live Photo capture is not supported in movie mode.
            NSString* livePhotoMovieFileName = [NSUUID UUID].UUIDString;
            NSString* livePhotoMovieFilePath = [NSTemporaryDirectory() stringByAppendingPathComponent:[livePhotoMovieFileName stringByAppendingPathExtension:@"mov"]];
            photoSettings.livePhotoMovieFileURL = [NSURL fileURLWithPath:livePhotoMovieFilePath];
        }
        
        photoSettings.depthDataDeliveryEnabled = (self.depthDataDeliveryMode == AVCamDepthDataDeliveryModeOn && self.photoOutput.isDepthDataDeliveryEnabled);
        
        photoSettings.portraitEffectsMatteDeliveryEnabled = (self.portraitEffectsMatteDeliveryMode == AVCamPortraitEffectsMatteDeliveryModeOn && self.photoOutput.isPortraitEffectsMatteDeliveryEnabled);
        
        if ( photoSettings.depthDataDeliveryEnabled && self.photoOutput.availableSemanticSegmentationMatteTypes.count > 0 ) {
            photoSettings.enabledSemanticSegmentationMatteTypes = self.selectedSemanticSegmentationMatteTypes;
        }
        
        photoSettings.photoQualityPrioritization = self.photoQualityPrioritizationMode;
        
        // Use a separate object for the photo capture delegate to isolate each capture life cycle.
        DevilAVCamPhotoCaptureDelegate* photoCaptureDelegate = [[DevilAVCamPhotoCaptureDelegate alloc] initWithRequestedPhotoSettings:photoSettings willCapturePhotoAnimation:^{
            dispatch_async(dispatch_get_main_queue(), ^{
                self.previewView.videoPreviewLayer.opacity = 0.0;
                [UIView animateWithDuration:0.25 animations:^{
                    self.previewView.videoPreviewLayer.opacity = 1.0;
                }];
            });
        } livePhotoCaptureHandler:^(BOOL capturing) {
            /*
             Because Live Photo captures can overlap, we need to keep track of the
             number of in progress Live Photo captures to ensure that the
             Live Photo label stays visible during these captures.
            */
            dispatch_async(self.sessionQueue, ^{
                if (capturing) {
                    self.inProgressLivePhotoCapturesCount++;
                }
                else {
                    self.inProgressLivePhotoCapturesCount--;
                }
                
                NSInteger inProgressLivePhotoCapturesCount = self.inProgressLivePhotoCapturesCount;
                dispatch_async(dispatch_get_main_queue(), ^{
                });
            });
        } completionHandler:^(DevilAVCamPhotoCaptureDelegate* photoCaptureDelegate) {
            // When the capture is complete, remove a reference to the photo capture delegate so it can be deallocated.
            dispatch_async(self.sessionQueue, ^{
                self.inProgressPhotoCaptureDelegates[@(photoCaptureDelegate.requestedPhotoSettings.uniqueID)] = nil;
            });
            dispatch_async(dispatch_get_main_queue(), ^{
                [self uiTaken];
                UIImage* photo = [UIImage imageWithData: photoCaptureDelegate.photoData];
                if(_front)
                    photo = [UIImage imageWithCGImage:photo.CGImage scale:photo.scale orientation:UIImageOrientationLeftMirrored];
                [self.cropView setImage:photo];
            });
        } photoProcessingHandler:^(BOOL animate) {
            // Animates a spinner while photo is processing
            dispatch_async(dispatch_get_main_queue(), ^{
                if ( animate ) {
                    self.spinner.hidesWhenStopped = YES;
                    self.spinner.center = CGPointMake(self.previewView.frame.size.width / 2.0, self.previewView.frame.size.height / 2.0);
                    [self.spinner startAnimating];
                }
                else {
                    [self.spinner stopAnimating];
                }
            });
        }];
        
        /*
         The Photo Output keeps a weak reference to the photo capture delegate so
         we store it in an array to maintain a strong reference to this object
         until the capture is completed.
        */
        self.inProgressPhotoCaptureDelegates[@(photoCaptureDelegate.requestedPhotoSettings.uniqueID)] = photoCaptureDelegate;
        
        [self.photoOutput capturePhotoWithSettings:photoSettings delegate:photoCaptureDelegate];
    });
}

-(void)onClickFlash:(id)sender {
    Class captureDeviceClass = NSClassFromString(@"AVCaptureDevice");
    if (captureDeviceClass != nil) {
        AVCaptureDevice *device = [AVCaptureDevice defaultDeviceWithMediaType:AVMediaTypeVideo];
        if ([device hasTorch] && [device hasFlash]){

            [device lockForConfiguration:nil];
            if (device.torchMode == AVCaptureTorchModeOff)
            {
                [device setTorchMode:AVCaptureTorchModeOn];
                [device setFlashMode:AVCaptureFlashModeOn];
                self.flash = YES;
            }
            else
            {
                [device setTorchMode:AVCaptureTorchModeOff];
                [device setFlashMode:AVCaptureFlashModeOff];
                self.flash= NO;
            }
            [device unlockForConfiguration];
        }
    }
}

-(void)onClickFront:(id)sender {
    dispatch_async(self.sessionQueue, ^{
        AVCaptureDevice* currentVideoDevice = self.videoDeviceInput.device;
        AVCaptureDevicePosition currentPosition = currentVideoDevice.position;
        
        AVCaptureDevicePosition preferredPosition;
        AVCaptureDeviceType preferredDeviceType;
        
        switch (currentPosition)
        {
            case AVCaptureDevicePositionUnspecified:
            case AVCaptureDevicePositionFront: {
                preferredPosition = AVCaptureDevicePositionBack;
                preferredDeviceType = AVCaptureDeviceTypeBuiltInDualCamera;
                self.front = NO;
                
                dispatch_async(dispatch_get_main_queue(), ^{
                    self.btnFlash.hidden = NO;
                });
                break;
            }
            case AVCaptureDevicePositionBack: {
                preferredPosition = AVCaptureDevicePositionFront;
                preferredDeviceType = AVCaptureDeviceTypeBuiltInTrueDepthCamera;
                self.front = YES;
                dispatch_async(dispatch_get_main_queue(), ^{
                    self.btnFlash.hidden = YES;
                });
                
                break;
            }
        }
        
        NSArray<AVCaptureDevice* >* devices = self.videoDeviceDiscoverySession.devices;
        AVCaptureDevice* newVideoDevice = nil;
        
        // First, look for a device with both the preferred position and device type.
        for (AVCaptureDevice* device in devices) {
            if (device.position == preferredPosition && [device.deviceType isEqualToString:preferredDeviceType]) {
                newVideoDevice = device;
                break;
            }
        }
        
        // Otherwise, look for a device with only the preferred position.
        if (!newVideoDevice) {
            for (AVCaptureDevice* device in devices) {
                if (device.position == preferredPosition) {
                    newVideoDevice = device;
                    break;
                }
            }
        }
        
        
        if (newVideoDevice) {
            AVCaptureDeviceInput* videoDeviceInput = [AVCaptureDeviceInput deviceInputWithDevice:newVideoDevice error:NULL];
            
            [self.session beginConfiguration];
            
            // Remove the existing device input first, since using the front and back camera simultaneously is not supported.
            [self.session removeInput:self.videoDeviceInput];
            
            if ([self.session canAddInput:videoDeviceInput]) {
                [[NSNotificationCenter defaultCenter] removeObserver:self name:AVCaptureDeviceSubjectAreaDidChangeNotification object:currentVideoDevice];
                
                [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(subjectAreaDidChange:) name:AVCaptureDeviceSubjectAreaDidChangeNotification object:newVideoDevice];
                
                [self.session addInput:videoDeviceInput];
                self.videoDeviceInput = videoDeviceInput;
            }
            else {
                [self.session addInput:self.videoDeviceInput];
            }
            
            AVCaptureConnection* movieFileOutputConnection = [self.movieFileOutput connectionWithMediaType:AVMediaTypeVideo];
            if (movieFileOutputConnection.isVideoStabilizationSupported) {
                movieFileOutputConnection.preferredVideoStabilizationMode = AVCaptureVideoStabilizationModeAuto;
            }
            
            /*
             Set Live Photo capture and depth data delivery if it is supported. When changing cameras, the
             `livePhotoCaptureEnabled` and `depthDataDeliveryEnabled` properties of the AVCapturePhotoOutput gets set to NO when
             a video device is disconnected from the session. After the new video device is
             added to the session, re-enable Live Photo capture and depth data delivery if they are supported.
            */
            self.photoOutput.livePhotoCaptureEnabled = self.photoOutput.livePhotoCaptureSupported;
            self.photoOutput.depthDataDeliveryEnabled = self.photoOutput.depthDataDeliverySupported;
            self.photoOutput.portraitEffectsMatteDeliveryEnabled = self.photoOutput.portraitEffectsMatteDeliverySupported;
            self.photoOutput.enabledSemanticSegmentationMatteTypes = self.photoOutput.availableSemanticSegmentationMatteTypes;
            self.selectedSemanticSegmentationMatteTypes = self.photoOutput.availableSemanticSegmentationMatteTypes;
            self.photoOutput.maxPhotoQualityPrioritization = AVCapturePhotoQualityPrioritizationSpeed;
            
            [self.session commitConfiguration];
        }
    });
}

- (void)onClickVideo:(id)sender{
    
    
    dispatch_async(self.sessionQueue, ^{
        AVCaptureMovieFileOutput* movieFileOutput = [[AVCaptureMovieFileOutput alloc] init];
        
        if ([self.session canAddOutput:movieFileOutput])
        {
            [self.session beginConfiguration];
            [self.session addOutput:movieFileOutput];
            self.session.sessionPreset = AVCaptureSessionPreset640x480;
            AVCaptureConnection* connection = [movieFileOutput connectionWithMediaType:AVMediaTypeVideo];
            if (connection.isVideoStabilizationSupported) {
                connection.preferredVideoStabilizationMode = AVCaptureVideoStabilizationModeAuto;
            }
            [self.session commitConfiguration];
            
            self.movieFileOutput = movieFileOutput;
            
            dispatch_async(dispatch_get_main_queue(), ^{
                [self uiRecord];
            });
        }
    });
}

- (void)onClickPicture:(id)sender
{
    [self uiPicture];
    dispatch_async(self.sessionQueue, ^{
        /*
         Remove the AVCaptureMovieFileOutput from the session because Live Photo
         capture is not supported when an AVCaptureMovieFileOutput is connected to the session.
        */
        [self.session beginConfiguration];
        [self.session removeOutput:self.movieFileOutput];
        self.session.sessionPreset = AVCaptureSessionPresetPhoto;
        
        self.movieFileOutput = nil;
        
        if (self.photoOutput.livePhotoCaptureSupported) {
            self.photoOutput.livePhotoCaptureEnabled = YES;
            
        }
        
        if (self.photoOutput.depthDataDeliverySupported) {
            self.photoOutput.depthDataDeliveryEnabled = YES;
            
        }
        
        if (self.photoOutput.portraitEffectsMatteDeliverySupported) {
            self.photoOutput.portraitEffectsMatteDeliveryEnabled = YES;
            
        }
        
        if (self.photoOutput.availableSemanticSegmentationMatteTypes.count > 0) {
            self.photoOutput.enabledSemanticSegmentationMatteTypes = self.photoOutput.availableSemanticSegmentationMatteTypes;
            self.selectedSemanticSegmentationMatteTypes = self.photoOutput.availableSemanticSegmentationMatteTypes;
            
        }
        
        [self.session commitConfiguration];
    });
    
}

-(void)onClickCancel1:(id)sender {
    [self uiPicture];
}
-(void)onClickComplete1:(id)sender {
    UIImage* image = self.cropView.croppedImage;
    CGSize size = CGSizeMake(1024, 1024);
    UIGraphicsBeginImageContext(size);
    [image drawInRect:CGRectMake(0, 0, size.width, size.height)];
    image = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    
    NSString* filePath = self.targetImagePath;
    NSData *imageData = UIImageJPEGRepresentation(image, 0.6f);
    [imageData writeToFile:filePath atomically:YES];
    
    [self.navigationController popViewControllerAnimated:YES];
    if(self.delegate)
        [self.delegate completeCapture:self result:[@{
            @"image": filePath
        } mutableCopy]];
}

-(void)onClickCancel2:(id)sender {
    [self uiRecord];
}
-(void)onClickComplete2:(id)sender {
    [self.navigationController popViewControllerAnimated:YES];
    if(self.delegate)
        [self.delegate completeCapture:self result:[@{
            @"video": self.targetVideoPathMp4,
            @"preview": self.targetPreviewPath
        } mutableCopy]];
}

-(void)onClickBack:(id)sender {
    [self.navigationController popViewControllerAnimated:YES];
    if(self.delegate)
        [self.delegate completeCapture:self result:nil];
}



-(void)onClickGallery:(id)sender {
    UIImagePickerController *picker = [[UIImagePickerController alloc] init];
    picker.sourceType = UIImagePickerControllerSourceTypePhotoLibrary;
    if(self.video)
        picker.mediaTypes = [[NSArray alloc] initWithObjects:(NSString *)kUTTypeMovie, nil];
    else
        picker.mediaTypes = [[NSArray alloc] initWithObjects:(NSString *)kUTTypeImage, nil];

    picker.delegate = self;
    [self presentViewController:picker animated:YES completion:nil];
}

- (BOOL)checkDuration:(NSString*)path {
    float duration = [DevilUtil getDuration:path];
    if(duration > self.maxSec) {
        [self showAlert:[NSString stringWithFormat:@"%d초 미만의 동영상을 올려주세요", self.maxSec]];
        [self uiRecord];
        return NO;
    } else if(duration < self.minSec) {
        [self showAlert:[NSString stringWithFormat:@"%d초 이상의 동영상을 올려주세요", self.minSec]];
        [self uiRecord];
        return NO;
    }
    
    return YES;
}

- (void)imagePickerController:(UIImagePickerController *)picker didFinishPickingMediaWithInfo:(NSDictionary<UIImagePickerControllerInfoKey, id> *)info{
    [picker dismissViewControllerAnimated:YES completion:^{
        if(self.video){
            NSURL* videoUrl = info[UIImagePickerControllerMediaURL];
            [videoUrl startAccessingSecurityScopedResource];
            NSString* path = videoUrl.path;
            if(![[NSFileManager defaultManager] fileExistsAtPath:path]) {
                [self showAlert:@"파일 없음"];
                return ;
            }
            
            if([self checkDuration:path]) {
                if([[NSFileManager defaultManager] fileExistsAtPath:self.targetVideoPathMovCopy])
                    [[NSFileManager defaultManager] removeItemAtPath:self.targetVideoPathMovCopy error:nil];
                [[NSFileManager defaultManager] copyItemAtPath:path toPath:self.targetVideoPathMovCopy error:nil];
                UIImage* preview = [DevilUtil getThumbnail:self.targetVideoPathMovCopy];
                NSData *imageData = UIImageJPEGRepresentation(preview, 0.6f);
                [imageData writeToFile:self.targetPreviewPath atomically:YES];
                [DevilUtil convertMovToMp4:self.targetVideoPathMovCopy to:self.targetVideoPathMp4 callback:^(id  _Nonnull res) {
                    if([res[@"r"] boolValue]){
                        [self.videoView setPreview:self.targetPreviewPath video:self.targetVideoPathMp4 force:YES];
                        [self.videoView play];
                    } else {
                        [self showAlert:@"Record Failed"];
                        [self uiRecord];
                    }
                }];
                [self uiRecorded];
            }
        } else {
            UIImage* photo = info[UIImagePickerControllerOriginalImage];
            if(photo.imageOrientation == UIImageOrientationRight)
                photo = [DevilUtil rotateImage:photo degrees:90];
            else if(photo.imageOrientation == UIImageOrientationLeft)
                photo = [DevilUtil rotateImage:photo degrees:-90];
            else if(photo.imageOrientation != nil && photo.imageOrientation == UIImageOrientationUp)
                photo = [DevilUtil rotateImage:photo degrees:180];
            
            [self uiTaken];
            [self.cropView setImage:photo];
        
        }
    }];
}

- (void)imagePickerControllerDidCancel:(UIImagePickerController *)picker{
    [picker dismissViewControllerAnimated:YES completion:^{
        
    }];
}

-(void)showAlert:(NSString*)msg
{
    UIAlertController *alertController = [UIAlertController alertControllerWithTitle:msg
                                                                             message:nil
                                                                      preferredStyle:UIAlertControllerStyleAlert];

    [alertController addAction:[UIAlertAction actionWithTitle:@"확인"
                                                      style:UIAlertActionStyleCancel
                                                    handler:^(UIAlertAction *action) {
                                                        
    }]];
    [self presentViewController:alertController animated:YES completion:^{}];
}
@end
