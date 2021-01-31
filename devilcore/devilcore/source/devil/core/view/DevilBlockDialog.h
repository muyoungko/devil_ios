//
//  DevilBlockDialog.h
//  devilcore
//
//  Created by Mu Young Ko on 2021/02/01.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

@interface DevilBlockDialog : NSObject

-(id)initWithViewController:(UIViewController*)vc;
@property (nonatomic, retain) UIViewController* vc;

-(void)popup:(NSString*)blockName data:(id)data title:(NSString*)title yes:(NSString*)yes no:(NSString*)no onselect:(void (^)(id res))callback;

@end

NS_ASSUME_NONNULL_END
