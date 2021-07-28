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
@end

@implementation ReplaceRuleImage

- (void)constructRule:(WildCardMeta *)wcMeta parent:(UIView *)parent vv:(WildCardUIView *)vv layer:(id)layer depth:(int)depth result:(id)result{
    
    UIView* iv = [[WildCardConstructor sharedInstance].delegate getNetworkImageViewInstnace];
    self.replaceView = iv;
    iv.contentMode = UIViewContentModeScaleAspectFill;
    [vv addSubview:iv];
    [WildCardConstructor followSizeFromFather:vv child:iv];
    
}

- (void)updateRule:(WildCardMeta *)meta data:(id)opt{
    NSString* url = nil;
    if([[opt class] isSubclassOfClass:[NSString class]])
        url = (NSString*)opt;
    else {
        NSString* jsonPath = self.replaceJsonLayer[@"imageContent"];
        url = [MappingSyntaxInterpreter interpret:jsonPath:opt];
    }
    
    if([url hasPrefix:@"/"]) {
        [(UIImageView*)self.replaceView setImage:[UIImage imageWithContentsOfFile:url]];
    } else if([url hasPrefix:@"phasset://"]) {
        if(![url isEqualToString:self.currentUrl]) {
            PHImageRequestOptions* requestOptions = [[PHImageRequestOptions alloc] init];
            requestOptions.resizeMode   = PHImageRequestOptionsResizeModeExact;
            requestOptions.deliveryMode = PHImageRequestOptionsDeliveryModeHighQualityFormat;
            // this one is key
            requestOptions.synchronous = NO;

            PHImageManager *manager = [PHImageManager defaultManager];

            PHFetchResult *results = [PHAsset fetchAssetsWithLocalIdentifiers:@[[url stringByReplacingOccurrencesOfString:@"phasset://" withString:@""]] options:nil];
            
            CGRect rect = [WildCardConstructor getFrame:self.replaceJsonLayer:nil];
            [results enumerateObjectsUsingBlock:^(PHAsset *obj, NSUInteger idx, BOOL * _Nonnull stop) {
                [manager requestImageForAsset:obj
                                   targetSize:rect.size
                                  contentMode:PHImageContentModeAspectFill
                                      options:requestOptions
                                resultHandler:^void(UIImage *image, NSDictionary *info) {
                                    [(UIImageView*)self.replaceView setImage:image];
                }];
                *stop = true;
            }];
        }
    } else {
        [[WildCardConstructor sharedInstance].delegate loadNetworkImageView:self.replaceView withUrl:url];
    }
    
    self.currentUrl = url;
}

@end
