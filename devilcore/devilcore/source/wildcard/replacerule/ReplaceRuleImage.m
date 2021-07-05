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
    } else {
        [[WildCardConstructor sharedInstance].delegate loadNetworkImageView:self.replaceView withUrl:url];
    }
}

@end
