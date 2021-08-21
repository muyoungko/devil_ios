//
//  DevilQrCameraController.m
//  devilcore
//
//  Created by Mu Young Ko on 2021/08/21.
//

#import "DevilQrCameraController.h"
#import "WildCardConstructor.h"


@interface DevilQrCameraController ()

@property (nonatomic, strong) WildCardUIView* mainVc;
@property (nonatomic, strong) ZXCapture *capture;
@property (nonatomic, weak) IBOutlet UIView *scanRectView;
@property (nonatomic, weak) IBOutlet UILabel *decodedLabel;
@property BOOL front;

@end

@implementation DevilQrCameraController


- (void)viewDidLoad {
    [super viewDidLoad];
    
    callbacked = NO;
    
    self.capture = [[ZXCapture alloc] init];
    self.capture.camera = self.capture.back;
    self.front = NO;
    
    self.capture.focusMode = AVCaptureFocusModeContinuousAutoFocus;
    
    [self.view.layer addSublayer:self.capture.layer];
    
//    [self.view bringSubviewToFront:self.scanRectView];
//    [self.view bringSubviewToFront:self.decodedLabel];
//    [self.view bringSubviewToFront:self.btnCancel];
}

- (void)construct {
    if(self.blockName) {
        id blockId = [[WildCardConstructor sharedInstance] getBlockIdByName:self.blockName];
        id cj = [[WildCardConstructor sharedInstance] getBlockJson:blockId];
        self.mainVc = [WildCardConstructor constructLayer:self.view withLayer:cj instanceDelegate:self];
        [WildCardConstructor applyRule:self.mainVc withData:[@{} mutableCopy]];
        WildCardMeta* meta = self.mainVc.meta;
        UIView* front = [meta getView:@"front"];
        UITapGestureRecognizer *buttonFrontRecognizer = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(buttonFrontBack:)];
        [WildCardConstructor userInteractionEnableToParentPath:front depth:10];
        front.userInteractionEnabled = YES;
        [front addGestureRecognizer:buttonFrontRecognizer];
        
        UIView* cancel = [meta getView:@"cancel"];
        UITapGestureRecognizer *buttonCancelRecognizer = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(buttonCancel:)];
        [WildCardConstructor userInteractionEnableToParentPath:cancel depth:10];
        cancel.userInteractionEnabled = YES;
        [cancel addGestureRecognizer:buttonCancelRecognizer];
        
    } else {
        NSBundle *bundle = [NSBundle bundleForClass:[self class]];
        UIView *rootView = [[bundle loadNibNamed:@"DevilQrCameraController" owner:self options:nil] objectAtIndex:0];
        [self.view addSubview:rootView];
        
        UIButton* cancel = [rootView viewWithTag:333];
        [cancel addTarget:self action:@selector(buttonCancel:) forControlEvents:UIControlEventTouchUpInside];
        
        UIButton* front = [rootView viewWithTag:34];
        [front addTarget:self action:@selector(buttonFrontBack:) forControlEvents:UIControlEventTouchUpInside];
    }
}

-(void)buttonCancel:(id)sender {
    [self dismissViewControllerAnimated:YES completion:nil];
}

-(void)buttonFrontBack:(id)sender {
    if(self.front) {
        self.front = NO;
        self.capture.camera = self.capture.back;
    } else {
        self.front = YES;
        self.capture.camera = self.capture.front;
    }
    
}

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    
    self.capture.delegate = self;
    
    [self applyOrientation];
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)toInterfaceOrientation {
    return toInterfaceOrientation == UIInterfaceOrientationPortrait;
}

- (void)didRotateFromInterfaceOrientation:(UIInterfaceOrientation)fromInterfaceOrientation {
    [super didRotateFromInterfaceOrientation:fromInterfaceOrientation];
    [self applyOrientation];
}


#pragma mark - Private
- (void)applyOrientation {
    UIInterfaceOrientation orientation = [[UIApplication sharedApplication] statusBarOrientation];
    float scanRectRotation;
    float captureRotation;
    
    switch (orientation) {
        case UIInterfaceOrientationPortrait:
        captureRotation = 0;
        scanRectRotation = 90;
        break;
        case UIInterfaceOrientationLandscapeLeft:
        captureRotation = 90;
        scanRectRotation = 180;
        break;
        case UIInterfaceOrientationLandscapeRight:
        captureRotation = 270;
        scanRectRotation = 0;
        break;
        case UIInterfaceOrientationPortraitUpsideDown:
        captureRotation = 180;
        scanRectRotation = 270;
        break;
        default:
        captureRotation = 0;
        scanRectRotation = 90;
        break;
    }
    [self applyRectOfInterest:orientation];
    CGAffineTransform transform = CGAffineTransformMakeRotation((CGFloat) (captureRotation / 180 * M_PI));
    [self.capture setTransform:transform];
    [self.capture setRotation:scanRectRotation];
    self.capture.layer.frame = self.view.frame;
}

