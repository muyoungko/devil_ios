//
//  DevilHeader.h
//  devilcore
//
//  Created by Mu Young Ko on 2020/12/04.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

@interface DevilHeader : NSObject

-(id)initWithViewController:(UIViewController*)viewController layer:(id)headerCloudJson withData:(id)data;
-(void)update;

@end

NS_ASSUME_NONNULL_END
