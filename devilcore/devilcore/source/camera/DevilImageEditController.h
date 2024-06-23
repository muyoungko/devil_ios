//
//  DevilImageEditController.h
//  devilcore
//
//  Created by Mu Young Ko on 2024/06/22.
//

#import <devilcore/devilcore.h>

NS_ASSUME_NONNULL_BEGIN

@interface DevilImageEditController : DevilBaseController
@property (nonatomic, retain) NSDictionary* param;
@property void (^callback)(id res);
@end

NS_ASSUME_NONNULL_END