- (void)applyRectOfInterest:(UIInterfaceOrientation)orientation {
    CGFloat scaleVideo, scaleVideoX, scaleVideoY;
    CGFloat videoSizeX, videoSizeY;
    CGRect transformedVideoRect = self.scanRectView.frame;
    if([self.capture.sessionPreset isEqualToString:AVCaptureSessionPreset1920x1080]) {
        videoSizeX = 1080;
        videoSizeY = 1920;
    } else {
        videoSizeX = 720;
        videoSizeY = 1280;
    }
    if(UIInterfaceOrientationIsPortrait(orientation)) {
        scaleVideoX = self.view.frame.size.width / videoSizeX;
        scaleVideoY = self.view.frame.size.height / videoSizeY;
        scaleVideo = MAX(scaleVideoX, scaleVideoY);
        if(scaleVideoX > scaleVideoY) {
            transformedVideoRect.origin.y += (scaleVideo * videoSizeY - self.view.frame.size.height) / 2;
        } else {
            transformedVideoRect.origin.x += (scaleVideo * videoSizeX - self.view.frame.size.width) / 2;
        }
    } else {
        scaleVideoX = self.view.frame.size.width / videoSizeY;
        scaleVideoY = self.view.frame.size.height / videoSizeX;
        scaleVideo = MAX(scaleVideoX, scaleVideoY);
        if(scaleVideoX > scaleVideoY) {
            transformedVideoRect.origin.y += (scaleVideo * videoSizeX - self.view.frame.size.height) / 2;
        } else {
            transformedVideoRect.origin.x += (scaleVideo * videoSizeY - self.view.frame.size.width) / 2;
        }
    }
    _captureSizeTransform = CGAffineTransformMakeScale(1/scaleVideo, 1/scaleVideo);
    self.capture.scanRect = CGRectApplyAffineTransform(transformedVideoRect, _captureSizeTransform);
}

#pragma mark - Private Methods

- (NSString *)barcodeFormatToString:(ZXBarcodeFormat)format {
    switch (format) {
        case kBarcodeFormatAztec:
        return @"Aztec";
        
        case kBarcodeFormatCodabar:
        return @"CODABAR";
        
        case kBarcodeFormatCode39:
        return @"Code 39";
        
        case kBarcodeFormatCode93:
        return @"Code 93";
        
        case kBarcodeFormatCode128:
        return @"Code 128";
        
        case kBarcodeFormatDataMatrix:
        return @"Data Matrix";
        
        case kBarcodeFormatEan8:
        return @"EAN-8";
        
        case kBarcodeFormatEan13:
        return @"EAN-13";
        
        case kBarcodeFormatITF:
        return @"ITF";
        
        case kBarcodeFormatPDF417:
        return @"PDF417";
        
        case kBarcodeFormatQRCode:
        return @"QR Code";
        
        case kBarcodeFormatRSS14:
        return @"RSS 14";
        
        case kBarcodeFormatRSSExpanded:
        return @"RSS Expanded";
        
        case kBarcodeFormatUPCA:
        return @"UPCA";
        
        case kBarcodeFormatUPCE:
        return @"UPCE";
        
        case kBarcodeFormatUPCEANExtension:
        return @"UPC/EAN extension";
        
        default:
        return @"Unknown";
    }
}

#pragma mark - ZXCaptureDelegate Methods
- (IBAction)onClickCancel:(id)sender
{
    [self dismissViewControllerAnimated:YES completion:nil];
}


- (void)captureResult:(ZXCapture *)capture result:(ZXResult *)result {
    if (!result) return;
    
    if(!callbacked)
    {
        callbacked = YES;
        [self dismissViewControllerAnimated:YES completion:nil];
        [_delegate captureResult:@{@"r":@TRUE, @"code":result.text}];
    }
    return;
    
    CGAffineTransform inverse = CGAffineTransformInvert(_captureSizeTransform);
    NSMutableArray *points = [[NSMutableArray alloc] init];
    NSString *location = @"";
    for (ZXResultPoint *resultPoint in result.resultPoints) {
        CGPoint cgPoint = CGPointMake(resultPoint.x, resultPoint.y);
        CGPoint transformedPoint = CGPointApplyAffineTransform(cgPoint, inverse);
        transformedPoint = [self.scanRectView convertPoint:transformedPoint toView:self.scanRectView.window];
        NSValue* windowPointValue = [NSValue valueWithCGPoint:transformedPoint];
        location = [NSString stringWithFormat:@"%@ (%f, %f)", location, transformedPoint.x, transformedPoint.y];
        [points addObject:windowPointValue];
    }
    
    
    // We got a result. Display information about the result onscreen.
    NSString *formatString = [self barcodeFormatToString:result.barcodeFormat];
    NSString *display = [NSString stringWithFormat:@"Scanned!\n\nFormat: %@\n\nContents:\n%@\nLocation: %@", formatString, result.text, location];
    [self.decodedLabel performSelectorOnMainThread:@selector(setText:) withObject:display waitUntilDone:YES];
    
    // Vibrate
    AudioServicesPlaySystemSound(kSystemSoundID_Vibrate);
    
    [self.capture stop];
    
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, 2 * NSEC_PER_SEC), dispatch_get_main_queue(), ^{
        [self.capture start];
    });
}

@end
