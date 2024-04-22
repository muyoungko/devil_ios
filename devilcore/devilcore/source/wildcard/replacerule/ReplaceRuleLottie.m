//
//  ReplaceRuleLottie.m
//  devilcore
//
//  Created by Mu Young Ko on 2024/04/22.
//

#import "ReplaceRuleLottie.h"
#import "Lottie/Lottie.h"
#import "WildCardConstructor.h"

@implementation ReplaceRuleLottie

- (void)constructRule:(WildCardMeta *)wcMeta parent:(UIView *)parent vv:(WildCardUIView *)vv layer:(id)layer depth:(int)depth result:(id)result{
    id lottie = layer[@"lottie"];
    NSString* url = lottie[@"url"];
    if([WildCardConstructor sharedInstance].localImageMode) {
        NSString* imageName = url;
        NSUInteger index = [imageName rangeOfString:@"/" options:NSBackwardsSearch].location;
        imageName = [imageName substringFromIndex:index+1];
        NSData* data = [WildCardConstructor getLocalFile:[NSString stringWithFormat:@"assets/images/%@", imageName]];
        NSDictionary *json = [NSJSONSerialization JSONObjectWithData:data options:NSJSONReadingMutableContainers error:nil];
        [self startLottie:json];
    } else {
        [[WildCardConstructor sharedInstance].delegate onNetworkRequest:url success:^(NSMutableDictionary* json) {
            [self startLottie:json];
        }];
    }
}

- (void)startLottie:(id)json {
    UIView* vv = self.replaceView;
    id lottie = self.replaceJsonLayer[@"lottie"];
    
    float lw = [json[@"w"] floatValue];
    float lh = [json[@"h"] floatValue];
    float todow, todoh;
    float w = vv.frame.size.width;
    float h = vv.frame.size.height;
    if(w/lw > h/lh){
        //높이에 맞춤
        todoh = h;
        todow = lw * h/lh;
    } else {
        todow = w;
        todoh = lh * w/lw;
    }
     
    LOTAnimationView* lv = [LOTAnimationView animationFromJSON:json];
    lv.contentMode = UIViewContentModeScaleAspectFit;
    lv.frame = CGRectMake(0, 0, todow, todoh);
    lv.center = CGPointMake(w/2.0f, h/2.0f);
    [vv addSubview:lv];
    
    if([@"Y" isEqualToString:lottie[@"infinite"]])
        lv.loopAnimation = YES;
    
    if([@"Y" isEqualToString:lottie[@"autoStart"]])
        [lv play];
}

- (void)updateRule:(WildCardMeta *)meta data:(id)opt{
    
}
@end
