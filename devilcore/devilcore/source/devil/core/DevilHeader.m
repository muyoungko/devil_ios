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

@interface DevilHeader ()

@property BOOL inited;
@property (nonatomic, retain) UIViewController* vc;
@property (nonatomic, retain) id cj;
@property (nonatomic, retain) id barButtonByName;

@end

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
    
    self.vc = vc;
    self.cj = cj;
    self.inited = false;
    self.barButtonByName = [@{} mutableCopy];
    [self initHeader];
    [self update];
    
    return self;
}

-(void)initHeader{

    id layers = self.cj[@"layers"];
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
                    self.barButtonByName[@"logo"] = logo;
                    [self update];
                }];
            } else if([@"left" isEqualToString:layer_name]){
                id layer2 = layer[@"layers"];
                [self everyIconButton:layer2 viewController:self.vc isLeft:YES];
            } else if([@"right" isEqualToString:layer_name]){
                id layer2 = layer[@"layers"];
                [self everyIconButton:layer2 viewController:self.vc isLeft:NO];
            } else if([@"title" isEqualToString:layer_name]){
                id title = layer[@"textSpec"][@"text"];
                int textSize = [layer[@"textSpec"][@"textSize"] intValue];
                UIColor* textColor = [WildCardUtil colorWithHexString:layer[@"textSpec"][@"textColor"]];
                //NSFontAttributeName : [UIFont systemFontOfSize:textSize]
                self.vc.navigationController.navigationBar.titleTextAttributes = @{
                    NSForegroundColorAttributeName : textColor,
                };
            }
        }
    }
}
-(void)update{
    id layers = self.cj[@"layers"];
    [self.vc.navigationItem setHidesBackButton:YES];
    
    if(layers){
        for(int i=0;i<[layers count];i++){
            id layer = layers[i];
            id layer_name = layer[@"name"];
            if([@"logo" isEqualToString:layer_name]){
                UIView* logo = self.barButtonByName[@"logo"];
                self.vc.navigationItem.titleView = logo;
            } else if([@"left" isEqualToString:layer_name]){
                id layer2 = layer[@"layers"];
                id barbuttons = [@[] mutableCopy];
                for(id icon_layer in layer2){
                    NSString* name = icon_layer[@"name"];
                    if(self.barButtonByName[name] 
                        && self.meta.correspondData[@"left"] 
                        && [self.meta.correspondData[@"left"][name] boolValue])
                        [barbuttons addObject:self.barButtonByName[name]];
                }
                self.vc.navigationItem.leftBarButtonItems = barbuttons;
            } else if([@"right" isEqualToString:layer_name]){
                id layer2 = layer[@"layers"];
                id barbuttons = [@[] mutableCopy];
                for(id icon_layer in layer2){
                    NSString* name = icon_layer[@"name"];
                    if(self.barButtonByName[name] 
                        && self.meta.correspondData[@"right"] 
                        && [self.meta.correspondData[@"right"][name] boolValue]
                        )
                        [barbuttons addObject:self.barButtonByName[name]];
                }
                
                self.vc.navigationItem.rightBarButtonItems = barbuttons;
            } else if([@"title" isEqualToString:layer_name]){
                if(self.meta.correspondData[@"title"])
                    self.vc.title = self.meta.correspondData[@"title"];
                else
                    self.vc.title = layer[@"textSpec"][@"text"];
            }
        }
    }
}

-(void)everyIconButton:(id)layers viewController:(UIViewController*)vc isLeft:(BOOL)isLeft{

    __block int i = 0;
    for(id icon_layer in layers){
        NSString* name = icon_layer[@"name"];
        NSString* url = icon_layer[@"localImageContent"];
        [[WildCardConstructor sharedInstance].delegate onNetworkRequestToByte:url success:^(NSData *byte) {
            CGRect rect = [WildCardConstructor getFrame:icon_layer:nil];
            WildCardUIButton *leftButton = [WildCardUIButton buttonWithType:UIButtonTypeCustom];
            int bw = 40;
            leftButton.frame = CGRectMake(0,0, bw, bw);
            UIImage* icon_image = [UIImage imageWithData:byte];
            icon_image = [self imageWithImage:icon_image convertToSize:CGSizeMake(
                64, 64
                )];
            
            UIImage* icon_asset_image = icon_image;//[[UIImage alloc] initWithIm];             
            [icon_asset_image.imageAsset registerImage:icon_image withTraitCollection:[UITraitCollection traitCollectionWithDisplayScale:3.0]];
          
            [leftButton setImage:icon_asset_image forState:UIControlStateNormal];
            [leftButton addTarget:self action:@selector(aClick:)forControlEvents:UIControlEventTouchUpInside];
            leftButton.stringTag = icon_layer[@"clickContent"]; 
            leftButton.imageView.contentMode = UIViewContentModeCenter;
            
            i++;
//            if(i%3 == 0)
//                [leftButton setBackgroundColor:[UIColor greenColor]];
//            else if(i%3 == 1)
//                [leftButton setBackgroundColor:[UIColor blueColor]];
//            else if(i%3 == 2)
//                [leftButton setBackgroundColor:[UIColor redColor]];
            
            if(isLeft){
//                leftButton.imageEdgeInsets = UIEdgeInsetsMake(
//                    bw - rect.size.height /2,
//                    0,
//                    bw - rect.size.height /2,
//                    bw - rect.size.width
//                );
                self.barButtonByName[name] = [[UIBarButtonItem alloc] initWithCustomView:leftButton];
            } else {
                //top left bototm right
//                leftButton.imageEdgeInsets = UIEdgeInsetsMake(
//                    bw - rect.size.height /2,
//                    bw - rect.size.width,
//                    bw - rect.size.height /2,
//                    0
//                );
                
                self.barButtonByName[name] = [[UIBarButtonItem alloc] initWithCustomView:leftButton];
            }
            [self update];
        }];
    }
}

-(void)aClick:(id)sender{
    WildCardUIButton* vv = (WildCardUIButton*)sender;
    NSString *action = vv.stringTag;
    WildCardTrigger* trigger = [[WildCardTrigger alloc] init];
    [WildCardAction parseAndConducts:trigger action:action meta:self.meta];
}


- (UIImage *)imageWithImage:(UIImage *)image convertToSize:(CGSize)size {
    UIGraphicsBeginImageContext(size);
    [image drawInRect:CGRectMake(0, 0, size.width, size.height)];
    UIImage *destImage = UIGraphicsGetImageFromCurrentImageContext();    
    UIGraphicsEndImageContext();
    return destImage;
}

@end