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
@property (nonatomic, retain) NSString* logoClickAction;

@end

@implementation DevilHeader

-(id)initWithViewController:(UIViewController*)vc layer:(id)cj withData:(id)data
    instanceDelegate:(id)delegate
{
    self = [super init];
    
    
    
    
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
    
    if(cj[@"backgroundColor"]){
        UIColor* bgColor = [WildCardUtil colorWithHexString:cj[@"backgroundColor"]];
        [vc.navigationController.navigationBar setBarTintColor:bgColor];
        [vc.navigationController.navigationBar setBackgroundColor:bgColor];
    }
    return self;
}

-(void)initHeader{

    id layers = self.cj[@"layers"];
    if(layers){
        BOOL hasline = false;
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
                    
                    if(layer[@"clickContent"]){
                        UITapGestureRecognizer *logoTap =
                        [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(handleLogoTap)];
                        self.logoClickAction = layer[@"clickContent"]; 
                        [logo addGestureRecognizer:logoTap];
                        logo.userInteractionEnabled = YES;
                    }
    
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
            } else if([@"line" isEqualToString:layer_name]){
//                UINavigationBarAppearance* n = [UINavigationBarAppearance new];
//                n.shadowColor = [UIColor clearColor];
//                self.vc.navigationController.navigationBar.scrollEdgeAppearance = n;
                hasline = true;
            }
        }
        
        if(!hasline)
            self.vc.navigationController.navigationBar.shadowImage = [[UIImage alloc] init];
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
                
                for(int j=(int)[layer2 count]-1;j>=0;j--) {
                    id icon_layer = layer2[j];
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
            UIImage* icon_image = [UIImage imageWithData:byte];
            CGRect rect = [WildCardConstructor getFrame:icon_layer:nil];
            rect.origin.y = rect.origin.x = 0;
            
            WildCardUIButton *leftButton = [[WildCardUIButton alloc] initWithFrame:rect];
            [leftButton setImage:icon_image forState:UIControlStateNormal];
            UIBarButtonItem* menuBarItem = [[UIBarButtonItem alloc] initWithCustomView:leftButton];
            
            NSLayoutConstraint* a = [menuBarItem.customView.widthAnchor constraintEqualToConstant:rect.size.width];
            [a setActive:YES];
            NSLayoutConstraint* b = [menuBarItem.customView.heightAnchor constraintEqualToConstant:rect.size.height];
            [b setActive:YES];
            self.barButtonByName[name] = menuBarItem;
            
//            WildCardUIButton *leftButton = [WildCardUIButton buttonWithType:UIButtonTypeCustom];
//            int bw = 40;
//            leftButton.frame = CGRectMake(0,0, bw, bw);
//
//            if(rect.size.width<rect.size.height){
//                icon_image = [self imageWithImage:icon_image convertToSize:CGSizeMake(
//                    64*rect.size.width/rect.size.height, 64
//                )];
//            } else {
//                icon_image = [self imageWithImage:icon_image convertToSize:CGSizeMake(
//                    64, 64*rect.size.height/rect.size.width
//                )];
//            }
//
//            UIImage* icon_asset_image = icon_image;//[[UIImage alloc] initWithIm];
//            [icon_asset_image.imageAsset registerImage:icon_image withTraitCollection:[UITraitCollection traitCollectionWithDisplayScale:3.0]];
//            [leftButton setImage:icon_asset_image forState:UIControlStateNormal];
//            leftButton.imageView.contentMode = UIViewContentModeCenter;
            
//            i++;
//            if(i%3 == 0)
//                [leftButton setBackgroundColor:[UIColor greenColor]];
//            else if(i%3 == 1)
//                [leftButton setBackgroundColor:[UIColor grayColor]];
//            else if(i%3 == 2)
//                [leftButton setBackgroundColor:[UIColor redColor]];
            
            if(isLeft){
//                leftButton.imageEdgeInsets = UIEdgeInsetsMake(
//                    (bw - rect.size.height) /2,
//                    0,
//                    (bw - rect.size.width) /2,
//                    bw - rect.size.width
//                );
                
            } else {
                //top left bototm right
//                leftButton.imageEdgeInsets = UIEdgeInsetsMake(
//                    bw - rect.size.height /2,
//                    bw - rect.size.width,
//                    bw - rect.size.height /2,
//                    0
//                );
            }
//            self.barButtonByName[name] = [[UIBarButtonItem alloc] initWithCustomView:leftButton];
            
            if(icon_layer[@"clickJavascript"]){
                [leftButton addTarget:self action:@selector(scriptClick:)forControlEvents:UIControlEventTouchUpInside];
                leftButton.stringTag = icon_layer[@"clickJavascript"];
            } else if(icon_layer[@"clickContent"]) {
                [leftButton addTarget:self action:@selector(aClick:)forControlEvents:UIControlEventTouchUpInside];
                leftButton.stringTag = icon_layer[@"clickContent"];
            }

            
            [self update];
        }];
    }
}

-(void)handleLogoTap{
    NSString *action = self.logoClickAction;
    WildCardTrigger* trigger = [[WildCardTrigger alloc] init];
    [WildCardAction parseAndConducts:trigger action:action meta:self.meta];
}

-(void)aClick:(id)sender{
    WildCardUIButton* vv = (WildCardUIButton*)sender;
    NSString *action = vv.stringTag;
    WildCardTrigger* trigger = [[WildCardTrigger alloc] init];
    [WildCardAction parseAndConducts:trigger action:action meta:self.meta];
}
-(void)scriptClick:(id)sender{
    WildCardUIButton* vv = (WildCardUIButton*)sender;
    NSString *script = vv.stringTag;
    WildCardTrigger* trigger = [[WildCardTrigger alloc] init];
    [WildCardAction execute:trigger script:script meta:self.meta];
}

- (UIImage *)imageWithImage:(UIImage *)image convertToSize:(CGSize)size {
    UIGraphicsBeginImageContext(size);
    [image drawInRect:CGRectMake(0, 0, size.width, size.height)];
    UIImage *destImage = UIGraphicsGetImageFromCurrentImageContext();    
    UIGraphicsEndImageContext();
    return destImage;
}

@end
