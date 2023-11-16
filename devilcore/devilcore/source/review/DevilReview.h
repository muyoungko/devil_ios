//
//  DevilReview.h
//  devilcore
//
//  Created by Mu Young Ko on 2023/11/08.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@interface DevilReview : NSObject

+(DevilReview*)sharedInstance;
-(BOOL)review;
@end

NS_ASSUME_NONNULL_END
