//
//  DevilGalleryController.m
//  devilcore
//
//  Created by Mu Young Ko on 2021/11/22.
//

#import "DevilGalleryController.h"
#import "DevilUtil.h"
#import "DevilCamera.h"

#define MARGIN 2
#define COL 3

@import Photos;

@interface DevilGalleryController ()
@property NSMutableArray* data;
@property NSMutableArray* selected;
@property NSString* titleText;
@property BOOL hasPicture;
@property BOOL hasVideo;
@property int max;
@property int min;
@property int minSec;
@property int maxSec;

@end

@implementation DevilGalleryController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    NSBundle *bundle = [NSBundle bundleForClass:[self class]];
    UIView *rootView = [[bundle loadNibNamed:@"DevilGalleryController" owner:self options:nil] objectAtIndex:0];
    [self.view addSubview:rootView];
    self.title = self.titleText = self.param && self.param[@"title"]? [self.param[@"title"] stringValue] : @"사진 선택";
    self.hasPicture = self.param && self.param[@"hasPicture"]? [self.param[@"hasPicture"] boolValue] : YES;
    self.hasVideo = self.param && self.param[@"hasVideo"] ? [self.param[@"hasVideo"] boolValue] : NO;
    self.min = self.param && self.param[@"min"]? [self.param[@"min"] intValue] : 1;
    self.max = self.param && self.param[@"max"]? [self.param[@"max"] intValue] : 10;
    self.minSec = self.param && self.param[@"minSec"]? [self.param[@"minSec"] intValue] : 3;
    self.maxSec = self.param && self.param[@"maxSec"]? [self.param[@"maxSec"] intValue] : 60;
    
    self.data = [@[] mutableCopy];
    self.selected = [@[] mutableCopy];
    [self.data addObject:[@{} mutableCopy]];
    
    [self constructNavigationButton];
    
    self.list.dataSource = self;
    self.list.delegate = self;
    [self.list registerClass:[UICollectionViewCell class] forCellWithReuseIdentifier:@"camera"];
    [self.list registerClass:[UICollectionViewCell class] forCellWithReuseIdentifier:@"picture"];
    
    [self showIndicator];
    [DevilCamera galleryList:self param:[@{
        @"hasPicture": self.hasPicture?@TRUE:@FALSE,
        @"hasVideo": self.hasVideo?@TRUE:@FALSE,
    } mutableCopy] callback:^(id  _Nonnull res) {
        [self hideIndicator];
        if(res && [res[@"r"] boolValue]) {
            [self.data addObjectsFromArray:res[@"list"]];
            [self.list reloadData];
        }
    }];
}
- (void)viewWillAppear:(BOOL)animated{
    [super viewWillAppear:animated];
    [self.navigationController setNavigationBarHidden:NO animated:YES];
    
    [self.navigationController.navigationBar setBarTintColor:[UIColor whiteColor]];
    [self.navigationController.navigationBar setBackgroundColor:[UIColor whiteColor]];
}

- (void)constructNavigationButton {
    NSBundle *bundle = [NSBundle bundleForClass:[self class]];
    
    UIImage *image_back = [UIImage imageNamed:@"devil_camera_cancel.png" inBundle:bundle compatibleWithTraitCollection:nil];
    image_back = [self resizeImage:image_back];
    UIButton *leftButton = [[UIButton alloc] initWithFrame:CGRectMake(0,0, 100,50)];
    leftButton.contentHorizontalAlignment = UIControlContentHorizontalAlignmentLeft;
    [leftButton setImage:image_back forState:UIControlStateNormal];
    [leftButton addTarget:self action:@selector(backClick:) forControlEvents:UIControlEventTouchUpInside];
    
    self.navigationItem.leftBarButtonItems = @[[[UIBarButtonItem alloc] initWithCustomView:leftButton]];
    
    UIImage *image_complete = [UIImage imageNamed:@"devil_camera_complete.png" inBundle:bundle compatibleWithTraitCollection:nil];
    image_complete = [self resizeImage:image_complete];
    UIButton *rightButton = [[UIButton alloc] initWithFrame:CGRectMake(0,0, 100,50)];
    rightButton.contentHorizontalAlignment = UIControlContentHorizontalAlignmentRight;
    
    UIColor* color = UIColorFromRGB(0x3cb043);
    UIImage *coloredImg = [self tintColor:image_complete :color];
    
    [rightButton setImage:coloredImg forState:UIControlStateNormal];
    [rightButton addTarget:self action:@selector(onClickComplete:) forControlEvents:UIControlEventTouchUpInside];
    UIBarButtonItem* b = [[UIBarButtonItem alloc] initWithCustomView:rightButton];
    self.navigationItem.rightBarButtonItems = @[b];
}

