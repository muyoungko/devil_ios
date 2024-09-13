//
//  DevilQrCameraController.m
//  devilcore
//
//  Created by Mu Young Ko on 2021/08/21.
//

#import "DevilQrCameraController.h"
#import "WildCardConstructor.h"
#import "JevilInstance.h"
#import "DevilController.h"

@interface DevilQrCameraController()<WildCardConstructorInstanceDelegate>

@property (nonatomic, strong) WildCardUIView* mainVc;
@property (nonatomic, strong) ZXCapture *capture;
@property (nonatomic, weak) IBOutlet UIView *scanRectView;
@property (nonatomic, weak) IBOutlet UILabel *decodedLabel;
@property NSTimeInterval lastCaptureTime;
@property (nonatomic, strong) AVAudioPlayer* beepPlayer;

@end

@implementation DevilQrCameraController


- (void)viewDidLoad {
    [super viewDidLoad];
    
    callbacked = NO;
    
    self.capture = [[ZXCapture alloc] init];
    if(self.front)
        self.capture.camera = self.capture.front;
    else
        self.capture.camera = self.capture.back;
    
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
        self.mainVc.backgroundColor = [UIColor clearColor];
        
        [WildCardConstructor applyRule:self.mainVc withData:[JevilInstance currentInstance].data];
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
        
        if([rootView superview] == nil && rootView != self.view)
            [self.view addSubview:rootView];
        
        float sw = [UIScreen mainScreen].bounds.size.width;
        float sh = [UIScreen mainScreen].bounds.size.height;
        
        int BTN_SIZE = 30;
        UIButton* cancel = [rootView viewWithTag:333];
        [cancel addTarget:self action:@selector(buttonCancel:) forControlEvents:UIControlEventTouchUpInside];
        UIImage* back = [[UIImage imageNamed:@"devil_camera_cancel" inBundle:bundle compatibleWithTraitCollection:nil] imageWithRenderingMode:UIImageRenderingModeAlwaysTemplate];
        [cancel setImage:back forState:UIControlStateNormal];
        cancel.frame = CGRectMake(23, 23, BTN_SIZE, BTN_SIZE);
        
        UIButton* front = [rootView viewWithTag:34];
        [front addTarget:self action:@selector(buttonFrontBack:) forControlEvents:UIControlEventTouchUpInside];
        UIImage* front_back = [[UIImage imageNamed:@"devil_camera_front_back" inBundle:bundle compatibleWithTraitCollection:nil] imageWithRenderingMode:UIImageRenderingModeAlwaysTemplate];
        [front setImage:front_back forState:UIControlStateNormal];
        front.frame = CGRectMake(sw - BTN_SIZE - 23, 23, BTN_SIZE, BTN_SIZE);
         
        
        UIView* top = [[UIView alloc] initWithFrame:CGRectMake(0,0, sw, 200)];
        top.backgroundColor = [UIColor blackColor];
        top.alpha = 0.3;
        [rootView addSubview:top];
        
        UIView* bottom = [[UIView alloc] initWithFrame:CGRectMake(0, sh-300 , sw, 300)];
        bottom.backgroundColor = [UIColor blackColor];
        bottom.alpha = 0.3;
        [rootView addSubview:bottom];
        
        UILabel* text = [rootView viewWithTag:444];
        
        [[text superview] bringSubviewToFront:text];
        [[cancel superview] bringSubviewToFront:cancel];
        [[front superview] bringSubviewToFront:front];
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
    
    NSTimeInterval now = [[NSDate date] timeIntervalSince1970];
    if(now - self.lastCaptureTime > 2)
    {
        self.lastCaptureTime = now;
        callbacked = YES;
        if(self.finish)
            [self dismissViewControllerAnimated:YES completion:nil];
        [self playBeep];
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


- (void)playBeep{
    NSBundle *bundle = [NSBundle bundleForClass:[self class]];
    NSString *path = [bundle pathForResource:@"devil_camera_record" ofType:@"wav"];
    
    NSError *error;
    self.beepPlayer = [[AVAudioPlayer alloc]initWithContentsOfURL:[NSURL fileURLWithPath:path] error:&error];
    self.beepPlayer.numberOfLoops = 1;
    [self.beepPlayer play];
}

-(BOOL)onInstanceCustomAction:(WildCardMeta *)meta function:(NSString*)functionName args:(NSArray*)args view:(WildCardUIView*) node{
    DevilController* dc = (DevilController*)[JevilInstance currentInstance].vc;
    WildCardMeta* parentMeta = dc.mainWc.meta;
    [dc onInstanceCustomAction:parentMeta function:functionName args:args view:node];
    return YES;
}
@end
