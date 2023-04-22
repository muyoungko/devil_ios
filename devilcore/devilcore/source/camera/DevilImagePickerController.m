//
//  DevilImagePickerController.m
//  devilcore
//
//  Created by Mu Young Ko on 2022/09/21.
//

#import "DevilImagePickerController.h"
#import "WildCardConstructor.h"
#import "DevilUtil.h"

@import Photos;
@import AVFoundation;
@import AVKit;

@interface DevilImagePickerController ()<UIImagePickerControllerDelegate>

@property (nonatomic) BOOL pictureTakening;
@property (nonatomic) float oldVolume;
@property (nonatomic, retain) UIView* over;
@property (nonatomic, retain) NSMutableArray* photoList;

@end

@implementation DevilImagePickerController

- (void)viewDidLoad {
    [super viewDidLoad];   
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    [[NSNotificationCenter defaultCenter] addObserver:self
                                      selector:@selector(volumeDown:)
                                      name:@"_UIApplicationVolumeDownButtonDownNotification"
                                      object:nil];
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(orientationChanged:) name:UIDeviceOrientationDidChangeNotification object:nil];
}

- (void)volumeDown:(id)s {
    [self takePicture];
}

- (void)viewWillDisappear:(BOOL)animated {
    [super viewWillDisappear:animated];
    [[NSNotificationCenter defaultCenter] removeObserver:self name:@"_UIApplicationVolumeDownButtonDownNotification" object:nil];
    [[NSNotificationCenter defaultCenter] removeObserver:self name:UIDeviceOrientationDidChangeNotification object:nil];
}

- (BOOL)shouldAutorotate {
    return NO;
}

- (UIInterfaceOrientationMask)supportedInterfaceOrientations{
    if(self.landscape){
        NSLog(@"supportedInterfaceOrientations landscape");
        return UIInterfaceOrientationMaskLandscapeLeft | UIInterfaceOrientationMaskLandscapeRight;
    } else {
        NSLog(@"supportedInterfaceOrientations portrait");
        return UIInterfaceOrientationMaskPortrait;
    }
}

- (UIInterfaceOrientation)preferredInterfaceOrientationForPresentation {
    if(self.landscape) {
        NSLog(@"preferredInterfaceOrientationForPresentation landscape");
        return UIInterfaceOrientationLandscapeLeft
        | UIInterfaceOrientationLandscapeRight;
    } else {
        NSLog(@"preferredInterfaceOrientationForPresentation portrait");
        return UIInterfaceOrientationPortrait;
    }
}

-(void)orientationChanged:(NSNotification*)noti {
    float sw = [UIScreen mainScreen].bounds.size.width;
    NSLog(@"orientationChanged sw - %f", sw);
    
    if([UIDevice currentDevice].orientation == UIDeviceOrientationLandscapeLeft ||
    [UIDevice currentDevice].orientation == UIDeviceOrientationLandscapeRight)
        self.actualLandscape = true;
    else
        self.actualLandscape = false;
    [self cameraOverlayUpdate:_over :_landscape : _showFrame : _rate];
    
    
}

-(void)construct {
    self.photoList = [@[] mutableCopy];
    BOOL isLandscape = [[UIApplication sharedApplication] statusBarOrientation] == UIDeviceOrientationLandscapeLeft ||
    [[UIApplication sharedApplication] statusBarOrientation] == UIDeviceOrientationLandscapeRight;
    self.actualLandscape = self.landscape = isLandscape;
    if(isLandscape)
        self.modalPresentationStyle = UIModalPresentationCurrentContext;
    
    self.sourceType = UIImagePickerControllerSourceTypeCamera;
    self.cameraFlashMode = UIImagePickerControllerCameraFlashModeAuto;
    self.over = [self cameraOverlay:isLandscape : _showFrame : _rate];
    self.cameraOverlayView = _over;
    self.showsCameraControls = NO;
    self.navigationBarHidden = YES;
    self.delegate = self;
}

-(void)constructOverlay {
    
    [self cameraOverlayUpdate:_over :_landscape : _showFrame : _rate];
    if([WildCardConstructor isTablet])
        ;
    else {
        if(_landscape)
            self.cameraViewTransform = CGAffineTransformMakeTranslation(0, 100);
        else
            self.cameraViewTransform = CGAffineTransformMakeTranslation(0, 100);
    }
    
}