- (void)backClick:(id)sender{
    [self.navigationController popViewControllerAnimated:YES];
}

- (void)onClickComplete:(id)sender{
    if(self.min > [self.selected count]) {
        [self alert:[NSString stringWithFormat:@"%d개 이상 선택해주세요", self.min]];
        return;
    }
    
    if(self.max < [self.selected count]) {
        [self alert:[NSString stringWithFormat:@"%d개 이하로 선택해주세요", self.max]];
        return;
    }
    
    [self showIndicator];
    __block int completeCount = 0;
    __block int shouldCompelteCount = (int)[self.selected count];
    void (^complete_callback)() = ^() {
        if(completeCount == shouldCompelteCount) {
            [self hideIndicator];
            
            if(self.selected) {
                id r = [@{} mutableCopy];
                r[@"r"] = @TRUE;
                r[@"list"] = self.selected;
                [self.delegate completeCapture:self result:r];
                [self.navigationController popViewControllerAnimated:YES];
            }
        }
    };

    
    for(id s in self.selected) {
        s[@"selected"] = nil;
        NSString* type = s[@"type"];
        if([type isEqualToString:@"image"]) {
            if([s[@"url"] hasPrefix:@"gallery://"]){
                [self convertGalleryImagePathTo:s[@"url"] callback:^(id res) {
                    s[@"image"] = res[@"url"];
                    [s removeObjectForKey:@"url"];
                    completeCount++;
                    complete_callback();
                }];
            } else {
                s[@"image"] = s[@"url"];
                [s removeObjectForKey:@"url"];
                completeCount ++;
                complete_callback();
            }
        } else {
            if([s[@"url"] hasPrefix:@"gallery://"]){
                [self convertGalleryVideoPathTo:s[@"url"] callback:^(id res) {
                    s[@"video"] = res[@"url"];
                    [s removeObjectForKey:@"url"];
                    s[@"preview"] = res[@"preview"];
                    completeCount++;
                    complete_callback();
                }];
            } else {
                s[@"video"] = s[@"url"];
                [s removeObjectForKey:@"url"];
                completeCount ++;
                complete_callback();
            }
        }
    }
}

-(void)completeCheck {
    
}

- (NSInteger)numberOfSectionsInCollectionView:(UICollectionView *)collectionView{
    return 1;
}

- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section
{
    return [_data count];
}

- (CGFloat)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout*)collectionViewLayout minimumLineSpacingForSectionAtIndex:(NSInteger)section
{
    return MARGIN;
}

- (CGFloat)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout*)collectionViewLayout minimumInteritemSpacingForSectionAtIndex:(NSInteger)section
{
    return MARGIN;
}

- (CGSize)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout*)collectionViewLayout sizeForItemAtIndexPath:(NSIndexPath *)indexPath {
    float s = ([UIScreen mainScreen].bounds.size.width - MARGIN*(COL)) / COL;
    return CGSizeMake(s, s);
}

