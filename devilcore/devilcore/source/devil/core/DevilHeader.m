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
#import "MappingSyntaxInterpreter.h"

@interface DevilHeader ()

@property BOOL inited;
@property BOOL hasline;
@property (nonatomic, retain) UIViewController* vc;
@property (nonatomic, retain) id cj;
@property (nonatomic, retain) id barButtonByName;
@property (nonatomic, retain) NSString* logoClickAction;
@property (nonatomic, retain) UIColor* titleColor;

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
    
    [self needAppearanceUpdate];
    
    return self;
}


-(void)needAppearanceUpdate {
    if(_cj[@"backgroundColor"]){
        UIColor* bgColor = [WildCardUtil colorWithHexString:_cj[@"backgroundColor"]];
        self.bgcolor = bgColor;
        [_vc.navigationController.navigationBar setTranslucent:false];

        if (@available(iOS 15.0, *)) {
            UINavigationBarAppearance* a = [UINavigationBarAppearance new];
            [a configureWithOpaqueBackground];
            a.backgroundColor = bgColor;
            
            if(!self.hasline) {
                a.shadowImage = [[UIImage alloc] init];
                a.shadowColor = [UIColor clearColor];
            }
         
            [a setTitleTextAttributes:@{NSForegroundColorAttributeName : self.titleColor}];
            
            self.vc.navigationController.navigationBar.scrollEdgeAppearance = self.vc.navigationController.navigationBar.standardAppearance = a;
            
        } else {
            [_vc.navigationController.navigationBar setBarTintColor:bgColor];
            [_vc.navigationController.navigationBar setBackgroundColor:bgColor];
            [_vc.navigationController.navigationBar setAlpha:1.0f];
            [[UINavigationBar appearance] setBarStyle:UIBarStyleBlackOpaque];
            [[UINavigationBar appearance] setAlpha:1.0f];
            self.vc.navigationController.navigationBar.titleTextAttributes = @{
                NSForegroundColorAttributeName : self.titleColor,
            };
        }
        
    }
}

