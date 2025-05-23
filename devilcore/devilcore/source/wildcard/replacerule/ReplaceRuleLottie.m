//
//  ReplaceRuleLottie.m
//  devilcore
//
//  Created by Mu Young Ko on 2024/04/22.
//

#import "ReplaceRuleLottie.h"
#import "WildCardConstructor.h"
#import "devilcore/devilcore-Swift.h"

@implementation ReplaceRuleLottie

- (void)constructRule:(WildCardMeta *)wcMeta parent:(UIView *)parent vv:(WildCardUIView *)vv layer:(id)layer depth:(int)depth result:(id)result{
    self.replaceView = vv;
    self.replaceJsonLayer = layer;
    
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
    if(json == nil)
        return;
    
    UIView* vv = self.replaceView;
    id lottie = self.replaceJsonLayer[@"lottie"];
    
    NSError *error = nil;
    NSData *jsonData = [NSJSONSerialization dataWithJSONObject:json options:0 error:&error];

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
    
    //json to data
    
    UIView* a = [DevilLottie generateViewWithData:jsonData];
    a.frame = CGRectMake(0, 0, todow, todoh);
    a.center = CGPointMake(w/2.0f, h/2.0f);
    [vv addSubview:a];
    
    if([@"Y" isEqualToString:lottie[@"infinite"]])
        [DevilLottie loopWithView:a Loop:YES];

    if([@"Y" isEqualToString:lottie[@"autoStart"]])
        [DevilLottie playWithView:a];
}

- (void)updateRule:(WildCardMeta *)meta data:(id)opt{
    
}
@end
