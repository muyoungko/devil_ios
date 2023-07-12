//
//  ReplaceRuleLocalImage.m
//  CloudJsonViewer
//
//  Created by Mu Young Ko on 2018. 6. 18..
//  Copyright © 2018년 Mu Young Ko. All rights reserved.
//

#import "ReplaceRuleLocalImage.h"
#import "WildCardConstructor.h"
#import "MappingSyntaxInterpreter.h"

@implementation ReplaceRuleLocalImage

- (void)constructRule:(WildCardMeta *)wcMeta parent:(UIView *)parent vv:(WildCardUIView *)vv layer:(id)layer depth:(int)depth result:(id)result {
    
    if([WildCardConstructor sharedInstance].onLineMode && ![WildCardConstructor sharedInstance].localImageMode)
    {
        UIView* iv = [[WildCardConstructor sharedInstance].delegate getNetworkImageViewInstnace];
        iv.contentMode = UIViewContentModeScaleToFill;
        [vv addSubview:iv];
        [WildCardConstructor followSizeFromFather:vv child:iv];
        //[outRules addObject:ReplaceRuleLocalImage(iv, layer, [layer objectForKey:@"localImageContent"])];
        [[WildCardConstructor sharedInstance].delegate loadNetworkImageView:iv withUrl:[layer objectForKey:(@"localImageContent")]];
    }
    else
    {
        UIImageView* iv = [[UIImageView alloc] init];
        iv.clipsToBounds = YES;
        iv.contentMode = UIViewContentModeScaleToFill;
        [vv addSubview:iv];
        
        NSString* imageName = [layer objectForKey:@"localImageContent"];
        NSUInteger index = [imageName rangeOfString:@"/" options:NSBackwardsSearch].location;
        imageName = [imageName substringFromIndex:index+1];
        NSData* imgData = [WildCardConstructor getLocalFile:[NSString stringWithFormat:@"assets/images/%@", imageName]];
        [iv setImage: [UIImage imageWithData:imgData]];
        [WildCardConstructor followSizeFromFather:vv child:iv];
    }
}

- (void)updateRule:(WildCardMeta *)meta data:(id)opt {
    
}

@end