- (__kindof UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath
{
    int position = (int)[indexPath row];
    
    NSMutableDictionary* item = [_data objectAtIndex:position];
    NSString* type = position == 0 ? @"camera":@"picture";
    UICollectionViewCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:type forIndexPath:indexPath];
    
    UIView* childUIView = cell;
    if ([[[UIDevice currentDevice] systemVersion] floatValue] >= 14.0) {
        childUIView = cell;
    } else {
        childUIView = [[cell subviews] objectAtIndex:0];
    }
    
    float s = childUIView.frame.size.width;
    
    //construct
    if([[childUIView subviews] count] == 0)
    {
        NSBundle *bundle = [NSBundle bundleForClass:[self class]];
        if([type isEqualToString:@"camera"]) {
            //[UIView ]
            childUIView.backgroundColor = UIColorFromRGB(0xeeeeee);
            childUIView.layer.cornerRadius = 3;
            UIImageView* image = [[UIImageView alloc] initWithFrame:CGRectMake(0, 0, s/3, s/3)];
            image.center = CGPointMake(s/2, s/2);
            UIImage* icon = [self tintColor:[UIImage imageNamed:@"devil_camera_icon.png" inBundle:bundle compatibleWithTraitCollection:nil] :UIColorFromRGB(0xaaaaaa)];
            [image setImage:icon];
            [childUIView addSubview:image];
            
            UIButton* button = [[UIButton alloc] initWithFrame:CGRectMake(0, 0, s, s)];
            [button addTarget:self action:@selector(onClickCamera:) forControlEvents:UIControlEventTouchUpInside];
            [childUIView addSubview:button];
        } else {
            UIImageView* image = [[UIImageView alloc] initWithFrame:CGRectMake(0, 0, s, s)];
            image.tag = 4321;
            [childUIView addSubview:image];
            
            UIButton* button = [[UIButton alloc] initWithFrame:CGRectMake(0, 0, s, s)];
            [button addTarget:self action:@selector(onClickCheck:) forControlEvents:UIControlEventTouchUpInside];
            [childUIView addSubview:button];
            
            UIButton* check_button = [[UIButton alloc] initWithFrame:CGRectMake(0, 0, 40, 40)];
            check_button.contentEdgeInsets = UIEdgeInsetsMake(5, 5, 5, 5);
            [check_button addTarget:self action:@selector(onClickCheck:) forControlEvents:UIControlEventTouchUpInside];
            check_button.tag = 3629;
            [childUIView addSubview:check_button];
        }
    }
    
    //update
    childUIView.tag = position;
    if([type isEqualToString:@"camera"]) {
        
    } else {
        if(item[@"preview"])
            [self urlToImage:item[@"preview"] : [childUIView viewWithTag:4321]];
        else
            [self urlToImage:item[@"url"] : [childUIView viewWithTag:4321]];
        [self check:[childUIView viewWithTag:3629] :[@"Y" isEqualToString:item[@"selected"]]];
    }
    
    return cell;
}

-(void)check:(UIButton*)check :(BOOL)on {
    NSBundle *bundle = [NSBundle bundleForClass:[self class]];
    if(!on) {
        UIImage* check_off = [self tintColor:[UIImage imageNamed:@"devil_checkbox.png" inBundle:bundle compatibleWithTraitCollection:nil] :UIColorFromRGB(0xffffff)];
        [check setImage:check_off forState:UIControlStateNormal];
    } else {
        UIImage* check_on = [self tintColor:[UIImage imageNamed:@"devil_checkbox_on.png" inBundle:bundle compatibleWithTraitCollection:nil] :UIColorFromRGB(0x3cb043)];
        [check setImage:check_on forState:UIControlStateNormal];
    }
}

-(void)onClickCheck:(UIView*)sender {
    int position = (int)[sender superview].tag;
    id o = self.data[position];
    BOOL on = [@"Y" isEqualToString:o[@"selected"]];
    if(on) { //체크해제
        
        o[@"selected"] = @"N";
        for(int i=0;i<[self.selected count];i++) {
            id a = self.selected[i];
            if(o[@"id"] == a[@"id"]){
                [self.selected removeObjectAtIndex:i];
                break;
            }
        }
    } else { //체크
        o[@"selected"] = @"Y";
        [self.selected addObject:o];
    }
    
    if([self.selected count] > 0)
        self.title = [NSString stringWithFormat:@"%d개 선택", (int)[self.selected count]];
    else
        self.title = self.titleText;
    
    [self check:(UIButton*)[[sender superview] viewWithTag:3629] :!on];
}


-(void)onClickImage:(UIView*)sender {
    int position = (int)[sender superview].tag;
}

-(void)onClickCamera:(UIView*)sender {
    [DevilCamera camera:self param:@{
        @"hasPicture": self.hasPicture?@TRUE:@FALSE,
        @"hasVideo": self.hasVideo?@TRUE:@FALSE,
        @"minSec": [NSNumber numberWithInt:self.minSec],
        @"maxSec": [NSNumber numberWithInt:self.maxSec],
        @"hasGallery": @FALSE,
    } callback:^(id  _Nonnull res) {
        if(res && [res[@"r"] boolValue]) {
            id o = [@{} mutableCopy];
            NSString* type = res[@"preview"]?@"video":@"image";
            o[@"type"] = type;
            if([@"image" isEqual:type]) {
                o[@"url"] = o[@"image"] = res[@"image"];
            } else {
                o[@"url"] = res[@"video"];
                o[@"preview"] = res[@"preview"];
                o[@"video"] = res[@"video"];
            }
            o[@"selected"] = @"Y";
            [self.selected addObject:o];
            [self.data insertObject:o atIndex:1];
            [self.list reloadData];
        }
    }];
}

-(void)urlToImage:(NSString*)url :(UIImageView*)imageView {
    if([url hasPrefix:@"/"]) {
        [(UIImageView*)imageView setImage:[UIImage imageWithContentsOfFile:url]];
    } else if([url hasPrefix:@"gallery://"]) {
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
                                [(UIImageView*)imageView setImage:image];
            }];
            *stop = true;
        }];
    }
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

