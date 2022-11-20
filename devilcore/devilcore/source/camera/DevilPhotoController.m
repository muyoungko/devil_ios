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

@property (nonatomic, retain) UICollectionView* collectionView;
@property (nonatomic, retain) NSString* url;
@property (nonatomic, retain) NSArray* urls;
@property int selectedIndex;

@property BOOL single;
@end

@implementation DevilPhotoController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.view.backgroundColor = [UIColor blackColor];
    self.title = @"";
    self.single = self.param[@"urls"]?false:true;
    self.url = self.param[@"url"];
    self.urls = self.param[@"urls"];
    [self.navigationController setNavigationBarHidden:NO animated:YES];
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    
    float sw = self.view.frame.size.width;
    float sh = self.view.frame.size.height;
    
    
    if(self.single) {
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
    } else {
        if(!self.collectionView) {
            
            UICollectionViewFlowLayout* flowLayout = [[UICollectionViewFlowLayout alloc] init];
            flowLayout.itemSize = CGSizeMake(100, 100);
            [flowLayout setScrollDirection:UICollectionViewScrollDirectionHorizontal];
            CGRect containerRect = CGRectMake(0, 0, sw, sh);
            containerRect.origin.x = containerRect.origin.y = 0;
            self.collectionView = [[UICollectionView alloc] initWithFrame:containerRect collectionViewLayout:flowLayout];
            self.collectionView.frame = CGRectMake(0, 0, sw, sh);
            self.collectionView.delegate = self;
            self.collectionView.dataSource = self;
            
            [self.collectionView registerClass:[UICollectionViewCell class] forCellWithReuseIdentifier:@"picture"];
            
            [self.collectionView setShowsHorizontalScrollIndicator:NO];
            [self.collectionView setShowsVerticalScrollIndicator:NO];
            
            [self.view addSubview:self.collectionView];
            self.view.backgroundColor = [UIColor blackColor];
            
            [self constructNavigationButton];
            
            int startIndex = 0;
            for(int i=0;i<[self.urls count];i++) {
                if([self.urls[i] isEqualToString:self.url]){
                    startIndex = i;
                    break;
                }
            }
            if(startIndex > 0) {
                [self.collectionView scrollToItemAtIndexPath:[NSIndexPath indexPathForItem:startIndex inSection:0] atScrollPosition:UICollectionViewScrollPositionCenteredHorizontally animated:NO];
            }
        }
    }
}


- (NSInteger)numberOfSectionsInCollectionView:(UICollectionView *)collectionView{
    return 1;
}

- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section
{
    return self.urls? [self.urls count] : 0;
}

- (CGFloat)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout*)collectionViewLayout minimumLineSpacingForSectionAtIndex:(NSInteger)section
{
    return 0;
}

- (CGFloat)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout*)collectionViewLayout minimumInteritemSpacingForSectionAtIndex:(NSInteger)section
{
    return 0;
}

- (CGSize)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout*)collectionViewLayout sizeForItemAtIndexPath:(NSIndexPath *)indexPath {
    float sw = self.view.frame.size.width;
    float sh = self.view.frame.size.height;
    return CGSizeMake(sw, sh);
}

- (__kindof UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath
{
    int position = (int)[indexPath row];
    NSString* thisUrl = _urls[position];
    NSString* type = @"picture";
    UICollectionViewCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:type forIndexPath:indexPath];
    
    UIView* childUIView = cell;
    if ([[[UIDevice currentDevice] systemVersion] floatValue] >= 14.0) {
        childUIView = cell;
    } else {
        childUIView = [[cell subviews] objectAtIndex:0];
    }
    
    float s = childUIView.frame.size.width;
    float sw = self.view.frame.size.width;
    float sh = self.view.frame.size.height;
    
    //construct
    if([[childUIView subviews] count] == 0)
    {
        //[UIView ]
        childUIView.backgroundColor = UIColorFromRGB(0x000000);
        UIImageView* image = [[UIImageView alloc] initWithFrame:CGRectMake(0, 0, sw, sh)];
        image.contentMode = UIViewContentModeScaleAspectFit;
        image.tag = 13123;
        [childUIView addSubview:image];
    }
    UIImageView* imageView = [childUIView viewWithTag:13123];
    [self loadImage:thisUrl:imageView];
    
    return cell;
}

- (void)scrollViewWillEndDragging:(UIScrollView *)scrollView withVelocity:(CGPoint)velocity targetContentOffset:(inout CGPoint *)targetContentOffset {
    float w = scrollView.frame.size.width;
    float offset = targetContentOffset->x;
    
    //뷰페이저
    float start = 0;
    float contentWidth = self.view.frame.size.width;
    if(self.collectionView){
        targetContentOffset->x = scrollView.contentOffset.x;
        int newIndex = _selectedIndex;
        if(velocity.x > 0.5 || velocity.x < -0.5){
            int sindex = (scrollView.contentOffset.x - start + contentWidth/2) / contentWidth;
            int direction = velocity.x > 0.0 ? 1 : -1;
            int tobeIndex = sindex+direction;
            if(tobeIndex < 0 )
                tobeIndex = 0;
            else if(tobeIndex > [_urls count] -1 )
                tobeIndex = [_urls count] -1;
            newIndex = tobeIndex;
            float tobe = -start + contentWidth*(tobeIndex);
            [UIView animateWithDuration:0.3 delay:0 options:UIViewAnimationOptionAllowUserInteraction animations:^{
                scrollView.contentOffset = CGPointMake(tobe, 0);
                [scrollView layoutIfNeeded];
            } completion:nil];
        }
        else
        {
            int sindex = (offset - start + contentWidth/2) / contentWidth;
            newIndex = sindex;
            [self.collectionView scrollToItemAtIndexPath:[NSIndexPath indexPathForRow:sindex inSection:0] atScrollPosition:UICollectionViewScrollPositionCenteredHorizontally animated:YES];
        }
        
        _selectedIndex = newIndex;
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
