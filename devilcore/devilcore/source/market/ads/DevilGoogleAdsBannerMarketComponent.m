//
//  DevilGoogleAdsBannerMarketComponent.m
//  devilcore
//
//  Created by Mu Young Ko on 2022/12/15.
//

#import "DevilGoogleAdsBannerMarketComponent.h"
#import "DevilSdk.h"

@interface DevilGoogleAdsBannerMarketComponent()
@property (nonatomic, retain) UIView* banner;
@end

@implementation DevilGoogleAdsBannerMarketComponent

- (void)initialized {
    [super initialized];
}

- (void)created {
    [super created];
    
    
    
}

- (void)update:(JSValue*)opt {
    [super update:opt];
    
    if(self.banner == nil && [DevilSdk sharedInstance].devilSdkGoogleAdsDelegate) {
        NSString* adUnitId = @"ca-app-pub-5134106554966339/4881221230";
        if(![[[NSBundle mainBundle] bundleIdentifier] isEqualToString:@"kr.co.july.CloudJsonViewer"])
            adUnitId = self.marketJson[@"select4"];
        UIView* banner = [[DevilSdk sharedInstance].devilSdkGoogleAdsDelegate createBanner:@{@"adUnitId":adUnitId}];
        self.banner = banner;
        [self.vv addSubview:self.banner];
        
        self.vv.userInteractionEnabled = YES;
        [WildCardConstructor userInteractionEnableToParentPath:self.vv depth:5];
        self.banner.center = CGPointMake(self.vv.frame.size.width/2, self.vv.frame.size.height/2);
//        [WildCardUtil followSizeFromFather:self.vv child:self.banner];
    }

}

@end