- (UIImage *)resizeImage:(UIImage *)image {
    CGSize newSize = CGSizeMake(image.size.width/2, image.size.height/2);
    UIGraphicsBeginImageContextWithOptions(newSize, NO, 0.0);
    [image drawInRect:CGRectMake(0, 0, newSize.width, newSize.height)];
    UIImage *newImage = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    return newImage;
}

-(void)alert:(NSString *)msg {
    UIAlertController *alertController = [UIAlertController alertControllerWithTitle:msg
                                                                             message:nil
                                                                      preferredStyle:UIAlertControllerStyleAlert];

    [alertController addAction:[UIAlertAction actionWithTitle:@"확인"
                                                      style:UIAlertActionStyleCancel
                                                    handler:^(UIAlertAction *action) {
       
    }]];
    [self presentViewController:alertController animated:YES completion:^{}];
}

- (void) convertGalleryImagePathTo:(NSString*)url callback:(void (^)(id res))callback {
    PHImageRequestOptions* requestOptions = [[PHImageRequestOptions alloc] init];
    requestOptions.resizeMode   = PHImageRequestOptionsResizeModeExact;
    requestOptions.deliveryMode = PHImageRequestOptionsDeliveryModeHighQualityFormat;
    // this one is key
    requestOptions.synchronous = NO;

    PHImageManager *manager = [PHImageManager defaultManager];

    PHFetchResult *results = [PHAsset fetchAssetsWithLocalIdentifiers:@[[url stringByReplacingOccurrencesOfString:@"gallery://" withString:@""]] options:nil];
    
    [results enumerateObjectsUsingBlock:^(PHAsset *obj, NSUInteger idx, BOOL * _Nonnull stop) {
        [manager requestImageForAsset:obj
                           targetSize:CGSizeMake(1024, 1024)
                          contentMode:PHImageContentModeAspectFill
                              options:requestOptions
                        resultHandler:^void(UIImage *image, NSDictionary *info) {
            
            NSString* outputFileName = [NSUUID UUID].UUIDString;
            NSString* targetPath = [NSTemporaryDirectory() stringByAppendingPathComponent:[outputFileName stringByAppendingPathExtension:@"jpg"]];
            NSData *imageData = UIImageJPEGRepresentation(image, 0.6f);
            [imageData writeToFile:targetPath atomically:YES];
            callback([@{@"url":targetPath} mutableCopy]);
        }];
        *stop = true;
    }];
}

- (void) convertGalleryVideoPathTo:(NSString*)url callback:(void (^)(id res))callback {
    

    PHImageManager *manager = [PHImageManager defaultManager];
    PHVideoRequestOptions *options = [[PHVideoRequestOptions alloc]init];
    options.version = PHVideoRequestOptionsVersionOriginal;
    options.deliveryMode = PHVideoRequestOptionsDeliveryModeAutomatic;
    options.networkAccessAllowed = YES;
    
    PHFetchResult *results = [PHAsset fetchAssetsWithLocalIdentifiers:@[[url stringByReplacingOccurrencesOfString:@"gallery://" withString:@""]] options:nil];
    
    [results enumerateObjectsUsingBlock:^(PHAsset *obj, NSUInteger idx, BOOL * _Nonnull stop) {
        [manager requestAVAssetForVideo:obj options:options resultHandler:^(AVAsset * _Nullable asset, AVAudioMix * _Nullable audioMix, NSDictionary * _Nullable info) {
            AVURLAsset* a = (AVURLAsset*)asset;
            NSString* path = [[a URL] absoluteString];
            NSString* outputFileName = [NSUUID UUID].UUIDString;
            NSString* targetPath = [NSTemporaryDirectory() stringByAppendingPathComponent:[outputFileName stringByAppendingPathExtension:@"mp4"]];
            NSString* previewPath = [NSTemporaryDirectory() stringByAppendingPathComponent:[outputFileName stringByAppendingPathExtension:@"jpg"]];
            UIImage* preview = [DevilUtil getThumbnail:targetPath];
            NSData *imageData = UIImageJPEGRepresentation(preview, 0.6f);
            [imageData writeToFile:previewPath atomically:YES];
            [DevilUtil convertMovToMp4:path to:targetPath callback:^(id  _Nonnull res) {
                if([res[@"r"] boolValue]){
                    callback([@{@"url":targetPath, @"preview":previewPath} mutableCopy]);
                } else
                    ;
            }];
        }];
        
        *stop = true;
    }];
}

@end
