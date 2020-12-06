//
//  DevilHeader.m
//  devilcore
//
//  Created by Mu Young Ko on 2020/12/04.
//

#import "DevilHeader.h"
#import "WildCardUtil.h"
#import "WildCardConstructor.h"
#import "WildCardUIButton.h"
#import "WildCardTrigger.h"
#import "WildCardAction.h"

@implementation DevilHeader

-(id)initWithViewController:(UIViewController*)vc layer:(id)cj withData:(id)data
    instanceDelegate:(id)delegate
{
    self = [super init];
    
    if(cj[@"backgroundColor"]){
        UIColor* bgColor = [WildCardUtil colorWithHexString:cj[@"backgroundColor"]];
        [vc.navigationController.navigationBar setBarTintColor:bgColor];
    }
    
    WildCardMeta* meta = [[WildCardMeta alloc] init];
    meta.wildCardConstructorInstanceDelegate = delegate;
    meta.parentMeta = nil;
    meta.rootView = nil;
    meta.correspondData = data;
    self.meta = meta;
    
    id layers = cj[@"layers"];
    if(layers){
        for(int i=0;i<[layers count];i++){
            id layer = layers[i];
            id layer_name = layer[@"name"];
            if([@"logo" isEqualToString:layer_name]){
                NSString* url = layer[@"localImageContent"];
                
                //TODO : 네트워크 캐시 해서 에니메이션부드럽게 해야함
                [[WildCardConstructor sharedInstance].delegate onNetworkRequestToByte:url success:^(NSData *byte) {
                    CGRect rect = [WildCardConstructor getFrame:layer:nil];
                    UIView* logo = [[UIView alloc] initWithFrame:CGRectMake(0,0,rect.size.width, rect.size.height)];
                    UIImageView* logoImage = [[UIImageView alloc] initWithFrame:CGRectMake(0,0,rect.size.width, rect.size.height)];
                    logoImage.clipsToBounds = YES;
                    logoImage.contentMode = UIViewContentModeScaleAspectFill;
                    [logoImage setImage:[UIImage imageWithData:byte]];
                    [logo addSubview:logoImage];
                    vc.navigationItem.titleView = logo;
                }];
            } else if([@"left" isEqualToString:layer_name]){
                id layer2 = layer[@"layers"];
                [self everyIconButton:layer2 viewController:vc isLeft:YES];
            } else if([@"right" isEqualToString:layer_name]){
                id layer2 = layer[@"layers"];
                [self everyIconButton:layer2 viewController:vc isLeft:NO];
            }
        }
    }
    
    
    return self;
}

-(void)update{
    
}

-(void)everyIconButton:(id)layers viewController:(UIViewController*)vc isLeft:(BOOL)isLeft{
    for(id icon_layer in layers){
        NSString* url = icon_layer[@"localImageContent"];
        [[WildCardConstructor sharedInstance].delegate onNetworkRequestToByte:url success:^(NSData *byte) {
            CGRect rect = [WildCardConstructor getFrame:icon_layer:nil];
            WildCardUIButton *leftButton = [WildCardUIButton buttonWithType:UIButtonTypeCustom];
            int bw = 50;
            leftButton.frame = CGRectMake(0,0, bw, bw);
            [leftButton setImage:[UIImage imageWithData:byte] forState:UIControlStateNormal];
            [leftButton addTarget:self action:@selector(aClick:)forControlEvents:UIControlEventTouchUpInside];
            leftButton.stringTag = icon_layer[@"clickContent"]; 
            leftButton.imageView.contentMode = UIViewContentModeScaleAspectFit;
            //[leftButton setBackgroundColor:[UIColor redColor]];
            if(isLeft){
                leftButton.imageEdgeInsets = UIEdgeInsetsMake(
                    bw - rect.size.height /2,
                    0,
                    bw - rect.size.height /2,
                    bw - rect.size.width
                );
                vc.navigationItem.leftBarButtonItem = [[UIBarButtonItem alloc] initWithCustomView:leftButton];
            } else {
                leftButton.imageEdgeInsets = UIEdgeInsetsMake(
                    bw - rect.size.height /2,
                    bw - rect.size.width,
                    bw - rect.size.height /2,
                    0
                );
                vc.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc] initWithCustomView:leftButton];
            }
        }];
    }
}

-(void)aClick:(id)sender{
    WildCardUIButton* vv = (WildCardUIButton*)sender;
    NSString *action = vv.stringTag;
    WildCardTrigger* trigger = [[WildCardTrigger alloc] init];
    [WildCardAction parseAndConducts:trigger action:action meta:self.meta];
}


@end