- (UIView*)findViewOfClassName:(UIView*)p :(NSString*)name {
    NSString* className = [NSString stringWithFormat:@"%@", [p class]];
    if([className isEqualToString:name])
        return p;
    
    for(UIView* vv in [p subviews]){
        UIView* r = [self findViewOfClassName:vv :name];
        if(r)
            return r;
    }
    
    return nil;
}

-(UIView*)cameraOverlay:(BOOL)isLandscape :(BOOL)showFrame :(float)rate {
    NSBundle *bundle = [NSBundle bundleForClass:[self class]];
    UIView * r = nil;
    
    id arr = [bundle loadNibNamed:(isLandscape?@"devil_camera_system_landscape":@"devil_camera_system") owner:self options:NULL];
    r = [arr firstObject];
    
    float sw = [UIScreen mainScreen].bounds.size.width;
    float sh = [UIScreen mainScreen].bounds.size.height;
    //r.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
    r.frame = CGRectMake(0, 0, sw, sh);
    
    {
        UIColor* color = [UIColor whiteColor];
        UIButton * b = [r viewWithTag:8574];
        b.tintColor = b.imageView.tintColor = color;
        UIImage* image = [[UIImage imageNamed:@"devil_camera_shutter.png" inBundle:bundle compatibleWithTraitCollection:nil] imageWithRenderingMode:UIImageRenderingModeAlwaysTemplate];
        [b setImage:image forState:UIControlStateNormal];
        [b addTarget:self action:@selector(onClickTake:) forControlEvents:UIControlEventTouchUpInside];
    }
    
    {
        UIColor* color = [UIColor whiteColor];
        UIButton * b = [r viewWithTag:8575];
        b.tintColor = b.imageView.tintColor = color;
        UIImage* image = [[UIImage imageNamed:@"devil_camera_cancel.png" inBundle:bundle compatibleWithTraitCollection:nil] imageWithRenderingMode:UIImageRenderingModeAlwaysTemplate];
        [b setImage:image forState:UIControlStateNormal];
        [b addTarget:self action:@selector(onClickCancel) forControlEvents:UIControlEventTouchUpInside];
    }
    
    {
        UIColor* color = [UIColor whiteColor];
        UIButton * b = [r viewWithTag:8576];
        b.tintColor = b.imageView.tintColor = color;
        UIImage* image = [[UIImage imageNamed:@"devil_camera_complete.png" inBundle:bundle compatibleWithTraitCollection:nil] imageWithRenderingMode:UIImageRenderingModeAlwaysTemplate];
        [b setImage:image forState:UIControlStateNormal];
        [b addTarget:self action:@selector(onClickComplete) forControlEvents:UIControlEventTouchUpInside];
    }

    return r;
}