-(void)initHeader{

    id layers = self.cj[@"layers"];
    if(layers){
        self.titleColor = [UIColor blackColor];
        BOOL hasline = false;
        for(int i=0;i<[layers count];i++){
            id layer = layers[i];
            id layer_name = layer[@"name"];
            if([@"logo" isEqualToString:layer_name]){
                NSString* url = layer[@"localImageContent"];
                
                //TODO : 네트워크 캐시 해서 에니메이션부드럽게 해야함
                [[WildCardConstructor sharedInstance].delegate onNetworkRequestToByte:url success:^(NSData *byte) {
                    
                    if(byte == nil || ![byte isKindOfClass:[NSData class]])
                        return;
                    
                    CGRect rect = [WildCardConstructor getFrame:layer:nil];
                    UIView* logo = [[UIView alloc] initWithFrame:CGRectMake(0,0,rect.size.width, rect.size.height)];
                    UIImageView* logoImage = [[UIImageView alloc] initWithFrame:CGRectMake(0,0,rect.size.width, rect.size.height)];
                    logoImage.clipsToBounds = YES;
                    logoImage.contentMode = UIViewContentModeScaleAspectFill;
                    [logoImage setImage:[UIImage imageWithData:byte]];
                    [logo addSubview:logoImage];
                    self.barButtonByName[@"logo"] = logo;
                    
                    if(layer[@"clickJavascript"]){
                        UITapGestureRecognizer *logoTap =
                        [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(handleLogoTap)];
                        self.logoClickAction = layer[@"clickJavascript"];
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
                self.titleColor = [WildCardUtil colorWithHexString:layer[@"textSpec"][@"textColor"]];
                //NSFontAttributeName : [UIFont systemFontOfSize:textSize]
            } else if([@"line" isEqualToString:layer_name]){
//                UINavigationBarAppearance* n = [UINavigationBarAppearance new];
//                n.shadowColor = [UIColor clearColor];
//                self.vc.navigationController.navigationBar.scrollEdgeAppearance = n;
                hasline = true;
            }
        }
        
        if(!hasline) {
            self.vc.navigationController.navigationBar.shadowImage = [[UIImage alloc] init];
            [self.vc.navigationController.navigationBar setValue:@(YES) forKeyPath:@"hidesShadow"];
        } else {
            [self.vc.navigationController.navigationBar setValue:@(NO) forKeyPath:@"hidesShadow"];
        }
        
        self.hasline = hasline;
    }
    
}

-(void)update{
    [self update:self.meta.correspondData];
}

-(void)update:(id)correspondData{
    self.meta.correspondData = correspondData;
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
                       && [self.meta.correspondData[@"left"][name] boolValue]) {
                        [barbuttons addObject:self.barButtonByName[name]];
                        
                        if(icon_layer[@"accessibility"]){
                            NSString* text = [MappingSyntaxInterpreter interpret:icon_layer[@"accessibility"]:correspondData];
                            ((UIBarButtonItem*)self.barButtonByName[name]).accessibilityLabel = text;
                        }
                    }
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

-(void)everyIconButton:(id)layers viewController:(UIViewController*)vc isLeft:(BOOL)isLeft {
    for(id layer in layers){
        NSString* name = layer[@"name"];
        NSString* url = layer[@"localImageContent"];
        if(url) {
            if([WildCardConstructor sharedInstance].onLineMode && ![WildCardConstructor sharedInstance].localImageMode)
            {
                [[WildCardConstructor sharedInstance].delegate onNetworkRequestToByte:url success:^(NSData *byte) {
                    if(byte == nil || ![byte isKindOfClass:[NSData class]])
                        return;
                    [self eventIconButtonCore:name layer:layer byte:byte];
                }];
            }
            else
            {
                NSString* imageName = [layer objectForKey:@"localImageContent"];
                NSUInteger index = [imageName rangeOfString:@"/" options:NSBackwardsSearch].location;
                imageName = [imageName substringFromIndex:index+1];
                NSData* byte = [WildCardConstructor getLocalFile:[NSString stringWithFormat:@"assets/images/%@", imageName]];
                [self eventIconButtonCore:name layer:layer byte:byte];
            }
        }
    }
}

-(void)eventIconButtonCore:(NSString*)name layer:(id)layer byte:(NSData*)byte {
    UIImage* icon_image = [UIImage imageWithData:byte];
    CGRect rect = [WildCardConstructor getFrame:layer:nil];
    rect.origin.y = rect.origin.x = 0;
    
    if([WildCardConstructor isTablet]) {
//        rect.size.width /= 2;
//        rect.size.height /= 2;
    }
    
    WildCardUIButton *leftButton = [[WildCardUIButton alloc] initWithFrame:rect];
    [leftButton setImage:icon_image forState:UIControlStateNormal];
    UIBarButtonItem* menuBarItem = [[UIBarButtonItem alloc] initWithCustomView:leftButton];
    
    NSLayoutConstraint* a = [menuBarItem.customView.widthAnchor constraintEqualToConstant:rect.size.width];
    [a setActive:YES];
    NSLayoutConstraint* b = [menuBarItem.customView.heightAnchor constraintEqualToConstant:rect.size.height];
    [b setActive:YES];
    self.barButtonByName[name] = menuBarItem;
    
    leftButton.isAccessibilityElement = YES;
    leftButton.accessibilityTraits = UIAccessibilityTraitButton;
    
    if(layer[@"clickJavascript"]){
        [leftButton addTarget:self action:@selector(scriptClick:)forControlEvents:UIControlEventTouchUpInside];
        leftButton.stringTag = layer[@"clickJavascript"];
    } else if(layer[@"clickContent"]) {
        [leftButton addTarget:self action:@selector(aClick:)forControlEvents:UIControlEventTouchUpInside];
        leftButton.stringTag = layer[@"clickContent"];
    }
    
    [self update];
}

-(void)handleLogoTap{
    NSString *script = self.logoClickAction;
    WildCardTrigger* trigger = [[WildCardTrigger alloc] init];
    [WildCardAction execute:trigger script:script meta:self.meta];
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
    trigger.node = vv;
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
