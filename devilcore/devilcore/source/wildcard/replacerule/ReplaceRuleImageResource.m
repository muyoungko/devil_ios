//
//  ReplaceRuleImageResource.m
//  sticar
//
//  Created by Mu Young Ko on 2019. 7. 5..
//  Copyright © 2019년 trix. All rights reserved.
//

#import "ReplaceRuleImageResource.h"
#import "WildCardUtil.h"
#import "MappingSyntaxInterpreter.h"

@implementation ReplaceRuleImageResource


- (void)constructRule:(WildCardMeta *)wcMeta parent:(UIView *)parent vv:(WildCardUIView *)vv layer:(id)layer depth:(int)depth result:(id)result{
    
    UIImageView* iv = [[UIImageView alloc] init];
    self.replaceView = iv;
    iv.contentMode = UIViewContentModeScaleToFill;
    [vv addSubview:iv];
    [WildCardUtil followSizeFromFather:vv child:iv];
}

- (void)updateRule:(WildCardMeta *)meta data:(id)opt{
    NSString* imageName = nil;
    if([[opt class] isSubclassOfClass:[NSString class]])
        imageName = (NSString*)opt;
    else {
        NSString* jsonPath = self.replaceJsonLayer[@"imageContentResource"];
        imageName = [MappingSyntaxInterpreter interpret:jsonPath:opt];
    }
    [((UIImageView*)self.replaceView) setImage:[UIImage imageNamed:imageName]];
}

@end
