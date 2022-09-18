//
//  DevilPhotoController.m
//  devilcore
//
//  Created by Mu Young Ko on 2022/09/18.
//

#import "DevilPhotoController.h"
@import Photos;

@interface DevilPhotoController ()
@property (nonatomic, retain) NSString* currentUrl;
@end

@implementation DevilPhotoController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.view.backgroundColor = [UIColor blackColor];
    self.title = @"";
    
    
    UIImageView* v = [[UIImageView alloc] init];
    float sw = [UIScreen mainScreen].bounds.size.width;
    float sh = [UIScreen mainScreen].bounds.size.height;
    v.frame = CGRectMake(0, 0, sw, sh/2);
    [self.view addSubview:v];
    v.center = CGPointMake(self.view.frame.size.width/2, self.view.frame.size.height/2);
    
    [self.navigationController setNavigationBarHidden:NO animated:YES];
    
    [self constructNavigationButton];
    
    [self loadImage:self.param[@"url"] :v];
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


@end