-(void)cameraOverlayUpdate:(UIView*)r :(BOOL)isLandscape :(BOOL)showFrame :(float)rate {
    UIView* previewView = [self findViewOfClassName:self.view :@"CAMPreviewView"];
    CGSize previewSize = CGSizeMake(0, 0);
    if(previewView)
        previewSize = CGSizeMake(previewView.frame.size.width, previewView.frame.size.height);
    
    int preview_offset = 100;
    if([WildCardConstructor isTablet])
        preview_offset = 0;
        
    if(showFrame) {
        [[r viewWithTag:1123] removeFromSuperview];
        [[r viewWithTag:1124] removeFromSuperview];
        
        float sw = [UIScreen mainScreen].bounds.size.width;
        float sh = [UIScreen mainScreen].bounds.size.height;
        if(isLandscape) {
            /**
             sw 932 sh 430 나옴
             카메라 previewSize는 573 430  나옴
             rate 0.8일때
             */
            //sw 932
            //sh 430 나옴
            //
            float frame_sw = sh/rate;
            float frame_sh = sh;
            if(!self.actualLandscape) {
                frame_sw = sh*rate;
                frame_sh = sh;
            }
            
            CGPoint previewCenter = CGPointMake(preview_offset + previewSize.width/2, sh/2);
            //폰에서는 previewSize가 가로세로가 반대로 나온다
            if(![WildCardConstructor isTablet])
                previewCenter = CGPointMake(preview_offset + previewSize.height/2, sh/2);
            
//            UIView* frame = [[UIView alloc] initWithFrame:CGRectMake(0, 0, frame_sw, frame_sh)];
//            frame.center = previewCenter;
//            frame.layer.borderColor = [UIColor blackColor].CGColor;
//            frame.layer.borderWidth = 2.0f;
//            [r addSubview:frame];
            
            UIView* left_frame = [[UIView alloc] initWithFrame:CGRectMake(0, 0, previewCenter.x-frame_sw/2, sh)];
            
            left_frame.backgroundColor = UIColorFromRGBA(0x95000000);
            [r addSubview:left_frame];
            
            UIButton * b = [r viewWithTag:8574];
            UIView* right_frame = [[UIView alloc] initWithFrame:CGRectMake(previewCenter.x+frame_sw/2, 0,
                                                                           sw - previewCenter.x - frame_sw/2, sh)];
            
            right_frame.backgroundColor = UIColorFromRGBA(0x95000000);
            right_frame.userInteractionEnabled = NO;
            
            left_frame.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
            right_frame.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
            
            [r addSubview:right_frame];
            
            left_frame.tag = 1124;
            right_frame.tag = 1123;
        } else {
            float frame_sw = sw;
            float frame_sh = sw*rate;
            if(self.actualLandscape) {
                frame_sw = sw;
                frame_sh = sw/rate;
            }
            
            /**
                iphone 11 기준 y:100 414:552
             */
            CGPoint previewCenter = CGPointMake(sw/2, preview_offset + previewSize.height/2);
            
//            UIView* frame = [[UIView alloc] initWithFrame:CGRectMake(0, 0, frame_sw, frame_sh)];
//            frame.center = previewCenter;
//            frame.layer.borderColor = [UIColor redColor].CGColor;
//            frame.layer.borderWidth = 2.0f;
//            [r addSubview:frame];
            
            
            UIView* top_frame = [[UIView alloc] initWithFrame:CGRectMake(0, 0, sw, previewCenter.y-frame_sh/2)];
            top_frame.backgroundColor = UIColorFromRGBA(0x95000000);
            [r addSubview:top_frame];
            
            UIView* bottom_frame = [[UIView alloc] initWithFrame:CGRectMake(0, previewCenter.y+frame_sh/2, sw,
                                                                            sh - previewCenter.y - frame_sh/2)];
            bottom_frame.backgroundColor = UIColorFromRGBA(0x95000000);
            bottom_frame.userInteractionEnabled = NO;
            
            top_frame.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
            bottom_frame.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
            
            [r addSubview:bottom_frame];
            
            top_frame.tag = 1124;
            bottom_frame.tag = 1123;
        }
        
        [r bringSubviewToFront:[r viewWithTag:8574]];
        [r bringSubviewToFront:[r viewWithTag:8575]];
        [r bringSubviewToFront:[r viewWithTag:8576]];
    }
}


-(void)onClickTake:(id)sender {
    [self takePicture];
}

-(void)onClickCancel {
    [self dismissViewControllerAnimated:YES completion:^{
        if(self.callback) {
            self.callback([@{
                @"r":@FALSE,
            } mutableCopy]);
            self.callback = nil;
        }
    }];
}
-(void)onClickComplete {
    [self dismissViewControllerAnimated:YES completion:^{
        if(self.callback) {
            self.callback([@{
                @"r":([self.photoList count] > 0 ? @TRUE:@FALSE),
                @"list":self.photoList
            } mutableCopy]);
            self.callback = nil;
        }
    }];
}

- (void)imagePickerController:(UIImagePickerController *)picker didFinishPickingMediaWithInfo:(NSDictionary<UIImagePickerControllerInfoKey, id> *)info{
    
    UIImage* photo = info[UIImagePickerControllerOriginalImage];
    NSString* targetPath = [self savePhotoToJpegFile:photo];
    UIImageWriteToSavedPhotosAlbum(photo, self, @selector(image:didFinishSavingWithError:contextInfo:), nil);

    [self.photoList addObject:[@{
        @"type":@"image",
        @"image" :targetPath,
    } mutableCopy]];
}

- (void)image:(UIImage *)image didFinishSavingWithError:(NSError *)error contextInfo:(void *)contextInfo {
    if (error) {
        NSLog(@"error: %@", [error localizedDescription]);
    } else {
        NSLog(@"saved");
    }
}

- (NSString*)savePhotoToJpegFile:(UIImage*)photo {
     id aaa = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
     NSString *prefix = aaa[0];
     NSString* outputFileName = [NSUUID UUID].UUIDString;
     NSString* targetPath = [prefix stringByAppendingPathComponent:[outputFileName stringByAppendingPathExtension:@"jpg"]];
     NSData *imageData = UIImageJPEGRepresentation(photo, 0.8f);
     [imageData writeToFile:targetPath atomically:YES];
    return targetPath;
}

@end
