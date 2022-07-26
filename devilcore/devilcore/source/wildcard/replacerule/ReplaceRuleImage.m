//
//  ReplaceRuleImage.m
//  CloudJsonViewer
//
//  Created by Mu Young Ko on 2018. 6. 18..
//  Copyright © 2018년 Mu Young Ko. All rights reserved.
//

#import "ReplaceRuleImage.h"
#import "WildCardConstructor.h"
#import "MappingSyntaxInterpreter.h"

@import Photos;

@interface ReplaceRuleImage()
@property (nonatomic, retain) NSString* currentUrl;
@property (nonatomic, retain) UIImageView* flipImageView;
@end

@implementation ReplaceRuleImage

- (void)constructRule:(WildCardMeta *)wcMeta parent:(UIView *)parent vv:(WildCardUIView *)vv layer:(id)layer depth:(int)depth result:(id)result{
    {
        UIView* iv = [[WildCardConstructor sharedInstance].delegate getNetworkImageViewInstnace];
        self.replaceView = iv;
        if(self.replaceJsonLayer[@"scaleType"] && [@"center_inside" isEqualToString:self.replaceJsonLayer[@"scaleType"]])
            iv.contentMode = UIViewContentModeScaleAspectFit;
        else
            iv.contentMode = UIViewContentModeScaleAspectFill;
        
        [vv addSubview:iv];
        [WildCardConstructor followSizeFromFather:vv child:iv];
        
        iv.layer.cornerRadius = vv.layer.cornerRadius;
        iv.layer.maskedCorners = vv.superview.layer.maskedCorners;
    }
    
    if(self.replaceJsonLayer[@"flipImageContent"])
    {
        UIView* iv = [[WildCardConstructor sharedInstance].delegate getNetworkImageViewInstnace];
        self.flipImageView = (UIImageView*)iv;
        if(self.replaceJsonLayer[@"scaleType"] && [@"center_inside" isEqualToString:self.replaceJsonLayer[@"scaleType"]])
            iv.contentMode = UIViewContentModeScaleAspectFit;
        else
            iv.contentMode = UIViewContentModeScaleAspectFill;
        
        [vv addSubview:iv];
        [WildCardConstructor followSizeFromFather:vv child:iv];
        
        iv.layer.cornerRadius = vv.layer.cornerRadius;
        iv.layer.maskedCorners = vv.superview.layer.maskedCorners;
        
        [self performSelector:@selector(flip) withObject:nil afterDelay:2.0f];
    }
}

- (void)updateRule:(WildCardMeta *)meta data:(id)opt {
    NSString* url = nil;
    if([[opt class] isSubclassOfClass:[NSString class]])
        url = (NSString*)opt;
    else {
        NSString* jsonPath = self.replaceJsonLayer[@"imageContent"];
        url = [MappingSyntaxInterpreter interpret:jsonPath:opt];
    }
    
    
    [self updateImageView:url view:(UIImageView*)self.replaceView meta:meta data:opt];
    self.currentUrl = url;
    if(self.currentUrl)
        ((WildCardUIView*)[self.replaceView superview]).tags[@"url"] = url;
    else
        [((WildCardUIView*)[self.replaceView superview]).tags removeObjectForKey:@"url"];
    
    if(self.flipImageView) {
        [self updateImageView:[MappingSyntaxInterpreter interpret:self.replaceJsonLayer[@"flipImageContent"]:opt] view:(UIImageView*)self.flipImageView meta:meta data:opt];
        self.flipImageView.alpha = 0.0f;
    }
    
}

- (void)flip {
    
    [UIView animateWithDuration:0.30f delay:0.0f options:UIViewAnimationOptionCurveEaseOut animations:^{
        if(self.replaceView.alpha == 1.0f){
            self.replaceView.alpha = 0.0f;
            self.flipImageView.alpha = 1.0f;
        } else {
            self.replaceView.alpha = 1.0f;
            self.flipImageView.alpha = 0.0f;
        }
    } completion:^(BOOL finished) {
//        NSLog(@"animate %@" , self.currentUrl);
        [self performSelector:@selector(flip) withObject:nil afterDelay:2.0f];
    }];
}

- (NSString*)updateImageView:(NSString*)url view:(UIImageView*)imageView meta:(WildCardMeta *)meta data:(id)opt {
    
    if(url == nil){
        [imageView setImage:nil];
        [imageView setNeedsDisplay];
        return self.currentUrl;
    }
    
    if([url isEqualToString:self.currentUrl])
        return self.currentUrl;
    
    [imageView setImage:nil];
    [imageView setNeedsDisplay];
    
    if([url hasPrefix:@"/"]) {
        [imageView setImage:[UIImage imageWithContentsOfFile:url]];
    } else if([url hasPrefix:@"gallery://"]) {
        if(![url isEqualToString:self.currentUrl]) {
            PHImageRequestOptions* requestOptions = [[PHImageRequestOptions alloc] init];
            requestOptions.resizeMode   = PHImageRequestOptionsResizeModeExact;
            requestOptions.deliveryMode = PHImageRequestOptionsDeliveryModeHighQualityFormat;
            // this one is key
            requestOptions.synchronous = NO;

            PHImageManager *manager = [PHImageManager defaultManager];

            PHFetchResult *results = [PHAsset fetchAssetsWithLocalIdentifiers:@[[url stringByReplacingOccurrencesOfString:@"gallery://" withString:@""]] options:nil];
            
            CGRect rect = [WildCardConstructor getFrame:self.replaceJsonLayer:nil];
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
    
    return url;
}

@end
