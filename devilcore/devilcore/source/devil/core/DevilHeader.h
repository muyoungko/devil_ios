//
//  DevilHeader.h
//  devilcore
//
//  Created by Mu Young Ko on 2020/12/04.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>
#import "WildCardConstructor.h"

NS_ASSUME_NONNULL_BEGIN

@interface DevilHeader : NSObject

@property (nonatomic, retain) WildCardMeta* meta;
@property (nonatomic, retain) UIColor* bgcolor;

-(id)initWithViewController:(UIViewController*)vc layer:(id)cj withData:(id)data instanceDelegate:(id)delegate;
-(void)update;
-(void)update:(id)correspondData;
-(void)needAppearanceUpdate;

@end

NS_ASSUME_NONNULL_END
