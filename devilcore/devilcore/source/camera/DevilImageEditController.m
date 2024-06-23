//
//  DevilImageEditController.m
//  devilcore
//
//  Created by Mu Young Ko on 2024/06/22.
//

#import "DevilImageEditController.h"
#import "PECropView.h"
#import "DevilUtil.h"
#import "DevilDownloader.h"
#import "DevilDebugView.h"

@interface DevilImageEditController ()

@property (nonatomic, retain) PECropView* cropView;
@property int degree;
@property (nonatomic, retain) UIImage* image;
@end

@implementation DevilImageEditController

- (void)viewDidLoad {
    [super viewDidLoad];
    [self hideNavigationBar];
    
    self.view.backgroundColor = [UIColor blackColor];
    float sw = [UIScreen mainScreen].bounds.size.width;
    float sh = [UIScreen mainScreen].bounds.size.height;
    
    self.cropView = [[PECropView alloc] initWithFrame:CGRectMake(0, 75, sw, sh-150)];
    [self.cropView construct:@{@"enableChangeGuide":@TRUE}];
    self.cropView.ratio = 0.0f;
    self.cropView.keepingCropAspectRatio = NO;
    
    [self.view addSubview:self.cropView];
    self.view.clipsToBounds = YES;
    
    NSBundle *bundle = [NSBundle bundleForClass:[self class]];
    int w = 50;
    int h = 50;
    int gap = 20;
    {
        UIColor* color = [UIColor redColor];
        UIButton * b = [[UIButton alloc] initWithFrame:CGRectMake(sw/2 - w - gap, sh-h-60, w, h)];
        [self.view addSubview:b];
        b.tintColor = b.imageView.tintColor = color;
        UIImage* image = [[UIImage imageNamed:@"devil_camera_cancel.png" inBundle:bundle compatibleWithTraitCollection:nil] imageWithRenderingMode:UIImageRenderingModeAlwaysTemplate];
        [b setImage:image forState:UIControlStateNormal];
        [b addTarget:self action:@selector(onClickCancel) forControlEvents:UIControlEventTouchUpInside];
    }
    
    {
        UIColor* color = UIColorFromRGB(0x3cb043);
        UIButton * b = [[UIButton alloc] initWithFrame:CGRectMake(sw/2 + gap, sh-h-60, w, h)];
        [self.view addSubview:b];
        b.tintColor = b.imageView.tintColor = color;
        UIImage* image = [[UIImage imageNamed:@"devil_camera_complete.png" inBundle:bundle compatibleWithTraitCollection:nil] imageWithRenderingMode:UIImageRenderingModeAlwaysTemplate];
        [b setImage:image forState:UIControlStateNormal];
        [b addTarget:self action:@selector(onClickComplete) forControlEvents:UIControlEventTouchUpInside];
    }
    
    {
        UIColor* color = UIColorFromRGB(0xffffff);
        UIButton * b = [[UIButton alloc] initWithFrame:CGRectMake(sw - w, 80, w-20, h-20)];
        [self.view addSubview:b];
        b.tintColor = b.imageView.tintColor = color;
        UIImage* image = [[UIImage imageNamed:@"devil_camera_front_back.png" inBundle:bundle compatibleWithTraitCollection:nil] imageWithRenderingMode:UIImageRenderingModeAlwaysTemplate];
        [b setImage:image forState:UIControlStateNormal];
        [b addTarget:self action:@selector(onClickRotate) forControlEvents:UIControlEventTouchUpInside];
    }
    
    
    [self showIndicator];
    
    NSString* url = _param[@"url"];
    DevilDownloader* downloder = [[DevilDownloader alloc] init];
    [downloder download:false url:url header:@{} filePath:nil progress:^(id  _Nonnull res) {
        
    } complete:^(id  _Nonnull res) {
        [self hideIndicator];
        if([res[@"r"] boolValue]) {
            NSString* path = res[@"dest"];
            NSString* pathEncoding = res[@"dest_encoding"];
            NSData *data = [[NSFileManager defaultManager] contentsAtPath:pathEncoding];
            self.image = [UIImage imageWithData:data];
            [self.cropView setImage:self.image];
            
        } else {
            [self onClickCancel];
        }
    }];
}

-(void)onClickCancel {
    self.callback(@{
        @"r":@FALSE
    });
    [self.navigationController popViewControllerAnimated:YES];
    self.callback = nil;
}

-(void)onClickRotate {
    self.degree += 90;
    self.degree = self.degree % 360;
    if(self.degree == 0)
        self.image = [UIImage imageWithCGImage:self.image.CGImage scale:1 orientation:UIImageOrientationUp];
    else if(self.degree == 90)
        self.image = [UIImage imageWithCGImage:self.image.CGImage scale:1 orientation:UIImageOrientationRight];
    else if(self.degree == 180)
        self.image = [UIImage imageWithCGImage:self.image.CGImage scale:1 orientation:UIImageOrientationDown];
    else if(self.degree == 270)
        self.image = [UIImage imageWithCGImage:self.image.CGImage scale:1 orientation:UIImageOrientationLeft];
    [self.cropView setImage:self.image];
    
}

-(void)onClickComplete {
    UIImage* image = self.cropView.croppedImage;
    NSData *imageData = UIImageJPEGRepresentation(image, 1.0f);
    NSString* outputFileName = [NSUUID UUID].UUIDString;
    NSString* filePath = [NSTemporaryDirectory() stringByAppendingPathComponent:[outputFileName stringByAppendingPathExtension:@"jpg"]];
    [imageData writeToFile:filePath atomically:YES];
    
    //self.cropView.cropRect
    CGRect rect = self.cropView.zoomedCropRect;
    [self.navigationController popViewControllerAnimated:YES];
    
    
    id r = @{
        @"r":@TRUE,
        @"path":filePath,
        @"x":[NSNumber numberWithFloat:rect.origin.x],
        @"y":[NSNumber numberWithFloat:rect.origin.y],
        @"w":[NSNumber numberWithFloat:rect.size.width],
        @"h":[NSNumber numberWithFloat:rect.size.height],
        @"degree":[NSNumber numberWithInt:self.degree],
    };
    [[DevilDebugView sharedInstance] log:@"DevilImageEdit" title:@"DevilImageEdit" log:r];
    self.callback(r);
    self.callback = nil;
}

- (void)hideNavigationBar{
    [self.navigationController setNavigationBarHidden:YES animated:YES];
}

@end
