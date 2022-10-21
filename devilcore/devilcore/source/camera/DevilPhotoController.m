//
//  DevilPhotoController.m
//  devilcore
//
//  Created by Mu Young Ko on 2022/09/18.
//

#import "DevilPhotoController.h"
@import Photos;

@interface DevilPhotoController () <UIScrollViewDelegate>
@property (nonatomic, retain) NSString* currentUrl;
@property (nonatomic, retain) UIImageView* imageView;
@property (nonatomic, retain) UIScrollView* scrollView;
@end

@implementation DevilPhotoController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.view.backgroundColor = [UIColor blackColor];
    self.title = @"";
    
    [self.navigationController setNavigationBarHidden:NO animated:YES];
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    
    float sw = self.view.frame.size.width;
    float sh = self.view.frame.size.height;
    
    if(!self.imageView) {
        UIImageView* image = [[UIImageView alloc] init];
        self.imageView = image;
        
        self.imageView.contentMode = UIViewContentModeScaleAspectFit;
        
        self.scrollView = [[UIScrollView alloc] initWithFrame:CGRectMake(0, 0, sw, sh)];
        self.scrollView.bounces = NO;
        self.scrollView.bouncesZoom = NO;
        self.scrollView.clipsToBounds = NO;
        self.scrollView.autoresizesSubviews = NO;
        _scrollView.userInteractionEnabled = YES;
        _scrollView.scrollEnabled = YES;
        _scrollView.contentSize = self.imageView.frame.size;
        _scrollView.delegate = self;
        
        [self.view addSubview:_scrollView];
        [_scrollView addSubview:self.imageView];
        
        self.imageView.frame = CGRectMake(0, 0, sw*4, sh*4);
        self.scrollView.frame = CGRectMake(0, 0, sw, sh);
        
        self.scrollView.minimumZoomScale = 1.0f / 4.0f;
        self.scrollView.maximumZoomScale = 3;
        self.scrollView.zoomScale = 1.0f / 4.0f;
        
        _scrollView.contentSize = self.imageView.frame.size;
        [self loadImage:self.param[@"url"] :self.imageView];
        
        [self constructNavigationButton];
    }
}


- (UIView *)viewForZoomingInScrollView:(UIScrollView *)scrollView {
    return self.imageView;
}
- (void)scrollViewDidZoom:(UIScrollView *)scrollView {
    NSLog(@"scrollViewDidZoom %f", scrollView.zoomScale);
}

- (void)loadImage:(NSString*)url :(UIImageView*)imageView {
    if(url == nil){
        [imageView setImage:nil];
        [imageView setNeedsDisplay];
    }
    
    if([url isEqualToString:self.currentUrl])
        return;
    
    [imageView setImage:nil];
    [imageView setNeedsDisplay];
    
    if([url hasPrefix:@"/"]) {
        
        if([[NSFileManager defaultManager] fileExistsAtPath:url])
            [imageView setImage:[UIImage imageWithContentsOfFile:url]];
        else {
            url = [DevilUtil replaceUdidPrefixDir:url];
            [imageView setImage:[UIImage imageWithContentsOfFile:url]];
        }
    } else if([url hasPrefix:@"gallery://"]) {
        if(![url isEqualToString:self.currentUrl]) {
            PHImageRequestOptions* requestOptions = [[PHImageRequestOptions alloc] init];
            requestOptions.resizeMode   = PHImageRequestOptionsResizeModeExact;
            requestOptions.deliveryMode = PHImageRequestOptionsDeliveryModeHighQualityFormat;
            // this one is key
            requestOptions.synchronous = NO;

            PHImageManager *manager = [PHImageManager defaultManager];

            PHFetchResult *results = [PHAsset fetchAssetsWithLocalIdentifiers:@[[url stringByReplacingOccurrencesOfString:@"gallery://" withString:@""]] options:nil];
            
            CGRect rect = imageView.frame;
            [results enumerateObjectsUsingBlock:^(PHAsset *obj, NSUInteger idx, BOOL * _Nonnull stop) {
                [manager requestImageForAsset:obj
                                   targetSize:rect.size
                                  contentMode:PHImageContentModeAspectFill
                                      options:requestOptions
                                resultHandler:^void(UIImage *image, NSDictionary *info) {
                                    [imageView setImage:image];
                }];
                *stop = true;
            }];
        }
    } else {
        [[WildCardConstructor sharedInstance].delegate loadNetworkImageView:imageView withUrl:url];
    }
}


- (void)constructNavigationButton {
    NSBundle *bundle = [NSBundle bundleForClass:[self class]];
    
    UIImage *image_back = [UIImage imageNamed:@"devil_camera_close.png" inBundle:bundle compatibleWithTraitCollection:nil];
    image_back = [self resizeImage:image_back];
    image_back = [self tintColor:image_back :[UIColor whiteColor]];
    //UIButton *leftButton = [[UIButton alloc] initWithFrame:CGRectMake(0,0, 100,50)];
    UIButton *leftButton = [[UIButton alloc] initWithFrame:CGRectMake(20,20, 100,50)];
    leftButton.contentHorizontalAlignment = UIControlContentHorizontalAlignmentLeft;
    [leftButton setImage:image_back forState:UIControlStateNormal];
    [leftButton addTarget:self action:@selector(backClick:) forControlEvents:UIControlEventTouchUpInside];
//    self.navigationItem.leftBarButtonItems = @[[[UIBarButtonItem alloc] initWithCustomView:leftButton]];
    [self.view addSubview:leftButton];
    
}

- (void)backClick:(id)sender{
    [self dismissViewControllerAnimated:YES completion:^{
        
    }];
    //[self.navigationController popViewControllerAnimated:YES];
}

- (UIImage *)resizeImage:(UIImage *)image {
    CGSize newSize = CGSizeMake(image.size.width/2, image.size.height/2);
    UIGraphicsBeginImageContextWithOptions(newSize, NO, 0.0);
    [image drawInRect:CGRectMake(0, 0, newSize.width, newSize.height)];
    UIImage *newImage = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    return newImage;
}

-(UIImage*)tintColor:(UIImage*)image_complete :(UIColor*)color {
    UIGraphicsBeginImageContextWithOptions(image_complete.size, NO, image_complete.scale);
    CGContextRef context = UIGraphicsGetCurrentContext();
    [color setFill];
    CGContextTranslateCTM(context, 0, image_complete.size.height);
    CGContextScaleCTM(context, 1.0, -1.0);
    CGContextClipToMask(context, CGRectMake(0, 0, image_complete.size.width, image_complete.size.height), [image_complete CGImage]);
    CGContextFillRect(context, CGRectMake(0, 0, image_complete.size.width, image_complete.size.height));
    UIImage *coloredImg = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    return coloredImg;
}

- (void)willTransitionToTraitCollection:(UITraitCollection *)newCollection withTransitionCoordinator:(id<UIViewControllerTransitionCoordinator>)coordinator {
    NSLog(@"willTransitionToTraitCollection %@" , self.projectId);
}

- (void)viewWillTransitionToSize:(CGSize)size withTransitionCoordinator:(id<UIViewControllerTransitionCoordinator>)coordinator{
    NSLog(@"viewWillTransitionToSize %@" , self.projectId);
    
}


@end
