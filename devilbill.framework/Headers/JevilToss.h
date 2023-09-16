//
//  JevilToss.h
//  devilbill
//
//  Created by Mu Young Ko on 2023/08/14.
//

#import <Foundation/Foundation.h>
@import JavaScriptCore;


NS_ASSUME_NONNULL_BEGIN

@protocol JevilToss <JSExport>

+ (void)order:(id)param :(JSValue *)callback;

@end


@interface JevilToss : NSObject<JevilToss>

@end

NS_ASSUME_NONNULL_END
