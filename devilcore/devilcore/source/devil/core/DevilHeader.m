//
//  DevilHeader.m
//  devilcore
//
//  Created by Mu Young Ko on 2020/12/04.
//

#import "DevilHeader.h"
#import "WildCardUtil.h"
#import "WildCardConstructor.h"

@implementation DevilHeader

-(id)initWithViewController:(UIViewController*)vc layer:(id)cj withData:(id)data{
    self = [super init];
    
    
    if(cj[@"backgroundColor"]){
        UIColor* bgColor = [WildCardUtil colorWithHexString:cj[@"backgroundColor"]];
        [vc.navigationController.navigationBar setBarTintColor:bgColor];
    }
    
    id layers = cj[@"layers"];
    if(layers){
        for(int i=0;i<[layers count];i++){
            id layer = layers[i];
            if([@"logo" isEqualToString:layer[@"name"]]){
                UIImageView* logo = [[UIImageView alloc] init];
                vc.navigationItem.titleView = logo;
                NSString* url = layer[@"localImageContent"];
                [[WildCardConstructor sharedInstance].delegate loadNetworkImageView:logo withUrl:url];
            }
        }
    }
    
    
    return self;
}

-(void)update{
    
}



@end
